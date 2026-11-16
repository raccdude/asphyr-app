-- Fills one account with everything unlocked, for demos. Titles are stored in
-- capitals, as the server does for quests made in the app.
--
-- 1. In the app, sign up with the demo email and finish onboarding.
-- 2. Put that email on the line marked "change this" below.
-- 3. In Supabase, open the ASPHYR project (never Synapse) → SQL Editor →
--    New query, paste this whole file and click Run.
-- 4. Close the app fully and reopen it.
--
-- What it does, for that account only:
--   - 100 finished quests over the last 100 days, with real titles across
--     development, learning, creative, health and career, so the quest log,
--     every Journey chapter and a 100-day streak look lived in
--   - the main quest in progress with steps, and two personal quests waiting
--   - level 20 (43,700 XP), strong attributes and 2,500 Embers
--   - every cloak and every achievement
-- Safe to run again: it replaces the account's quests each time.
-- It doesn't change the name, color, aspiration or archetype.

do $$
declare
  v_email text := 'asphyr.demo@gmail.com';  -- change this
  v_user uuid;
  v_titles text[] := array[
    'Prototype a jump mechanic', 'Read a chapter on game design', 'Sketch three level layouts',
    'Run for 20 minutes', 'Fix the collision bug', 'Watch a talk on game feel',
    'Write a devlog post', 'Polish the main menu', 'Study pathfinding basics',
    'Plan the week''s goals', 'Record sound effects', 'Refactor the player script',
    'Stretch and walk outside', 'Playtest with a friend', 'Learn a new shader trick',
    'Update the portfolio page', 'Design an enemy', 'Read about level pacing',
    'Animate the idle pose', 'Tidy the project folders'
  ];
  v_categories text[] := array[
    'development', 'learning', 'creative', 'health', 'development', 'learning',
    'creative', 'development', 'learning', 'career', 'creative', 'development',
    'health', 'career', 'learning', 'career', 'creative', 'learning',
    'creative', 'career'
  ];
  -- The durations Create Quest offers
  v_minutes integer[] := array[15, 30, 60, 120];
  v_category text;
  v_difficulty text;
  v_duration integer;
  v_day timestamptz;
  v_quest uuid;
  i integer;
  k integer;
begin
  select id into v_user from auth.users where lower(email) = lower(v_email);
  if v_user is null then
    raise exception 'No account uses %. Sign up in the app first.', v_email;
  end if;

  delete from public.quests where user_id = v_user;

  -- 100 finished quests, one a day, the oldest first in the log
  for i in 1..100 loop
    k := 1 + (i - 1) % 20;
    v_category := v_categories[k];
    v_duration := v_minutes[1 + i % 4];
    v_difficulty := private.estimate_difficulty(v_titles[k], null);
    v_day := now() - make_interval(days => i, hours => i % 5);
    insert into public.quests (
      user_id, type, title, description, icon_name, category, difficulty,
      duration_minutes, xp_reward, attribute_rewards, status,
      started_at, completed_at, created_at
    ) values (
      v_user, 'personal', upper(v_titles[k]), null,
      'iconQuestHammer', v_category, v_difficulty, v_duration,
      private.timed_xp(v_duration, v_difficulty),
      private.quest_attributes(v_category, v_difficulty, v_duration),
      'COMPLETED',
      v_day - make_interval(mins => v_duration), v_day,
      v_day - interval '2 hours'
    );
  end loop;

  -- The main quest in progress, with 3 steps (main quests take 3 to 10 and no
  -- duration), to show Quest Details live
  v_difficulty := private.estimate_difficulty('Build the boss fight', 'Make the first boss fight playable.');
  insert into public.quests (
    user_id, type, title, description, icon_name, category, difficulty,
    duration_minutes, xp_reward, attribute_rewards, status, started_at
  ) values (
    v_user, 'main', 'BUILD THE BOSS FIGHT', 'Make the first boss fight playable.',
    'iconQuestBook', 'development', v_difficulty, null,
    private.xp_per_step(v_difficulty) * 3,
    private.quest_attributes('development', v_difficulty, null),
    'ACTIVE', now() - interval '20 minutes'
  ) returning id into v_quest;

  insert into public.quest_steps (quest_id, user_id, position, title, done_at) values
    (v_quest, v_user, 0, 'Sketch the attack pattern', now() - interval '15 minutes'),
    (v_quest, v_user, 1, 'Code the first attack', null),
    (v_quest, v_user, 2, 'Playtest and tune', null);

  -- Two personal quests waiting to start: a duration and no steps
  insert into public.quests (
    user_id, type, title, description, icon_name, category, difficulty,
    duration_minutes, xp_reward, attribute_rewards, status
  )
  select v_user, 'personal', upper(q.title), q.description, 'iconQuestHammer', q.category, d.difficulty,
    q.minutes, private.timed_xp(q.minutes, d.difficulty),
    private.quest_attributes(q.category, d.difficulty, q.minutes), 'AVAILABLE'
  from (values
    ('Read about juicy feedback', 'Find three ideas to try.', 'learning', 30),
    ('Design the title screen', 'Make the first screen players see.', 'creative', 60)
  ) as q(title, description, category, minutes)
  cross join lateral (
    select private.estimate_difficulty(q.title, q.description) as difficulty
  ) d;

  update public.player_progress set
    earned_xp = 43700,
    knowledge_gain = 52,
    discipline_gain = 44,
    creativity_gain = 47,
    problem_solving_gain = 61,
    -- Already "seen", so the app doesn't replay every level and star
    announced_level = 20,
    seen_lit_star_count = 100,
    embers = 2500,
    updated_at = now()
  where user_id = v_user;

  insert into public.unlocked_cloaks (user_id, cloak)
  select v_user, c from unnest(array['Midnight', 'Oxblood', 'Plum', 'Green', 'Yellow', 'Snow', 'Teal']) as c
  on conflict do nothing;

  insert into public.earned_achievements (user_id, achievement)
  select v_user, a from unnest(array['firstQuest', 'levelTwo', 'consistency', 'scholar', 'builder', 'master']) as a
  on conflict do nothing;
end $$;
