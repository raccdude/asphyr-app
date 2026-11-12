-- Checks every quest and reward rule in the server functions, on a local Postgres.
-- Run with: zsh scripts/db-tests/run.sh
-- Calls go through the `authenticated` role with a signed-in user, the way the app's do.
-- Time is moved by shifting stored timestamps, so the functions keep the real clock.

\set ON_ERROR_STOP on
set client_min_messages = warning;

create schema tests;
create table tests.results (id serial, name text, ok boolean);

create function tests.check(p_name text, p_ok boolean) returns void
language plpgsql as $$
begin
  insert into tests.results (name, ok) values (p_name, coalesce(p_ok, false));
  raise warning '% %', case when coalesce(p_ok, false) then 'pass' else 'FAIL' end, p_name;
end;
$$;

-- Runs `select <p_sql>` as the user, as the app would.
create function tests.act(p_user uuid, p_sql text) returns jsonb
language plpgsql as $$
declare
  v jsonb;
begin
  perform set_config('request.jwt.claim.sub', coalesce(p_user::text, ''), false);
  set role authenticated;
  execute 'select ' || p_sql into v;
  reset role;
  return v;
exception when others then
  reset role;
  raise;
end;
$$;

-- The error the call raised, or null if it worked.
create function tests.error(p_user uuid, p_sql text, p_role text default 'authenticated') returns text
language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', coalesce(p_user::text, ''), false);
  execute format('set role %I', p_role);
  execute 'select ' || p_sql;
  reset role;
  return null;
exception when others then
  reset role;
  return sqlerrm;
end;
$$;

create function tests.new_user(p_time_zone text default 'UTC') returns uuid
language plpgsql as $$
declare
  v uuid := gen_random_uuid();
begin
  insert into auth.users (id, email) values (v, v || '@example.com');
  update public.profiles
  set name = 'Lou', archetype = 'Strategist', aspiration = 'Game Developer', time_zone = p_time_zone
  where id = v;
  return v;
end;
$$;

create function tests.personal(p_user uuid, p_title text default 'Read a book', p_minutes int default 30)
returns uuid language sql as $$
  select (tests.act(p_user, format('public.create_quest(%L, %L, null, %L, %s)',
    'personal', p_title, 'Learning', p_minutes)) -> 'quest' ->> 'id')::uuid
$$;

create function tests.main(p_user uuid, p_title text default 'Physics review', p_steps int default 3)
returns uuid language sql as $$
  select (tests.act(p_user, format('public.create_quest(%L, %L, null, %L, null, %L::text[])',
    'main', p_title, 'Development',
    (select array_agg('Step ' || i) from generate_series(1, p_steps) i))) -> 'quest' ->> 'id')::uuid
$$;

-- Starts a quest and moves its start back far enough to complete it.
create function tests.finish(p_user uuid, p_quest uuid) returns jsonb
language plpgsql as $$
begin
  perform tests.act(p_user, format('public.start_quest(%L)', p_quest));
  update public.quests set started_at = started_at - interval '2 hours' where id = p_quest;
  return tests.act(p_user, format('public.complete_quest(%L)', p_quest));
end;
$$;

create function tests.step(p_quest uuid, p_position int) returns uuid
language sql as $$
  select id from public.quest_steps where quest_id = p_quest and position = p_position
$$;

create function tests.xp(p_user uuid) returns int
language sql as $$
  select earned_xp from public.player_progress where user_id = p_user
$$;

-- Rules -------------------------------------------------------------------------------

do $$
begin
  perform tests.check('level 1 starts at 0 of 500',
    (select row(level, xp_into_level, xp_for_level) = row(1, 0, 500) from private.level_progress(0)));
  perform tests.check('499 XP is still level 1', (select level = 1 from private.level_progress(499)));
  perform tests.check('500 XP is level 2 of 700',
    (select row(level, xp_into_level, xp_for_level) = row(2, 0, 700) from private.level_progress(500)));
  perform tests.check('1100 XP is level 2 with 600 in',
    (select row(level, xp_into_level) = row(2, 600) from private.level_progress(1100)));
  perform tests.check('1200 XP is level 3', (select level = 3 from private.level_progress(1200)));

  perform tests.check('30m moderate is 100 XP', private.timed_xp(30, 'MODERATE') = 100);
  perform tests.check('15m easy is 25 XP', private.timed_xp(15, 'EASY') = 25);
  perform tests.check('1h moderate is 200 XP', private.timed_xp(60, 'MODERATE') = 200);
  perform tests.check('2h+ hard is 600 XP', private.timed_xp(120, 'HARD') = 600);
  perform tests.check('step XP is 50, 100, 150',
    array[private.xp_per_step('EASY'), private.xp_per_step('MODERATE'), private.xp_per_step('HARD')]
      = array[50, 100, 150]);

  -- The same cases as scripts/rule-tests/rewards
  perform tests.check('15m easy 1,1', private.quest_attributes('development', 'EASY', 15)
    = '[{"name":"PROBLEM SOLVING","value":1},{"name":"KNOWLEDGE","value":1}]');
  perform tests.check('15m moderate 3,1', private.quest_attributes('development', 'MODERATE', 15)
    = '[{"name":"PROBLEM SOLVING","value":3},{"name":"KNOWLEDGE","value":1}]');
  perform tests.check('15m hard 4,2', private.quest_attributes('development', 'HARD', 15)
    = '[{"name":"PROBLEM SOLVING","value":4},{"name":"KNOWLEDGE","value":2}]');
  perform tests.check('30m moderate 5,2', private.quest_attributes('development', 'MODERATE', 30)
    = '[{"name":"PROBLEM SOLVING","value":5},{"name":"KNOWLEDGE","value":2}]');
  perform tests.check('1h moderate 10,4', private.quest_attributes('development', 'MODERATE', 60)
    = '[{"name":"PROBLEM SOLVING","value":10},{"name":"KNOWLEDGE","value":4}]');
  perform tests.check('2h+ moderate 15,6', private.quest_attributes('development', 'MODERATE', 120)
    = '[{"name":"PROBLEM SOLVING","value":15},{"name":"KNOWLEDGE","value":6}]');
  perform tests.check('2h+ hard 24,9', private.quest_attributes('development', 'HARD', 120)
    = '[{"name":"PROBLEM SOLVING","value":24},{"name":"KNOWLEDGE","value":9}]');
  perform tests.check('no duration stays at the base', private.quest_attributes('development', 'HARD', null)
    = '[{"name":"PROBLEM SOLVING","value":8},{"name":"KNOWLEDGE","value":3}]');
  perform tests.check('health gives only discipline', private.quest_attributes('HEALTH', 'MODERATE', 30)
    = '[{"name":"DISCIPLINE","value":5}]');

  perform tests.check('hard word in title is Hard',
    private.estimate_difficulty('Tidy my calculus notes', '') = 'HARD');
  perform tests.check('hard word only in description isn''t Hard',
    private.estimate_difficulty('Clean my room', 'before my exam') = 'MODERATE');
  perform tests.check('easy word in description is still Easy',
    private.estimate_difficulty('Chores', 'do the laundry') = 'EASY');
  perform tests.check('title Walk with exam in description is Easy',
    private.estimate_difficulty('Walk', 'exam') = 'EASY');
  perform tests.check('words are matched whole, so "examine" isn''t Hard',
    private.estimate_difficulty('Examine the plan', '') = 'MODERATE');

  perform tests.check('Strategist developer daily: problem solving 5, knowledge 2',
    private.daily_attributes('Strategist', 'DEVELOPMENT')
      = '[{"name":"PROBLEM SOLVING","value":5},{"name":"KNOWLEDGE","value":2}]');
  perform tests.check('Explorer health daily falls back to knowledge',
    private.daily_attributes('Explorer', 'HEALTH')
      = '[{"name":"DISCIPLINE","value":5},{"name":"KNOWLEDGE","value":2}]');
  perform tests.check('Creator creative daily falls back to discipline',
    private.daily_attributes('Creator', 'CREATIVE')
      = '[{"name":"CREATIVITY","value":5},{"name":"DISCIPLINE","value":2}]');
  perform tests.check('no archetype counts as Explorer',
    private.daily_attributes(null, 'LEARNING')
      = '[{"name":"DISCIPLINE","value":5},{"name":"KNOWLEDGE","value":2}]');
