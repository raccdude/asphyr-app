-- Backend step 4a: the server functions behind quests and rewards. See docs/BACKEND-SPEC.md.
-- They use the same numbers as RewardRules, DifficultyEstimator and DailyQuests in the app,
-- and the server's clock. supabase/tests/quest_functions.test.sql checks every rule.
--
-- The app can call only the functions in `public`. Their helpers and the timer setting
-- live in `private`, which the API can't reach.
--
-- Errors are raised with a short code as the message, for the app to turn into words:
--   not_signed_in, not_found, invalid_input, not_allowed, limit_reached, too_soon

create schema private;
revoke all on schema private from public;

-- The share of a timed quest's duration that must pass before it can be completed.
-- 0.01 while developing, so a 30-minute quest can be finished after 18 seconds.
-- Before release, set it to 0.5 to match the app's Release builds.
create table private.settings (
  id boolean primary key default true check (id),
  minimum_time_fraction numeric not null
    check (minimum_time_fraction > 0 and minimum_time_fraction <= 1)
);

insert into private.settings (minimum_time_fraction) values (0.01);

-- Days are counted at the user's own midnight. The app saves the phone's time zone here.
alter table public.profiles add column time_zone text not null default 'UTC';
grant update (time_zone) on public.profiles to authenticated;

create or replace function public.check_profile_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.id <> old.id then
    raise exception 'A profile can''t change owner';
  end if;

  if new.cloak is not null and new.cloak is distinct from old.cloak and not exists (
    select 1 from public.unlocked_cloaks
    where user_id = new.id and cloak = new.cloak
  ) then
    raise exception 'This cloak isn''t unlocked';
  end if;

  if new.time_zone is distinct from old.time_zone and not exists (
    select 1 from pg_catalog.pg_timezone_names where name = new.time_zone
  ) then
    raise exception 'Unknown time zone';
  end if;

  new.updated_at := now();
  return new;
end;
$$;

-- Helpers ------------------------------------------------------------------------------

