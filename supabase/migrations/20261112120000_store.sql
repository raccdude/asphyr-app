-- The Store: Embers, earned from completed quests and spent on cloaks. See
-- docs/superpowers/specs/2026-11-12-store-and-inventory-design.md.

alter table public.player_progress
  add column embers integer not null default 0 check (embers >= 0);

-- What's for sale. Changing a price here needs no app update.
create table private.store_items (
  item text primary key
    check (item in ('Midnight', 'Oxblood', 'Plum', 'Green', 'Yellow', 'Snow', 'Teal')),
  price integer not null check (price > 0),
  position integer not null unique
);

insert into private.store_items (item, price, position) values
  ('Green', 200, 1),
  ('Yellow', 200, 2),
  ('Snow', 200, 3),
  ('Teal', 200, 4);

-- Pays existing accounts, once, for the quests they had already completed
update public.player_progress p
set embers = paid.embers
from (
  select user_id, sum(xp_reward / 10)::integer as embers
  from public.quests
  where status = 'COMPLETED'
  group by user_id
) paid
where paid.user_id = p.user_id;

create or replace function private.player_json(p_user uuid)
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
    'embers', p.embers,
    -- Every cloak owned: level cloaks first, then bought ones in store order
    'owned_cloaks', coalesce((
      select jsonb_agg(c.cloak order by coalesce(lc.level, 100), s.position)
      from public.unlocked_cloaks c
      left join private.level_cloaks() lc on lc.cloak = c.cloak
      left join private.store_items s on s.item = c.cloak
      where c.user_id = p_user
    ), '[]'::jsonb),
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

create or replace function public.complete_quest(p_quest uuid)
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
  v_embers integer;
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

  -- 1 Ember for every 10 XP the quest gives, paid now rather than per step, so
  -- ticking steps and deleting the quest earns nothing
  v_embers := v_quest.xp_reward / 10;

  -- Quests with steps have already earned their XP
  v_has_steps := exists (select 1 from public.quest_steps where quest_id = p_quest);

  update public.player_progress p
  set earned_xp = p.earned_xp + case when v_has_steps then 0 else v_quest.xp_reward end,
    knowledge_gain = p.knowledge_gain + coalesce(g.knowledge, 0),
    discipline_gain = p.discipline_gain + coalesce(g.discipline, 0),
    creativity_gain = p.creativity_gain + coalesce(g.creativity, 0),
    problem_solving_gain = p.problem_solving_gain + coalesce(g.problem_solving, 0),
    embers = p.embers + v_embers,
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
    'new_cloaks', v_new_cloaks,
    'embers_earned', v_embers
  );

  return jsonb_build_object(
    'quest', private.quest_json(p_quest),
    'player', private.player_json(v_user),
    'reward', v_reward
  );
end;
$$;

create or replace function public.reset_progress()
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
    problem_solving_gain = 0, embers = 0, announced_level = 1, seen_lit_star_count = 0, updated_at = now()
  where user_id = v_user;
  -- Cloaks are earned again from level 3, and bought ones with new Embers
  update public.profiles set cloak = null where id = v_user;

  return jsonb_build_object('player', private.player_json(v_user));
end;
$$;

create or replace function public.get_player_state(p_time_zone text default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
begin
  if p_time_zone is not null and exists (
    select 1 from pg_catalog.pg_timezone_names where name = p_time_zone
  ) then
    update public.profiles set time_zone = p_time_zone
    where id = v_user and time_zone is distinct from p_time_zone;
  end if;

  return jsonb_build_object(
    'quests', coalesce((
      select jsonb_agg(private.quest_json(q.id) order by q.created_at, q.id)
      from public.quests q where q.user_id = v_user
    ), '[]'::jsonb),
    'player', private.player_json(v_user),
    'store', coalesce((
      select jsonb_agg(jsonb_build_object('item', item, 'price', price) order by position)
      from private.store_items
    ), '[]'::jsonb)
  );
end;
$$;

-- Spends Embers on a cloak from the store, in one transaction. The cloak joins
-- unlocked_cloaks, so the profile can wear it, and losing a level never takes it back.
create function public.buy_cloak(p_cloak text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := private.user_id();
  v_progress public.player_progress;
  v_price integer;
begin
  v_progress := private.lock_progress(v_user);

  select price into v_price from private.store_items where item = p_cloak;
  if v_price is null then
    perform private.fail('not_found');
  end if;

  if exists (select 1 from public.unlocked_cloaks where user_id = v_user and cloak = p_cloak) then
    perform private.fail('not_allowed');
  end if;

  if v_progress.embers < v_price then
    perform private.fail('not_enough_embers');
  end if;

  update public.player_progress
  set embers = embers - v_price, updated_at = now()
  where user_id = v_user;

  insert into public.unlocked_cloaks (user_id, cloak) values (v_user, p_cloak);

  return jsonb_build_object('quest', null, 'player', private.player_json(v_user));
end;
$$;

revoke all on table private.store_items from public, anon, authenticated;
revoke all on function private.player_json(uuid) from public, anon, authenticated;
revoke all on function
  public.complete_quest(uuid),
  public.reset_progress(),
  public.get_player_state(text),
  public.buy_cloak(text)
from public, anon;
grant execute on function
  public.complete_quest(uuid),
  public.reset_progress(),
  public.get_player_state(text),
  public.buy_cloak(text)
to authenticated;