end;
$$;

-- Security ----------------------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  b uuid := tests.new_user();
  q uuid := tests.personal(a);
begin
  perform tests.check('signed-out visitors can''t call the functions',
    tests.error(null, 'public.reset_progress()', 'anon') like 'permission denied%');
  perform tests.check('a request with no user is refused',
    tests.error(null, 'public.reset_progress()') = 'not_signed_in');
  perform tests.check('the helpers can''t be called from the app',
    tests.error(a, 'private.level_progress(0)') like 'permission denied%');
  perform tests.check('the timer setting can''t be read from the app',
    tests.error(a, '* from private.settings') like 'permission denied%');
  perform tests.check('another user''s quest can''t be started',
    tests.error(b, format('public.start_quest(%L)', q)) = 'not_found');
  perform tests.check('another user''s quest can''t be deleted',
    tests.error(b, format('public.delete_quest(%L)', q)) = 'not_found'
    and exists (select 1 from public.quests where id = q));
end;
$$;

-- tests.error runs one statement, so the two writes above need checking another way
do $$
declare
  a uuid := tests.new_user();
  v text;
begin
  perform set_config('request.jwt.claim.sub', a::text, false);
  set role authenticated;
  begin
    update public.player_progress set earned_xp = 9999 where user_id = a;
    v := null;
  exception when others then
    v := sqlerrm;
  end;
  begin
    update public.profiles set time_zone = 'Mars/Olympus' where id = a;
  exception when others then
    v := v || ' | ' || sqlerrm;
  end;
  begin
    update public.profiles set time_zone = 'Asia/Manila' where id = a;
  exception when others then
    v := v || ' | manila failed';
  end;
  reset role;

  perform tests.check('progress update is denied', v like 'permission denied%');
  perform tests.check('unknown time zone is denied', v like '%Unknown time zone%');
  perform tests.check('a real time zone is saved',
    v not like '%manila failed%' and (select time_zone from public.profiles where id = a) = 'Asia/Manila');
end;
$$;

-- Create ------------------------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  r jsonb;
  m uuid;