create function private.fail(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception using message = code, errcode = 'P0001';
end;
$$;

create function private.user_id()
returns uuid
language plpgsql
stable
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    perform private.fail('not_signed_in');
  end if;
  return v_user;
end;
$$;

-- Every action locks the player's progress first, so two actions at once can't both
-- pass a daily limit.
create function private.lock_progress(p_user uuid)
returns public.player_progress
language plpgsql
set search_path = ''
as $$
declare
  v_progress public.player_progress;
begin
  select * into v_progress from public.player_progress where user_id = p_user for update;
  if not found then
    perform private.fail('not_found');
  end if;
  return v_progress;
end;
$$;

create function private.time_zone(p_user uuid)
returns text
language sql
stable
set search_path = ''
as $$
  select coalesce((select time_zone from public.profiles where id = p_user), 'UTC')
$$;

create function private.own_quest(p_user uuid, p_quest uuid)
returns public.quests
language plpgsql
set search_path = ''
as $$
declare
  v_quest public.quests;
begin
  select * into v_quest from public.quests
  where id = p_quest and user_id = p_user
  for update;

  if not found then
    perform private.fail('not_found');
  end if;
  return v_quest;
end;
$$;

-- Level 1 needs 500 XP, and each one after that needs 200 more.
create function private.level_progress(
  p_xp integer,
  out level integer,
  out xp_into_level integer,
  out xp_for_level integer
)
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_remaining integer := greatest(0, coalesce(p_xp, 0));
begin
  level := 1;
  while v_remaining >= 500 + 200 * (level - 1) loop
    v_remaining := v_remaining - (500 + 200 * (level - 1));
    level := level + 1;
  end loop;
  xp_into_level := v_remaining;
  xp_for_level := 500 + 200 * (level - 1);
end;
$$;

create function private.level_cloaks()
returns table (cloak text, level integer)
language sql
immutable
set search_path = ''
as $$
  values ('Midnight', 3), ('Oxblood', 5), ('Plum', 8)
$$;

create function private.xp_per_step(p_difficulty text)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case p_difficulty when 'EASY' then 50 when 'HARD' then 150 else 100 end
$$;

create function private.timed_xp(p_minutes integer, p_difficulty text)
returns integer
language sql
immutable
set search_path = ''
as $$
  select (p_minutes * 5 / 3)
    * case p_difficulty when 'EASY' then 1 when 'HARD' then 3 else 2 end
$$;

-- Judged from the words, never the duration. Only the title can make a quest Hard, and
-- Hard wins over Easy.
create function private.estimate_difficulty(p_title text, p_description text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when regexp_split_to_array(lower(coalesce(p_title, '')), '[^[:alpha:]]+') && array[
      'algebra', 'algorithm', 'algorithms', 'biology', 'calculus', 'certification', 'chemistry',
      'dissertation', 'exam', 'exams', 'finals', 'geometry', 'interview', 'marathon', 'midterm',
      'midterms', 'orals', 'physics', 'programming', 'research', 'statistics', 'thesis', 'triathlon'
    ] then 'HARD'
    when regexp_split_to_array(
      lower(coalesce(p_title, '') || ' ' || coalesce(p_description, '')), '[^[:alpha:]]+'
    ) && array[
      'dishes', 'drink', 'errand', 'errands', 'laundry', 'meditate', 'nap', 'stretch', 'tidy',
      'vacuum', 'walk', 'water'
    ] then 'EASY'
    else 'MODERATE'
  end
$$;

create function private.is_category(p_category text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select lower(coalesce(p_category, '')) in
    ('development', 'learning', 'health', 'creative', 'career', 'social', 'other')
$$;

create function private.category_attributes(p_category text)
returns text[]
language sql
immutable
set search_path = ''
as $$
  select case lower(coalesce(p_category, ''))
    when 'development' then array['PROBLEM SOLVING', 'KNOWLEDGE']
    when 'learning' then array['KNOWLEDGE', 'DISCIPLINE']
    when 'health' then array['DISCIPLINE']
    when 'creative' then array['CREATIVITY']
    when 'social' then array['CREATIVITY']
    when 'career' then array['DISCIPLINE', 'PROBLEM SOLVING']
    else array['DISCIPLINE']
  end
$$;

-- Longer quests earn more: 30 minutes and quests with no timer earn the base amounts,
-- and 2h+ stops at three times them.
create function private.quest_attributes(p_category text, p_difficulty text, p_minutes integer)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  with amounts as (
    select case p_difficulty when 'EASY' then array[2, 1] when 'HARD' then array[8, 3]
      else array[5, 2] end as values,
    case
      when p_minutes is null then 1.0
      when p_minutes <= 15 then 0.5
      when p_minutes <= 30 then 1.0
      when p_minutes <= 60 then 2.0
      else 3.0
    end as multiplier
  )
  select coalesce(jsonb_agg(
    jsonb_build_object('name', n.name, 'value', ceil(a.values[n.ord] * a.multiplier)::integer)
    order by n.ord
  ), '[]'::jsonb)
  from amounts a, unnest(private.category_attributes(p_category)) with ordinality as n(name, ord)
$$;

-- +1 of the quest's main attribute, for a quest past the daily full-reward limit.
create function private.bonus_attributes(p_rewards jsonb)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select case when jsonb_array_length(coalesce(p_rewards, '[]'::jsonb)) = 0 then '[]'::jsonb
    else jsonb_build_array(jsonb_build_object('name', p_rewards -> 0 ->> 'name', 'value', 1))
  end
$$;

-- The archetype gives the main attribute, and the aspiration's category the second.
create function private.daily_attributes(p_archetype text, p_category text)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  with main as (
    select case coalesce(p_archetype, 'Explorer')
      when 'Strategist' then 'PROBLEM SOLVING'
      when 'Scholar' then 'KNOWLEDGE'
      when 'Creator' then 'CREATIVITY'
      else 'DISCIPLINE'
    end as name
  )
  select jsonb_build_array(
    jsonb_build_object('name', main.name, 'value', 5),
    jsonb_build_object('name', coalesce(
      (select n from unnest(private.category_attributes(p_category)) with ordinality as c(n, ord)
       where n <> main.name order by ord limit 1),
      case when main.name = 'DISCIPLINE' then 'KNOWLEDGE' else 'DISCIPLINE' end
    ), 'value', 2)
  )
  from main
$$;

create function private.quest_json(p_quest uuid)
returns jsonb
language sql
stable
set search_path = ''
as $$
  select to_jsonb(q) - 'user_id' || jsonb_build_object('steps', coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', s.id, 'position', s.position, 'title', s.title, 'done_at', s.done_at
    ) order by s.position)
    from public.quest_steps s where s.quest_id = q.id
  ), '[]'::jsonb))
  from public.quests q where q.id = p_quest
