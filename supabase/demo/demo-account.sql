-- Fills one account with everything unlocked, for demos.
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
--   - one quest in progress with steps, and two waiting to start
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
  v_icons text[] := array['iconQuestHammer', 'iconQuestBook', 'iconQuestAtom', 'iconQuestGamepad'];
  v_difficulties text[] := array['EASY', 'MODERATE', 'MODERATE', 'HARD'];
  v_xp integer[] := array[50, 100, 100, 150];
  v_minutes integer[] := array[15, 30, 45, 60];
  v_category text;
  v_attribute text;
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
    v_attribute := case v_category
      when 'development' then 'PROBLEM SOLVING'
      when 'learning' then 'KNOWLEDGE'
      when 'creative' then 'CREATIVITY'
      else 'DISCIPLINE'
    end;
    v_day := now() - make_interval(days => i, hours => i % 5);
    insert into public.quests (
      user_id, type, title, description, icon_name, category, difficulty,
      duration_minutes, xp_reward, attribute_rewards, status,
      started_at, completed_at, created_at
    ) values (
      v_user, 'personal', v_titles[k], 'One small step, done.',
      v_icons[1 + i % 4], v_category, v_difficulties[1 + i % 4],
      v_minutes[1 + i % 4], v_xp[1 + i % 4],
      jsonb_build_array(jsonb_build_object('name', v_attribute, 'value', 5)),
      'COMPLETED',
      v_day - make_interval(mins => v_minutes[1 + i % 4]), v_day,
      v_day - interval '2 hours'
    );
  end loop;

  -- One quest in progress, with its steps, to show Quest Details live
  insert into public.quests (
    user_id, type, title, description, icon_name, category, difficulty,
    duration_minutes, xp_reward, attribute_rewards, status, started_at
  ) values (
    v_user, 'personal', 'Build the boss fight', 'Make the first boss fight playable.',
    'iconQuestGamepad', 'development', 'HARD', 60, 150,
    '[{"name": "PROBLEM SOLVING", "value": 8}, {"name": "KNOWLEDGE", "value": 3}]'::jsonb,
    'ACTIVE', now() - interval '20 minutes'
  ) returning id into v_quest;

  insert into public.quest_steps (quest_id, user_id, position, title, done_at) values
    (v_quest, v_user, 0, 'Sketch the attack pattern', now() - interval '15 minutes'),
    (v_quest, v_user, 1, 'Code the first attack', null),
    (v_quest, v_user, 2, 'Playtest and tune', null);

  -- Two waiting to start
  insert into public.quests (
    user_id, type, title, description, icon_name, category, difficulty,
    duration_minutes, xp_reward, attribute_rewards, status
  ) values
    (v_user, 'personal', 'Read about juicy feedback', 'Find three ideas to try.',
     'iconQuestBook', 'learning', 'EASY', 20, 50,
     '[{"name": "KNOWLEDGE", "value": 2}, {"name": "DISCIPLINE", "value": 1}]'::jsonb, 'AVAILABLE'),
    (v_user, 'personal', 'Design the title screen', 'Make the first screen players see.',
     'iconQuestAtom', 'creative', 'MODERATE', 45, 100,
     '[{"name": "CREATIVITY", "value": 5}]'::jsonb, 'AVAILABLE');

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