begin
  r := tests.act(a, 'public.create_quest(''personal'', ''  study physics '', ''Chapter 2'', ''Learning'', 60)');
  perform tests.check('personal quest: title trimmed and in capitals', r -> 'quest' ->> 'title' = 'STUDY PHYSICS');
  perform tests.check('personal quest: the server judges it Hard', r -> 'quest' ->> 'difficulty' = 'HARD');
  perform tests.check('personal quest: 1h hard is 300 XP', (r -> 'quest' ->> 'xp_reward')::int = 300);
  perform tests.check('personal quest: learning attributes for 1h hard',
    r -> 'quest' -> 'attribute_rewards' = '[{"name":"KNOWLEDGE","value":16},{"name":"DISCIPLINE","value":6}]');
  perform tests.check('personal quest: hammer icon, category in capitals',
    r -> 'quest' ->> 'icon_name' = 'iconQuestHammer' and r -> 'quest' ->> 'category' = 'LEARNING');
  perform tests.check('personal quest: reply includes the player', (r -> 'player' ->> 'level')::int = 1);

  perform tests.check('main quest needs 3 steps',
    tests.error(a, 'public.create_quest(''main'', ''Learn Swift'', null, ''Learning'', null, array[''a'', ''b''])')
      = 'invalid_input');
  perform tests.check('main quest takes at most 10 steps',
    tests.error(a, format('public.create_quest(''main'', ''Learn Swift'', null, ''Learning'', null, %L::text[])',
      (select array_agg('s' || i) from generate_series(1, 11) i))) = 'invalid_input');
  perform tests.check('main quest steps can''t be blank',
    tests.error(a, 'public.create_quest(''main'', ''Learn Swift'', null, ''Learning'', null, array[''a'', '' '', ''c''])')
      = 'invalid_input');
  perform tests.check('main quest has no duration',
    tests.error(a, 'public.create_quest(''main'', ''Learn Swift'', null, ''Learning'', 30, array[''a'', ''b'', ''c''])')
      = 'invalid_input');

  m := tests.main(a, 'Physics review', 4);
  perform tests.check('main quest: 4 hard steps is 600 XP',
    (select xp_reward = 600 and difficulty = 'HARD' and duration_minutes is null and icon_name = 'iconQuestBook'
     from public.quests where id = m));
  perform tests.check('main quest: steps saved in order',
    (select array_agg(title order by position) from public.quest_steps where quest_id = m)
      = array['Step 1', 'Step 2', 'Step 3', 'Step 4']);
  perform tests.check('main quest: no attribute multiplier',
    (select attribute_rewards from public.quests where id = m)
      = '[{"name":"PROBLEM SOLVING","value":8},{"name":"KNOWLEDGE","value":3}]');
  perform tests.check('only one main quest open at a time',
    tests.error(a, 'public.create_quest(''main'', ''Another'', null, ''Other'', null, array[''a'', ''b'', ''c''])')
      = 'limit_reached');

  perform tests.check('personal quest has no steps',
    tests.error(a, 'public.create_quest(''personal'', ''Run'', null, ''Health'', 30, array[''a''])') = 'invalid_input');
  perform tests.check('personal quest duration must be one of the choices',
    tests.error(a, 'public.create_quest(''personal'', ''Run'', null, ''Health'', 45)') = 'invalid_input');
  perform tests.check('category must be one of the choices',
    tests.error(a, 'public.create_quest(''personal'', ''Run'', null, ''Gaming'', 30)') = 'invalid_input');
  perform tests.check('title can''t be blank',
    tests.error(a, 'public.create_quest(''personal'', ''   '', null, ''Health'', 30)') = 'invalid_input');
  perform tests.check('daily quests can''t be created',
    tests.error(a, 'public.create_quest(''daily'', ''Run'', null, ''Health'', 30)') = 'invalid_input');

  perform tests.personal(a); perform tests.personal(a); perform tests.personal(a); perform tests.personal(a);
  perform tests.check('only five personal quests open at a time',
    tests.error(a, 'public.create_quest(''personal'', ''Sixth'', null, ''Other'', 30)') = 'limit_reached');
end;
$$;

-- Start, pause and abandon -------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  p1 uuid := tests.personal(a);
  p2 uuid := tests.personal(a);
  m uuid := tests.main(a);
  r jsonb;
begin
  r := tests.act(a, format('public.start_quest(%L)', p1));
  perform tests.check('starting a timed quest starts its timer',
    r -> 'quest' ->> 'status' = 'ACTIVE' and r -> 'quest' ->> 'started_at' is not null);
  perform tests.check('only one personal or daily quest active at a time',
    tests.error(a, format('public.start_quest(%L)', p2)) = 'limit_reached');
  r := tests.act(a, format('public.start_quest(%L)', m));
  perform tests.check('the main quest can be active alongside, with no timer',
    r -> 'quest' ->> 'status' = 'ACTIVE' and r -> 'quest' ->> 'started_at' is null);
  perform tests.check('an active quest can''t be started again',
    tests.error(a, format('public.start_quest(%L)', p1)) = 'not_allowed');

  perform tests.check('a quest with no timer can''t be paused',
    tests.error(a, format('public.pause_quest(%L, true)', m)) = 'not_allowed');
  perform tests.act(a, format('public.pause_quest(%L, true)', p1));
  update public.quests set paused_at = paused_at - interval '5 minutes' where id = p1;
  r := tests.act(a, format('public.pause_quest(%L, true)', p1));
  perform tests.check('pausing twice changes nothing',
    to_timestamp((r -> 'quest' ->> 'paused_at')::float) < now() - interval '4 minutes');
  r := tests.act(a, format('public.pause_quest(%L, false)', p1));
  perform tests.check('resuming adds the paused time',
    r -> 'quest' ->> 'paused_at' is null and (r -> 'quest' ->> 'paused_duration')::float between 299 and 301);

  r := tests.act(a, format('public.abandon_quest(%L)', p1));
  perform tests.check('abandoning makes it available and clears the timer',
    r -> 'quest' ->> 'status' = 'AVAILABLE' and r -> 'quest' ->> 'started_at' is null
    and (r -> 'quest' ->> 'paused_duration')::float = 0);
  perform tests.check('an available quest can''t be abandoned',
    tests.error(a, format('public.abandon_quest(%L)', p1)) = 'not_allowed');
  perform tests.check('after abandoning, another quest can start',
    tests.error(a, format('public.start_quest(%L)', p2)) is null);
end;
$$;

-- Steps -------------------------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  m uuid := tests.main(a, 'Physics review', 5);
  r jsonb;
begin
  perform tests.check('steps can''t be ticked before the quest is accepted',
    tests.error(a, format('public.set_step_done(%L, true)', tests.step(m, 0))) = 'not_allowed');
  perform tests.act(a, format('public.start_quest(%L)', m));

  r := tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 0)));
  perform tests.check('ticking a hard step earns 150 XP', (r -> 'player' ->> 'earned_xp')::int = 150);
  r := tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 0)));
  perform tests.check('ticking a ticked step changes nothing', (r -> 'player' ->> 'earned_xp')::int = 150);
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 1)));
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 2)));
  perform tests.check('three steps a day', tests.xp(a) = 450);
  perform tests.check('a fourth step today is refused',
    tests.error(a, format('public.set_step_done(%L, true)', tests.step(m, 3))) = 'limit_reached'
    and tests.xp(a) = 450);

  r := tests.act(a, format('public.set_step_done(%L, false)', tests.step(m, 2)));
  perform tests.check('unticking takes the XP back', (r -> 'player' ->> 'earned_xp')::int = 300);
  perform tests.check('unticking frees today''s count',
    tests.error(a, format('public.set_step_done(%L, true)', tests.step(m, 3))) is null);

  update public.quest_steps set done_at = done_at - interval '1 day' where quest_id = m and done_at is not null;
  perform tests.check('steps ticked yesterday don''t count today',
    tests.error(a, format('public.set_step_done(%L, true)', tests.step(m, 4))) is null and tests.xp(a) = 600);
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 2)));
  perform tests.act(a, format('public.complete_quest(%L)', m));
  perform tests.check('a completed quest''s steps can''t be changed',
    tests.error(a, format('public.set_step_done(%L, false)', tests.step(m, 0))) = 'not_allowed'
    and tests.xp(a) = 750);