$$;

create function private.player_json(p_user uuid)
returns jsonb
language sql
stable
set search_path = ''
as $$
  select jsonb_build_object(
    'earned_xp', p.earned_xp,
    'level', l.level,
    'xp_into_level', l.xp_into_level,
    'xp_for_level', l.xp_for_level,
    'attribute_gains', jsonb_build_object(
      'KNOWLEDGE', p.knowledge_gain,
      'DISCIPLINE', p.discipline_gain,
      'CREATIVITY', p.creativity_gain,
      'PROBLEM SOLVING', p.problem_solving_gain
    ),
    'announced_level', p.announced_level,
    'seen_lit_star_count', p.seen_lit_star_count,
    'unlocked_cloaks', coalesce((
      select jsonb_agg(c.cloak order by lc.level)
      from public.unlocked_cloaks c join private.level_cloaks() lc on lc.cloak = c.cloak
      where c.user_id = p_user
    ), '[]'::jsonb),
    'earned_achievements', coalesce((
      select jsonb_agg(a.achievement order by a.achievement)
      from public.earned_achievements a where a.user_id = p_user
    ), '[]'::jsonb)
  )
  from public.player_progress p, private.level_progress(p.earned_xp) l
  where p.user_id = p_user
$$;

-- Cloaks and level badges need the XP behind them. Without this, ticking steps,
-- completing any quest and then removing those steps would keep them for free.
create function private.remove_rewards_above_level(p_user uuid)
returns void
language plpgsql
set search_path = ''
as $$
declare
  v_level integer;
begin
  select l.level into v_level
  from public.player_progress p, private.level_progress(p.earned_xp) l
  where p.user_id = p_user;

  delete from public.unlocked_cloaks c
  using private.level_cloaks() lc
  where c.user_id = p_user and c.cloak = lc.cloak and lc.level > v_level;

  delete from public.earned_achievements
  where user_id = p_user
    and ((achievement = 'levelTwo' and v_level < 2) or (achievement = 'master' and v_level < 5));

  -- So the level is announced again when it's earned back
  update public.player_progress
  set announced_level = least(announced_level, v_level), updated_at = now()
  where user_id = p_user;

  -- A cloak that was taken back can't stay worn
  update public.profiles pr
  set cloak = null
  where pr.id = p_user
    and pr.cloak in (select cloak from private.level_cloaks())
    and not exists (
      select 1 from public.unlocked_cloaks c where c.user_id = p_user and c.cloak = pr.cloak
    );
end;
$$;

create function private.give_daily_quest(
  p_user uuid,
  p_title text,
  p_description text,
  p_objective text,
  p_icon_name text,
  p_category text,
  p_replace boolean
)
returns jsonb
language plpgsql
set search_path = ''
as $$
declare
  v_today date := (now() at time zone private.time_zone(p_user))::date;
  v_title text := upper(btrim(coalesce(p_title, '')));
  v_category text := upper(btrim(coalesce(p_category, '')));
  v_archetype text;
  v_id uuid;
begin
  perform private.lock_progress(p_user);

  if v_title = '' or char_length(v_title) > 200
    or char_length(coalesce(p_description, '')) > 1000
    or char_length(coalesce(p_objective, '')) > 1000
    or coalesce(p_icon_name, '') !~ '^[A-Za-z0-9]{1,100}$'
    or not private.is_category(v_category) then
    perform private.fail('invalid_input');
  end if;

  if p_replace then
    -- After the aspiration or archetype changes. One that's been started or finished
    -- today stays, so changing them can't earn a second daily quest.
    if exists (
      select 1 from public.quests
      where user_id = p_user and type = 'daily'
        and (status = 'ACTIVE' or (status = 'COMPLETED' and generated_on = v_today))
    ) then
      return jsonb_build_object('quest', null, 'player', private.player_json(p_user));
    end if;
  else
    -- A daily that's been started stays until it's finished, and one a day is given.
    if exists (
      select 1 from public.quests
      where user_id = p_user and type = 'daily'
        and (generated_on = v_today or status = 'ACTIVE')
    ) then
      return jsonb_build_object('quest', null, 'player', private.player_json(p_user));
    end if;
  end if;

  delete from public.quests where user_id = p_user and type = 'daily' and status = 'AVAILABLE';

  select archetype into v_archetype from public.profiles where id = p_user;

  insert into public.quests (
    user_id, type, title, description, objective, icon_name, category, difficulty,
    duration_minutes, xp_reward, attribute_rewards, status, generated_on
  ) values (
    p_user, 'daily', v_title, nullif(btrim(coalesce(p_description, '')), ''),
    nullif(btrim(coalesce(p_objective, '')), ''), p_icon_name, v_category, 'MODERATE',
    30, private.timed_xp(30, 'MODERATE'), private.daily_attributes(v_archetype, v_category),
    'AVAILABLE', v_today
  )
  returning id into v_id;

  return jsonb_build_object('quest', private.quest_json(v_id), 'player', private.player_json(p_user));
