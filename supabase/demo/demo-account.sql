-- Fills one account with everything unlocked, for demos.
--
-- 1. In the app, sign up with the demo email and finish onboarding.
-- 2. Put that email on the line marked "change this" below.
-- 3. In Supabase, open the ASPHYR project (never Synapse) → SQL Editor →
--    New query, paste this whole file and click Run.
--
-- What it does, for that account only:
--   - 100 finished quests, one a day for the last 100 days, so all five
--     Journey chapters are lit and the streak is long
--   - 10,000 XP (level 9), 40 in every attribute, 1,000 Embers
--   - every cloak and every achievement
-- Safe to run again: it replaces the account's quests each time.
-- It doesn't change the name, color, aspiration or archetype.

do $$
declare
  v_email text := 'demo@example.com';  -- change this
  v_user uuid;
  v_icons text[] := array['iconQuestBook', 'iconQuestHammer', 'iconQuestAtom', 'iconQuestGamepad'];
  v_attributes text[] := array['KNOWLEDGE', 'DISCIPLINE', 'CREATIVITY', 'PROBLEM SOLVING'];
  v_day timestamptz;
  i integer;
begin
  select id into v_user from auth.users where lower(email) = lower(v_email);
  if v_user is null then
    raise exception 'No account uses %. Sign up in the app first.', v_email;
  end if;

  delete from public.quests where user_id = v_user;

  for i in 1..100 loop
    v_day := now() - make_interval(days => i);
    insert into public.quests (
      user_id, type, title, description, icon_name, category, difficulty,
      duration_minutes, xp_reward, attribute_rewards, status,
      started_at, completed_at, created_at
    ) values (
      v_user, 'personal', 'Practice session ' || (101 - i),
      'A finished quest for the demo.',
      v_icons[1 + i % 4], 'Practice', 'MODERATE', 30, 100,
      jsonb_build_array(jsonb_build_object('name', v_attributes[1 + i % 4], 'value', 2)),
      'COMPLETED', v_day - interval '35 minutes', v_day, v_day - interval '1 hour'
    );
  end loop;

  update public.player_progress set
    earned_xp = 10000,
    knowledge_gain = 30,
    discipline_gain = 30,
    creativity_gain = 30,
    problem_solving_gain = 30,
    -- Already "seen", so the app doesn't replay every level and star
    announced_level = 9,
    seen_lit_star_count = 100,
    embers = 1000,
    updated_at = now()
  where user_id = v_user;

  insert into public.unlocked_cloaks (user_id, cloak)
  select v_user, c from unnest(array['Midnight', 'Oxblood', 'Plum', 'Green', 'Yellow', 'Snow', 'Teal']) as c
  on conflict do nothing;

  insert into public.earned_achievements (user_id, achievement)
  select v_user, a from unnest(array['firstQuest', 'levelTwo', 'consistency', 'scholar', 'builder', 'master']) as a
  on conflict do nothing;
end $$;