end;
$$;

-- Complete ----------------------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  p uuid := tests.personal(a, 'Read a book', 30);
  r jsonb;
begin
  perform tests.check('an available quest can''t be completed',
    tests.error(a, format('public.complete_quest(%L)', p)) = 'not_allowed');
  perform tests.act(a, format('public.start_quest(%L)', p));
  perform tests.check('a timed quest can''t be completed straight away',
    tests.error(a, format('public.complete_quest(%L)', p)) = 'too_soon');

  -- 1% of 30 minutes is 18 seconds. Started a minute ago, but paused for 50 seconds of it.
  update public.quests set started_at = now() - interval '60 seconds', paused_duration = 50 where id = p;
  perform tests.check('paused time doesn''t count towards the minimum',
    tests.error(a, format('public.complete_quest(%L)', p)) = 'too_soon');
  update public.quests set paused_duration = 0 where id = p;

  r := tests.act(a, format('public.complete_quest(%L)', p));
  perform tests.check('completing earns the quest''s XP', (r -> 'player' ->> 'earned_xp')::int = 100);
  perform tests.check('completing adds the attributes',
    (r -> 'player' -> 'attribute_gains' ->> 'KNOWLEDGE')::int = 5
    and (r -> 'player' -> 'attribute_gains' ->> 'DISCIPLINE')::int = 2);
  perform tests.check('the first quest badge is earned', r -> 'player' -> 'earned_achievements' ? 'firstQuest');
  perform tests.check('Reward gets the level and time',
    (r -> 'reward' ->> 'level_before')::int = 1 and (r -> 'reward' ->> 'level_after')::int = 1
    and (r -> 'reward' ->> 'xp_into_level')::int = 100 and (r -> 'reward' ->> 'xp_for_level')::int = 500
    and (r -> 'reward' ->> 'elapsed_seconds')::float between 59 and 61);
  perform tests.check('a completed quest can''t be completed again',
    tests.error(a, format('public.complete_quest(%L)', p)) = 'not_allowed');
  perform tests.check('a completed quest can''t be deleted',
    tests.error(a, format('public.delete_quest(%L)', p)) = 'not_allowed');
end;
$$;

do $$
declare
  a uuid := tests.new_user();
  r jsonb;
  m uuid;
begin
  perform tests.finish(a, tests.personal(a));
  perform tests.finish(a, tests.personal(a));
  perform tests.finish(a, tests.personal(a));
  r := tests.finish(a, tests.personal(a));
  perform tests.check('the fourth personal quest today earns the bonus',
    (r -> 'quest' ->> 'is_bonus_reward')::boolean and (r -> 'quest' ->> 'xp_reward')::int = 10
    and r -> 'quest' -> 'attribute_rewards' = '[{"name":"KNOWLEDGE","value":1}]'
    and (r -> 'player' ->> 'earned_xp')::int = 310);

  update public.quests set completed_at = completed_at - interval '1 day' where user_id = a;
  r := tests.finish(a, tests.personal(a));
  perform tests.check('the full rewards come back the next day', not (r -> 'quest' ->> 'is_bonus_reward')::boolean);

  m := tests.main(a, 'Learn Swift', 3);
  perform tests.act(a, format('public.start_quest(%L)', m));
  perform tests.check('a main quest with steps left can''t be completed',
    tests.error(a, format('public.complete_quest(%L)', m)) = 'not_allowed');
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, i))) from generate_series(0, 2) i;
  r := tests.act(a, format('public.complete_quest(%L)', m));
  perform tests.check('a main quest''s XP comes from its steps, not completion',
    (r -> 'player' ->> 'earned_xp')::int = 410 + 300);
  perform tests.check('a main quest still gives its attributes',
    (r -> 'player' -> 'attribute_gains' ->> 'KNOWLEDGE')::int = 5 * 4 + 1 + 2);
end;
$$;


-- Levels, cloaks and badges -------------------------------------------------------------

-- The same cases as scripts/rule-tests/rewards: a personal quest worth p_xp, then a hard
-- 3-step main quest with one step ticked (150 XP), then a personal quest worth nothing.
create function tests.level_setup(p_user uuid, p_xp int) returns uuid
language plpgsql as $$
declare
  first_quest uuid := tests.personal(p_user);
  m uuid := tests.main(p_user, 'Physics review', 3);
  last_quest uuid := tests.personal(p_user);
begin
  update public.quests set xp_reward = p_xp where id = first_quest;
  update public.quests set xp_reward = 0 where id = last_quest;
  perform tests.finish(p_user, first_quest);
  perform tests.act(p_user, format('public.start_quest(%L)', m));
  perform tests.act(p_user, format('public.set_step_done(%L, true)', tests.step(m, 0)));
  perform tests.finish(p_user, last_quest);
  return m;
end;
$$;

create function tests.player(p_user uuid) returns jsonb
language sql as $$
  select private.player_json(p_user)
$$;

do $$
declare
  a uuid;
  m uuid;
  r jsonb;