end;
$$;

-- What the app calls ---------------------------------------------------------------------

-- Checks the limits, then works out difficulty, XP and attributes itself.
-- p_type is 'main' or 'personal'. Main quests take 3 to 10 steps and no duration.
-- Personal quests take a duration of 15, 30, 60 or 120 minutes and no steps.
create function public.create_quest(
  p_type text,
  p_title text,
  p_description text default null,
  p_category text default 'Other',
  p_duration_minutes integer default null,
  p_steps text[] default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
  v_type text := lower(btrim(coalesce(p_type, '')));
  v_title text := upper(btrim(coalesce(p_title, '')));
  v_description text := nullif(btrim(coalesce(p_description, '')), '');
  v_category text := upper(btrim(coalesce(p_category, '')));
  v_steps text[] := coalesce(p_steps, '{}');
  v_step_count integer := coalesce(array_length(p_steps, 1), 0);
  v_open_limit integer := case when lower(btrim(coalesce(p_type, ''))) = 'main' then 1 else 5 end;
  v_difficulty text;
  v_id uuid;
begin
  perform private.lock_progress(v_user);

  if v_type not in ('main', 'personal')
    or v_title = '' or char_length(v_title) > 200
    or char_length(coalesce(v_description, '')) > 1000
    or not private.is_category(v_category) then
    perform private.fail('invalid_input');
  end if;

  if v_type = 'main' then
    if p_duration_minutes is not null or v_step_count not between 3 and 10 or exists (
      select 1 from unnest(v_steps) s where btrim(coalesce(s, '')) = '' or char_length(btrim(s)) > 200
    ) then
      perform private.fail('invalid_input');
    end if;
  elsif v_step_count > 0 or coalesce(p_duration_minutes, 0) not in (15, 30, 60, 120) then
    perform private.fail('invalid_input');
  end if;

  -- One main quest and five personal quests can be open at a time
  if (select count(*) from public.quests
      where user_id = v_user and type = v_type and status <> 'COMPLETED') >= v_open_limit then
    perform private.fail('limit_reached');
  end if;

  v_difficulty := private.estimate_difficulty(v_title, v_description);

  insert into public.quests (
    user_id, type, title, description, icon_name, category, difficulty, duration_minutes,
    xp_reward, attribute_rewards, status
  ) values (
    v_user, v_type, v_title, v_description,
    case v_type when 'main' then 'iconQuestBook' else 'iconQuestHammer' end,
    v_category, v_difficulty, p_duration_minutes,
    case v_type
      when 'main' then private.xp_per_step(v_difficulty) * v_step_count
      else private.timed_xp(p_duration_minutes, v_difficulty)
    end,
    private.quest_attributes(v_category, v_difficulty, p_duration_minutes),
    'AVAILABLE'
  )
  returning id into v_id;

  insert into public.quest_steps (quest_id, user_id, position, title)
  select v_id, v_user, (s.ord - 1)::integer, btrim(s.title)
  from unnest(v_steps) with ordinality as s(title, ord);

  return jsonb_build_object('quest', private.quest_json(v_id), 'player', private.player_json(v_user));
end;
$$;

-- At most two quests can be active: the main quest plus one other.
create function public.start_quest(p_quest uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
  v_quest public.quests;
begin
  perform private.lock_progress(v_user);
  v_quest := private.own_quest(v_user, p_quest);

  if v_quest.status <> 'AVAILABLE' then
    perform private.fail('not_allowed');
  end if;

  if v_quest.type <> 'main' and exists (
    select 1 from public.quests where user_id = v_user and type <> 'main' and status = 'ACTIVE'
  ) then
    perform private.fail('limit_reached');
  end if;

  -- Main quests go at the user's own pace, so they have no timer
  update public.quests
  set status = 'ACTIVE',
    started_at = case when duration_minutes is null then null else now() end,
    paused_at = null,
    paused_duration = 0
  where id = p_quest;

  return jsonb_build_object('quest', private.quest_json(p_quest), 'player', private.player_json(v_user));
end;
$$;

-- Pauses or resumes a timed quest. Paused time doesn't count towards its minimum time.
-- Asking for the state it's already in changes nothing, so a retry is safe.
create function public.pause_quest(p_quest uuid, p_paused boolean)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
  v_quest public.quests;
begin
  perform private.lock_progress(v_user);
  v_quest := private.own_quest(v_user, p_quest);

  if v_quest.status <> 'ACTIVE' or v_quest.started_at is null or p_paused is null then
    perform private.fail('not_allowed');
  end if;

  if p_paused and v_quest.paused_at is null then
    update public.quests set paused_at = now() where id = p_quest;
  elsif not p_paused and v_quest.paused_at is not null then
    update public.quests
    set paused_duration = paused_duration + extract(epoch from now() - paused_at),
      paused_at = null
    where id = p_quest;
  end if;

  return jsonb_build_object('quest', private.quest_json(p_quest), 'player', private.player_json(v_user));
end;
$$;

-- Back to available. A main quest keeps its ticked steps and their XP.
create function public.abandon_quest(p_quest uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
  v_quest public.quests;
begin
  perform private.lock_progress(v_user);
  v_quest := private.own_quest(v_user, p_quest);

  if v_quest.status <> 'ACTIVE' then
    perform private.fail('not_allowed');
  end if;

  update public.quests
  set status = 'AVAILABLE', started_at = null, paused_at = null, paused_duration = 0
  where id = p_quest;

  return jsonb_build_object('quest', private.quest_json(p_quest), 'player', private.player_json(v_user));
end;
$$;

-- Ticks or unticks a step of an active quest. Each step's XP is earned when it's ticked,
-- and lost if it's unticked. Ticking stops at 3 a day. Asking for the state it's
-- already in changes nothing, so a retry is safe.
create function public.set_step_done(p_step uuid, p_done boolean)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
  v_tz text := private.time_zone(v_user);
  v_step public.quest_steps;
  v_quest public.quests;
begin
  perform private.lock_progress(v_user);

  select * into v_step from public.quest_steps where id = p_step and user_id = v_user for update;
  if not found then
    perform private.fail('not_found');
  end if;

  v_quest := private.own_quest(v_user, v_step.quest_id);

  if v_quest.status <> 'ACTIVE' or p_done is null then
    perform private.fail('not_allowed');
  end if;

  if p_done and v_step.done_at is null then
    if (select count(*) from public.quest_steps
        where user_id = v_user
          and (done_at at time zone v_tz)::date = (now() at time zone v_tz)::date) >= 3 then
      perform private.fail('limit_reached');
    end if;

    update public.quest_steps set done_at = now() where id = p_step;
    update public.player_progress
    set earned_xp = earned_xp + private.xp_per_step(v_quest.difficulty), updated_at = now()
    where user_id = v_user;
  elsif not p_done and v_step.done_at is not null then
    update public.quest_steps set done_at = null where id = p_step;
    update public.player_progress
    set earned_xp = greatest(0, earned_xp - private.xp_per_step(v_quest.difficulty)), updated_at = now()
    where user_id = v_user;
    perform private.remove_rewards_above_level(v_user);
  end if;

  return jsonb_build_object('quest', private.quest_json(v_quest.id), 'player', private.player_json(v_user));
end;
$$;

-- Checks the steps and minimum time, then awards rewards, cloaks and badges, and returns
-- what Reward shows. Personal quests past 3 full rewards a day earn the flat bonus.
create function public.complete_quest(p_quest uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
  v_tz text := private.time_zone(v_user);
  v_today date := (now() at time zone v_tz)::date;
  v_quest public.quests;
  v_progress public.player_progress;
  v_fraction numeric;
  v_elapsed double precision;
  v_has_steps boolean;
  v_full boolean;
  v_reward jsonb;
  v_level integer;
  v_xp_into integer;
  v_xp_for integer;
  v_level_before integer;
  v_new_cloaks jsonb;
begin
  v_progress := private.lock_progress(v_user);
  v_quest := private.own_quest(v_user, p_quest);

  if v_quest.status <> 'ACTIVE' or exists (
    select 1 from public.quest_steps where quest_id = p_quest and done_at is null
  ) then
    perform private.fail('not_allowed');
  end if;

  if v_quest.started_at is not null and v_quest.duration_minutes is not null then
    select minimum_time_fraction into v_fraction from private.settings;
    v_elapsed := greatest(0,
      extract(epoch from coalesce(v_quest.paused_at, now()) - v_quest.started_at)
        - v_quest.paused_duration);
    if v_elapsed < v_quest.duration_minutes * 60 * v_fraction then
      perform private.fail('too_soon');
    end if;
  end if;

  v_full := v_quest.type <> 'personal' or (
    select count(*) from public.quests
    where user_id = v_user and type = 'personal' and status = 'COMPLETED'
      and not is_bonus_reward and (completed_at at time zone v_tz)::date = v_today
  ) < 3;

  update public.quests
  set status = 'COMPLETED',
    completed_at = now(),
    paused_at = coalesce(paused_at, now()),
    is_bonus_reward = not v_full,
    xp_reward = case when v_full then xp_reward else 10 end,
    attribute_rewards = case when v_full then attribute_rewards
      else private.bonus_attributes(attribute_rewards) end
  where id = p_quest
  returning * into v_quest;

  -- Quests with steps have already earned their XP
  v_has_steps := exists (select 1 from public.quest_steps where quest_id = p_quest);

  update public.player_progress p
  set earned_xp = p.earned_xp + case when v_has_steps then 0 else v_quest.xp_reward end,
    knowledge_gain = p.knowledge_gain + coalesce(g.knowledge, 0),
    discipline_gain = p.discipline_gain + coalesce(g.discipline, 0),
    creativity_gain = p.creativity_gain + coalesce(g.creativity, 0),
    problem_solving_gain = p.problem_solving_gain + coalesce(g.problem_solving, 0),
    updated_at = now()
  from (
    select
      sum((r ->> 'value')::integer) filter (where r ->> 'name' = 'KNOWLEDGE') as knowledge,
      sum((r ->> 'value')::integer) filter (where r ->> 'name' = 'DISCIPLINE') as discipline,
      sum((r ->> 'value')::integer) filter (where r ->> 'name' = 'CREATIVITY') as creativity,
      sum((r ->> 'value')::integer) filter (where r ->> 'name' = 'PROBLEM SOLVING') as problem_solving
    from jsonb_array_elements(v_quest.attribute_rewards) r
  ) g
  where p.user_id = v_user
  returning p.* into v_progress;

  select level, xp_into_level, xp_for_level into v_level, v_xp_into, v_xp_for
  from private.level_progress(v_progress.earned_xp);

  -- Every cloak the level has reached, so one reached by ticking steps isn't lost if
  -- that main quest is later deleted
  with added as (
    insert into public.unlocked_cloaks (user_id, cloak)
    select v_user, cloak from private.level_cloaks() where level <= v_level
    on conflict do nothing
    returning cloak
  )
  select coalesce(jsonb_agg(a.cloak order by lc.level), '[]'::jsonb) into v_new_cloaks
  from added a join private.level_cloaks() lc on lc.cloak = a.cloak;

  insert into public.earned_achievements (user_id, achievement)
  select v_user, a from unnest(array_remove(array[
    'firstQuest',
    case when v_level >= 2 then 'levelTwo' end,
    case when (
      select count(distinct (completed_at at time zone v_tz)::date) from public.quests
      where user_id = v_user and status = 'COMPLETED'
    ) >= 3 then 'consistency' end,
    case when 10 + v_progress.knowledge_gain >= 25 then 'scholar' end,
    case when 10 + v_progress.problem_solving_gain >= 25 then 'builder' end,
    case when v_level >= 5 then 'master' end
  ], null)) a
  on conflict do nothing;

  v_level_before := v_progress.announced_level;
  update public.player_progress
  set announced_level = greatest(announced_level, v_level)
  where user_id = v_user;

  v_reward := jsonb_build_object(
    'elapsed_seconds', case when v_quest.started_at is null then 0 else greatest(0,
      extract(epoch from v_quest.paused_at - v_quest.started_at) - v_quest.paused_duration) end,
    'level_before', v_level_before,
    'level_after', v_level,
    'xp_into_level', v_xp_into,
    'xp_for_level', v_xp_for,
    'new_cloaks', v_new_cloaks
  );

  return jsonb_build_object(
    'quest', private.quest_json(p_quest),
    'player', private.player_json(v_user),
    'reward', v_reward
  );
end;
$$;

-- Daily quests renew on their own, and completed quests stay as a record. A main quest's
-- step XP goes with it, so deleting and recreating gains nothing.
create function public.delete_quest(p_quest uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
  v_quest public.quests;
  v_done integer;
begin
  perform private.lock_progress(v_user);
  v_quest := private.own_quest(v_user, p_quest);

  if v_quest.type = 'daily' or v_quest.status = 'COMPLETED' then
    perform private.fail('not_allowed');
  end if;

  if v_quest.type = 'main' then
    select count(*) into v_done from public.quest_steps where quest_id = p_quest and done_at is not null;
    update public.player_progress
    set earned_xp = greatest(0, earned_xp - v_done * private.xp_per_step(v_quest.difficulty)),
      updated_at = now()
    where user_id = v_user;
  end if;

  delete from public.quests where id = p_quest;
  perform private.remove_rewards_above_level(v_user);

  return jsonb_build_object('quest', null, 'player', private.player_json(v_user));
end;
$$;

-- Gives today's daily quest, written by the app. The server sets its rewards from the
-- profile's archetype and the category, and allows one a day. Returns a null quest when
-- nothing changed.
create function public.refresh_daily_quest(
  p_title text,
  p_description text,
  p_objective text,
  p_icon_name text,
  p_category text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  return private.give_daily_quest(
    private.user_id(), p_title, p_description, p_objective, p_icon_name, p_category, false
  );
end;
$$;

-- Swaps today's daily quest after the aspiration or archetype changes, unless it's been
-- started or finished today.
create function public.renew_daily_quest(
  p_title text,
  p_description text,
  p_objective text,
  p_icon_name text,
  p_category text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  return private.give_daily_quest(
    private.user_id(), p_title, p_description, p_objective, p_icon_name, p_category, true
  );
end;
$$;

-- How many Journey stars have been announced, so each shows once. Display only.
create function public.mark_journey_seen(p_lit_star_count integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
begin
  perform private.lock_progress(v_user);

  update public.player_progress
  set seen_lit_star_count = greatest(0, least(coalesce(p_lit_star_count, 0), 10000)),
    updated_at = now()
  where user_id = v_user;

  return jsonb_build_object('player', private.player_json(v_user));
end;
$$;

-- Clears everything earned. The account, name and identity stay.
create function public.reset_progress()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
begin
  perform private.lock_progress(v_user);

  delete from public.quests where user_id = v_user;
  delete from public.unlocked_cloaks where user_id = v_user;
  delete from public.earned_achievements where user_id = v_user;
  update public.player_progress
  set earned_xp = 0, knowledge_gain = 0, discipline_gain = 0, creativity_gain = 0,
    problem_solving_gain = 0, announced_level = 1, seen_lit_star_count = 0, updated_at = now()
  where user_id = v_user;
  -- Cloaks are earned again from level 3
  update public.profiles set cloak = null where id = v_user;

  return jsonb_build_object('player', private.player_json(v_user));
end;
$$;

-- Security: only signed-in users can call the functions above, and nothing in `private`
-- can be reached from the API.
revoke all on all functions in schema private from public, anon, authenticated;
revoke all on all tables in schema private from public, anon, authenticated;

revoke all on function
  public.create_quest(text, text, text, text, integer, text[]),
  public.start_quest(uuid),
  public.pause_quest(uuid, boolean),
  public.abandon_quest(uuid),
  public.set_step_done(uuid, boolean),
  public.complete_quest(uuid),
  public.delete_quest(uuid),
  public.refresh_daily_quest(text, text, text, text, text),
  public.renew_daily_quest(text, text, text, text, text),
  public.mark_journey_seen(integer),
  public.reset_progress()
from public, anon;

grant execute on function
  public.create_quest(text, text, text, text, integer, text[]),
  public.start_quest(uuid),
  public.pause_quest(uuid, boolean),
  public.abandon_quest(uuid),
  public.set_step_done(uuid, boolean),
  public.complete_quest(uuid),
  public.delete_quest(uuid),
  public.refresh_daily_quest(text, text, text, text, text),
  public.renew_daily_quest(text, text, text, text, text),
  public.mark_journey_seen(integer),
  public.reset_progress()
to authenticated;

-- The trigger function was replaced above, so it needs its grants removed again
revoke all on function public.check_profile_update() from public, anon, authenticated;