begin
  a := tests.new_user(); m := tests.level_setup(a, 1100);
  perform tests.check('level 3 reached by a step gives Midnight',
    (tests.player(a) ->> 'level')::int = 3 and tests.player(a) -> 'unlocked_cloaks' = '["Midnight"]');
  update public.profiles set cloak = 'Midnight' where id = a;
  perform tests.act(a, format('public.delete_quest(%L)', m));
  perform tests.check('deleting the main quest drops the level', (tests.player(a) ->> 'level')::int = 2);
  perform tests.check('deleting takes the cloak back', tests.player(a) -> 'unlocked_cloaks' = '[]');
  perform tests.check('a cloak taken back is taken off', (select cloak from public.profiles where id = a) is null);

  a := tests.new_user(); m := tests.level_setup(a, 1100);
  perform tests.act(a, format('public.set_step_done(%L, false)', tests.step(m, 0)));
  perform tests.check('unticking takes the cloak back',
    (tests.player(a) ->> 'level')::int = 2 and tests.player(a) -> 'unlocked_cloaks' = '[]');

  a := tests.new_user(); m := tests.level_setup(a, 400);
  perform tests.check('level 2 badge earned by a step', tests.player(a) -> 'earned_achievements' ? 'levelTwo');
  perform tests.act(a, format('public.delete_quest(%L)', m));
  perform tests.check('deleting takes the level 2 badge back', not tests.player(a) -> 'earned_achievements' ? 'levelTwo');
  perform tests.check('first quest badge stays', tests.player(a) -> 'earned_achievements' ? 'firstQuest');

  a := tests.new_user(); m := tests.level_setup(a, 1400);
  perform tests.act(a, format('public.delete_quest(%L)', m));
  perform tests.check('cloak stays when the level holds',
    (tests.player(a) ->> 'level')::int = 3 and tests.player(a) -> 'unlocked_cloaks' = '["Midnight"]');

  a := tests.new_user(); m := tests.level_setup(a, 1100);
  perform tests.act(a, format('public.delete_quest(%L)', m));
  m := tests.personal(a);
  update public.quests set xp_reward = 100 where id = m;
  r := tests.finish(a, m);
  perform tests.check('level is announced again when re-earned',
    (r -> 'reward' ->> 'level_before')::int = 2 and (r -> 'reward' ->> 'level_after')::int = 3
    and r -> 'reward' -> 'new_cloaks' = '["Midnight"]');

  a := tests.new_user();
  m := tests.personal(a);
  update public.quests set xp_reward = 7700 where id = m;
  r := tests.finish(a, m);
  perform tests.check('reaching level 8 at once gives all three cloaks in order',
    (r -> 'reward' ->> 'level_after')::int = 8
    and r -> 'reward' -> 'new_cloaks' = '["Midnight", "Oxblood", "Plum"]');
  perform tests.check('level 5 gives the Master badge', r -> 'player' -> 'earned_achievements' ? 'master');
end;
$$;

do $$
declare
  a uuid := tests.new_user();
  q uuid;
  r jsonb;
begin
  perform tests.finish(a, tests.personal(a));
  update public.quests set completed_at = completed_at - interval '2 days' where user_id = a;
  perform tests.finish(a, tests.personal(a));
  r := tests.player(a);
  perform tests.check('two days isn''t consistency yet', not r -> 'earned_achievements' ? 'consistency');
  update public.quests set completed_at = completed_at - interval '1 day'
  where user_id = a and completed_at > now() - interval '1 hour';
  r := tests.finish(a, tests.personal(a));
  perform tests.check('quests on 3 different days earn Consistency', r -> 'player' -> 'earned_achievements' ? 'consistency');

  -- 10 + 15 = 25 Knowledge from a 2h+ learning quest
  q := tests.act(a, 'public.create_quest(''personal'', ''Read'', null, ''Learning'', 120)') -> 'quest' ->> 'id';
  r := tests.finish(a, q);
  perform tests.check('25 Knowledge earns Scholar', r -> 'player' -> 'earned_achievements' ? 'scholar');
  perform tests.check('Builder needs 25 Problem Solving', not r -> 'player' -> 'earned_achievements' ? 'builder');
end;
$$;

-- Days are counted at the user's own midnight ------------------------------------------

do $$
declare
  manila uuid := tests.new_user('Asia/Manila');
  local_midnight timestamptz := date_trunc('day', now() at time zone 'Asia/Manila') at time zone 'Asia/Manila';
  r jsonb;
begin
  perform tests.finish(manila, tests.personal(manila));
  perform tests.finish(manila, tests.personal(manila));
  perform tests.finish(manila, tests.personal(manila));

  update public.quests set completed_at = local_midnight - interval '1 minute' where user_id = manila;
  r := tests.finish(manila, tests.personal(manila));
  perform tests.check('a minute before local midnight is yesterday', not (r -> 'quest' ->> 'is_bonus_reward')::boolean);

  update public.quests set completed_at = local_midnight where user_id = manila;
  r := tests.finish(manila, tests.personal(manila));
  perform tests.check('local midnight is today', (r -> 'quest' ->> 'is_bonus_reward')::boolean);
end;
$$;

-- Delete ------------------------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  m uuid := tests.main(a, 'Learn Swift', 3);
  p uuid := tests.personal(a);
  r jsonb;
begin
  perform tests.act(a, format('public.start_quest(%L)', m));
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 0)));
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 1)));
  perform tests.act(a, format('public.abandon_quest(%L)', m));
  perform tests.check('an abandoned main quest keeps its steps and XP',
    tests.xp(a) = 200 and (select count(*) from public.quest_steps where quest_id = m and done_at is not null) = 2);
  r := tests.act(a, format('public.delete_quest(%L)', m));
  perform tests.check('deleting a main quest takes its step XP',
    (r -> 'player' ->> 'earned_xp')::int = 0 and r -> 'quest' = 'null'::jsonb);
  perform tests.check('its steps go with it', not exists (select 1 from public.quest_steps where quest_id = m));
  perform tests.check('then a new main quest can be created', tests.main(a) is not null);
  perform tests.act(a, format('public.delete_quest(%L)', p));
  perform tests.check('a personal quest can be deleted', not exists (select 1 from public.quests where id = p));
end;
$$;

-- Daily quests ------------------------------------------------------------------------

create function tests.daily(p_user uuid, p_kind text, p_title text default 'Build a small mechanic',
  p_icon text default 'iconQuestGamepad') returns jsonb
language sql as $$
  select tests.act(p_user, format('public.%s_daily_quest(%L, %L, %L, %L, %L)', p_kind, p_title,
    'Turn a simple idea into a working feature.', 'Decide your approach first, then follow your plan.',
    p_icon, 'Development'))
$$;

do $$
declare
  a uuid := tests.new_user('Asia/Manila');
  r jsonb;
  d uuid;
begin
  r := tests.daily(a, 'refresh');
  d := r -> 'quest' ->> 'id';
  perform tests.check('the daily quest''s rewards are set by the server',
    r -> 'quest' ->> 'title' = 'BUILD A SMALL MECHANIC' and r -> 'quest' ->> 'difficulty' = 'MODERATE'
    and (r -> 'quest' ->> 'duration_minutes')::int = 30 and (r -> 'quest' ->> 'xp_reward')::int = 100
    and r -> 'quest' -> 'attribute_rewards' = '[{"name":"PROBLEM SOLVING","value":5},{"name":"KNOWLEDGE","value":2}]');
  perform tests.check('it''s dated with the user''s own day',
    (r -> 'quest' ->> 'generated_on')::date = (now() at time zone 'Asia/Manila')::date);
  perform tests.check('one daily quest a day', tests.daily(a, 'refresh', 'Another') -> 'quest' = 'null'::jsonb);
  perform tests.check('a daily quest can''t be deleted',
    tests.error(a, format('public.delete_quest(%L)', d)) = 'not_allowed');
  perform tests.check('the icon must be an asset name',
    tests.error(a, 'public.renew_daily_quest(''T'', null, null, ''../x'', ''Other'')') = 'invalid_input');

  r := tests.daily(a, 'renew', 'Map your next month', 'iconSparklesSmall');
  perform tests.check('a new identity swaps an untouched daily quest',
    r -> 'quest' ->> 'title' = 'MAP YOUR NEXT MONTH' and not exists (select 1 from public.quests where id = d));
  d := r -> 'quest' ->> 'id';

  perform tests.act(a, format('public.start_quest(%L)', d));
  perform tests.check('a started daily quest isn''t swapped', tests.daily(a, 'renew', 'Other') -> 'quest' = 'null'::jsonb);
  update public.quests set generated_on = generated_on - 1 where id = d;
  perform tests.check('a started daily quest stays into the next day',
    tests.daily(a, 'refresh', 'Other') -> 'quest' = 'null'::jsonb);

  update public.quests set generated_on = generated_on + 1 where id = d;
  update public.quests set started_at = started_at - interval '1 hour' where id = d;
  perform tests.act(a, format('public.complete_quest(%L)', d));
  perform tests.check('a daily quest finished today isn''t swapped',
    tests.daily(a, 'renew', 'Other') -> 'quest' = 'null'::jsonb);

  update public.quests set generated_on = generated_on - 2, completed_at = completed_at - interval '2 days' where id = d;
  r := tests.daily(a, 'refresh', 'Find your bottleneck');
  perform tests.check('the next day brings a new one and keeps the finished one',
    r -> 'quest' ->> 'title' = 'FIND YOUR BOTTLENECK' and exists (select 1 from public.quests where id = d));

  update public.quests set generated_on = generated_on - 1 where id = (r -> 'quest' ->> 'id')::uuid;
  r := tests.daily(a, 'refresh', 'Review your week');
  perform tests.check('an untouched daily from yesterday is replaced',
    r -> 'quest' ->> 'title' = 'REVIEW YOUR WEEK'
    and (select count(*) from public.quests where user_id = a and type = 'daily' and status = 'AVAILABLE') = 1);
end;
$$;

-- Reset and Journey -------------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  q uuid := tests.personal(a);
  r jsonb;
begin
  update public.quests set xp_reward = 1200 where id = q;
  perform tests.finish(a, q);
  update public.profiles set cloak = 'Midnight' where id = a;
  perform tests.act(a, 'public.mark_journey_seen(4)');

  r := tests.act(a, 'public.reset_progress()');
  perform tests.check('reset clears XP, attributes, cloaks and badges',
    (r -> 'player' ->> 'earned_xp')::int = 0 and (r -> 'player' ->> 'level')::int = 1
    and (r -> 'player' -> 'attribute_gains' ->> 'KNOWLEDGE')::int = 0
    and r -> 'player' -> 'unlocked_cloaks' = '[]' and r -> 'player' -> 'earned_achievements' = '[]'
    and (r -> 'player' ->> 'announced_level')::int = 1 and (r -> 'player' ->> 'seen_lit_star_count')::int = 0);
  perform tests.check('reset clears the quests', not exists (select 1 from public.quests where user_id = a));
  perform tests.check('reset takes the cloak off and keeps the identity',
    (select cloak is null and name = 'Lou' and archetype = 'Strategist' from public.profiles where id = a));

  r := tests.act(a, 'public.mark_journey_seen(7)');
  perform tests.check('Journey stars seen are saved', (r -> 'player' ->> 'seen_lit_star_count')::int = 7);
  r := tests.act(a, 'public.mark_journey_seen(-3)');
  perform tests.check('Journey stars seen can''t go below 0', (r -> 'player' ->> 'seen_lit_star_count')::int = 0);
end;
$$;

-- Loading an account ------------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  b uuid := tests.new_user();
  m uuid := tests.main(a, 'Learn Swift', 3);
  p uuid := tests.personal(a);
  r jsonb;
begin
  perform tests.act(a, format('public.start_quest(%L)', m));
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 1)));
  perform tests.personal(b);
  -- Everything in this block shares one clock reading, unlike the app's separate requests
  update public.quests set created_at = now() - interval '1 hour' where id = m;

  r := tests.act(a, 'public.get_player_state(''Asia/Manila'')');
  perform tests.check('loading returns only the user''s own quests, oldest first',
    jsonb_array_length(r -> 'quests') = 2 and (r -> 'quests' -> 0 ->> 'id')::uuid = m
    and (r -> 'quests' -> 1 ->> 'id')::uuid = p);
  perform tests.check('loading includes the steps in order with their tick times',
    r -> 'quests' -> 0 -> 'steps' -> 0 ->> 'title' = 'Step 1'
    and r -> 'quests' -> 0 -> 'steps' -> 0 -> 'done_at' = 'null'::jsonb
    and abs((r -> 'quests' -> 0 -> 'steps' -> 1 ->> 'done_at')::float - extract(epoch from now())) < 5);
  perform tests.check('loading includes the player', (r -> 'player' ->> 'earned_xp')::int = 100);
  perform tests.check('loading saves the phone''s time zone',
    (select time_zone from public.profiles where id = a) = 'Asia/Manila');
  perform tests.act(a, 'public.get_player_state(''Mars/Olympus'')');
  perform tests.check('an unknown time zone is ignored',
    (select time_zone from public.profiles where id = a) = 'Asia/Manila');
  perform tests.check('loading needs a signed-in user',
    tests.error(null, 'public.get_player_state()') = 'not_signed_in'
    and tests.error(null, 'public.get_player_state()', 'anon') like 'permission denied%');
end;
$$;

-- Profile photos and limits ----------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  b uuid := tests.new_user();
  v text;
  n int;
begin
  perform set_config('request.jwt.claim.sub', a::text, false);
  set role authenticated;

  insert into storage.objects (bucket_id, name) values ('avatars', a || '/avatar.jpg');
  begin
    insert into storage.objects (bucket_id, name) values ('avatars', b || '/avatar.jpg');
    v := 'other folder allowed';
  exception when others then v := 'other folder refused';
  end;
  begin
    insert into storage.objects (bucket_id, name) values ('avatars', a || '/extra.jpg');
    v := v || ', other name allowed';
  exception when others then v := v || ', other name refused';
  end;
  update public.profiles set photo_path = a || '/avatar.jpg' where id = a;
  begin
    update public.profiles set photo_path = b || '/avatar.jpg' where id = a;
    v := v || ', other photo allowed';
  exception when others then v := v || ', other photo refused';
  end;
  begin
    update public.profiles set name = repeat('x', 101) where id = a;
    v := v || ', long name allowed';
  exception when others then v := v || ', long name refused';
  end;

  perform set_config('request.jwt.claim.sub', b::text, false);
  select count(*) into n from storage.objects where bucket_id = 'avatars';
  delete from storage.objects where name = a || '/avatar.jpg';
  reset role;

  perform tests.check('a photo can be saved in the user''s own folder',
    exists (select 1 from storage.objects where name = a || '/avatar.jpg'));
  perform tests.check('a photo can''t be saved in another user''s folder', v like 'other folder refused%');
  perform tests.check('each user has one photo, at avatar.jpg', v like '%other name refused%');
  perform tests.check('the profile points at its own photo',
    (select photo_path from public.profiles where id = a) = a || '/avatar.jpg');
  perform tests.check('a profile can''t point at another user''s photo', v like '%other photo refused%');
  perform tests.check('names are at most 100 characters', v like '%long name refused%');
  perform tests.check('another user can''t see the photo', n = 0);
  perform tests.check('another user can''t delete the photo',
    exists (select 1 from storage.objects where name = a || '/avatar.jpg'));
  perform tests.check('the photo bucket is private and takes JPEGs up to 2 MB',
    (select not public and file_size_limit = 2097152 and allowed_mime_types = array['image/jpeg']
     from storage.buckets where id = 'avatars'));
end;
$$;

-- Store: Embers and buying ----------------------------------------------------------

create function tests.embers(p_user uuid) returns int
language sql as $$
  select (private.player_json(p_user) ->> 'embers')::int
$$;

do $$
declare
  a uuid := tests.new_user();
  m uuid;
  r jsonb;
begin
  r := tests.finish(a, tests.personal(a, 'Read a book', 30));
  perform tests.check('a 100 XP quest pays 10 Embers',
    (r -> 'reward' ->> 'embers_earned')::int = 10 and (r -> 'player' ->> 'embers')::int = 10);

  m := tests.main(a, 'Learn Swift', 3);
  perform tests.act(a, format('public.start_quest(%L)', m));
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, i))) from generate_series(0, 2) i;
  perform tests.check('ticking steps pays no Embers', tests.embers(a) = 10);
  r := tests.act(a, format('public.complete_quest(%L)', m));
  perform tests.check('a main quest pays Embers for its full XP when completed',
    (r -> 'reward' ->> 'embers_earned')::int = 30 and tests.embers(a) = 40);
end;
$$;

do $$
declare
  a uuid := tests.new_user();
  r jsonb;
begin
  perform tests.finish(a, tests.personal(a));
  perform tests.finish(a, tests.personal(a));
  perform tests.finish(a, tests.personal(a));
  r := tests.finish(a, tests.personal(a));
  perform tests.check('a bonus quest pays exactly 1 Ember',
    (r -> 'reward' ->> 'embers_earned')::int = 1 and tests.embers(a) = 31);
end;
$$;

do $$
declare
  a uuid := tests.new_user();
  m uuid;
  r jsonb;
begin
  update public.player_progress set embers = 199 where user_id = a;
  perform tests.check('199 Embers can''t buy a 200 cloak',
    tests.error(a, 'public.buy_cloak(''Green'')') = 'not_enough_embers'
    and tests.embers(a) = 199 and not tests.player(a) -> 'owned_cloaks' ? 'Green');

  update public.player_progress set embers = 200 where user_id = a;
  r := tests.act(a, 'public.buy_cloak(''Green'')');
  perform tests.check('exactly 200 Embers buys a cloak and leaves 0',
    (r -> 'player' ->> 'embers')::int = 0 and r -> 'player' -> 'owned_cloaks' ? 'Green');
  perform tests.check('a bought cloak isn''t listed as a level cloak',
    not r -> 'player' -> 'unlocked_cloaks' ? 'Green');

  update public.player_progress set embers = 500 where user_id = a;
  perform tests.check('a cloak already owned can''t be bought again',
    tests.error(a, 'public.buy_cloak(''Green'')') = 'not_allowed' and tests.embers(a) = 500);
  perform tests.check('level cloaks aren''t for sale',
    tests.error(a, 'public.buy_cloak(''Midnight'')') = 'not_found' and tests.embers(a) = 500);
  perform tests.check('unknown items aren''t for sale',
    tests.error(a, 'public.buy_cloak(''Rainbow'')') = 'not_found');

  perform set_config('request.jwt.claim.sub', a::text, false);
  set role authenticated;
  update public.profiles set cloak = 'Green' where id = a;
  reset role;
  perform tests.check('a bought cloak can be worn', (select cloak from public.profiles where id = a) = 'Green');

  -- Ticking a step then deleting the quest drops XP, which takes back level rewards
  m := tests.main(a, 'Learn Swift', 3);
  perform tests.act(a, format('public.start_quest(%L)', m));
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 0)));
  perform tests.act(a, format('public.delete_quest(%L)', m));
  perform tests.check('a bought cloak stays owned and worn when XP drops',
    tests.player(a) -> 'owned_cloaks' ? 'Green' and (select cloak from public.profiles where id = a) = 'Green');

  r := tests.act(a, 'public.reset_progress()');
  perform tests.check('reset clears Embers and bought cloaks, and takes the cloak off',
    (r -> 'player' ->> 'embers')::int = 0 and r -> 'player' -> 'owned_cloaks' = '[]'
    and (select cloak from public.profiles where id = a) is null);

  r := tests.act(a, 'public.get_player_state()');
  perform tests.check('the store lists four cloaks at 200 Embers, in order',
    r -> 'store' = '[{"item":"Green","price":200},{"item":"Yellow","price":200},{"item":"Snow","price":200},{"item":"Teal","price":200}]');
  perform tests.check('signed-out visitors can''t buy',
    tests.error(null, 'public.buy_cloak(''Green'')', 'anon') like 'permission denied%'
    and tests.error(null, 'public.buy_cloak(''Green'')') = 'not_signed_in');
end;
$$;

-- Editing quests ---------------------------------------------------------------------

do $$
declare
  a uuid := tests.new_user();
  b uuid := tests.new_user();
  p uuid := tests.personal(a, 'Read a book', 30);
  m uuid := tests.main(a, 'Learn Swift', 3);
  r jsonb;
begin
  r := tests.act(a, format('public.update_quest(%L, %L, %L, %L, 60)', p, 'Read two books', 'Slowly', 'Creative'));
  perform tests.check('an untouched quest can be fully edited, and its rewards are worked out again',
    r -> 'quest' ->> 'title' = 'READ TWO BOOKS' and r -> 'quest' ->> 'description' = 'Slowly'
    and r -> 'quest' ->> 'category' = 'CREATIVE' and (r -> 'quest' ->> 'duration_minutes')::int = 60
    and (r -> 'quest' ->> 'xp_reward')::int = 200
    and r -> 'quest' -> 'attribute_rewards' = '[{"name":"CREATIVITY","value":10}]');

  r := tests.act(a, format('public.update_quest(%L, %L, null, %L, null, %L::text[])', m, 'Learn Swift', 'Development',
    array['One', 'Two', 'Three', 'Four']));
  perform tests.check('an untouched main quest''s steps are replaced',
    (r -> 'quest' ->> 'xp_reward')::int = 400 and jsonb_array_length(r -> 'quest' -> 'steps') = 4
    and r -> 'quest' -> 'steps' -> 3 ->> 'title' = 'Four');

  perform tests.act(a, format('public.start_quest(%L)', p));
  r := tests.act(a, format('public.update_quest(%L, %L, %L, %L, 120)', p, 'Physics exam', 'New words', 'Learning'));
  perform tests.check('a started quest only changes its title and description',
    r -> 'quest' ->> 'title' = 'PHYSICS EXAM' and r -> 'quest' ->> 'description' = 'New words'
    and r -> 'quest' ->> 'difficulty' = 'MODERATE' and (r -> 'quest' ->> 'duration_minutes')::int = 60
    and r -> 'quest' ->> 'category' = 'CREATIVE' and (r -> 'quest' ->> 'xp_reward')::int = 200);

  perform tests.act(a, format('public.start_quest(%L)', m));
  perform tests.act(a, format('public.set_step_done(%L, true)', tests.step(m, 0)));
  r := tests.act(a, format('public.update_quest(%L, %L, null, %L, null, %L::text[])', m, 'Learn SwiftUI', 'Development',
    array['A', 'B', 'C']));
  perform tests.check('a main quest with a ticked step keeps its steps',
    r -> 'quest' ->> 'title' = 'LEARN SWIFTUI' and r -> 'quest' -> 'steps' -> 0 ->> 'title' = 'One'
    and r -> 'quest' -> 'steps' -> 0 ->> 'done_at' is not null and jsonb_array_length(r -> 'quest' -> 'steps') = 4);

  perform tests.check('the title still can''t be blank when editing',
    tests.error(a, format('public.update_quest(%L, %L, null, %L, 60)', p, '  ', 'Learning')) = 'invalid_input');
  perform tests.check('another user''s quest can''t be edited',
    tests.error(b, format('public.update_quest(%L, %L, null, %L, 60)', p, 'Mine now', 'Learning')) = 'not_found');
  perform tests.check('signed-out visitors can''t edit',
    tests.error(null, format('public.update_quest(%L, %L, null, %L, 60)', p, 'X', 'Learning'), 'anon') like 'permission denied%');

  update public.quests set started_at = started_at - interval '2 hours' where id = p;
  perform tests.act(a, format('public.complete_quest(%L)', p));
  perform tests.check('a completed quest can''t be edited',
    tests.error(a, format('public.update_quest(%L, %L, null, %L, 30)', p, 'X', 'Other')) = 'not_allowed');
  r := tests.daily(a, 'refresh');
  perform tests.check('a daily quest can''t be edited',
    tests.error(a, format('public.update_quest(%L, %L, null, %L, 30)', r -> 'quest' ->> 'id', 'X', 'Other')) = 'not_allowed');
end;
$$;

-- Result ------------------------------------------------------------------------------

do $$
declare
  v_failed int := (select count(*) from tests.results where not ok);
  v_total int := (select count(*) from tests.results);
begin
  if v_failed > 0 then
    raise exception '% of % checks FAILED', v_failed, v_total;
  end if;
  raise warning 'ALL % CHECKS PASSED', v_total;
end;
$$;
