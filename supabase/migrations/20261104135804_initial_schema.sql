-- ASPHYR's tables. See docs/BACKEND-SPEC.md.
-- People can read their own rows. Only `profiles` can be written from the app:
-- everything that earns rewards goes through server functions, added in a later step.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null default '',
  color text not null default 'Green'
    check (color in ('Green', 'Oxblood', 'Yellow', 'Snow', 'Midnight', 'Plum')),
  aspiration text,
  archetype text check (archetype in ('Strategist', 'Scholar', 'Creator', 'Explorer')),
  cloak text check (cloak in ('Midnight', 'Oxblood', 'Plum', 'Green', 'Yellow', 'Snow', 'Teal')),
  photo_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.player_progress (
  user_id uuid primary key references auth.users (id) on delete cascade,
  earned_xp integer not null default 0 check (earned_xp >= 0),
  knowledge_gain integer not null default 0 check (knowledge_gain >= 0),
  discipline_gain integer not null default 0 check (discipline_gain >= 0),
  creativity_gain integer not null default 0 check (creativity_gain >= 0),
  problem_solving_gain integer not null default 0 check (problem_solving_gain >= 0),
  announced_level integer not null default 1 check (announced_level >= 1),
  seen_lit_star_count integer not null default 0 check (seen_lit_star_count >= 0),
  updated_at timestamptz not null default now()
);

create table public.quests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null check (type in ('main', 'daily', 'personal')),
  title text not null check (char_length(title) between 1 and 200),
  description text,
  objective text,
  icon_name text not null,
  category text,
  difficulty text check (difficulty in ('EASY', 'MODERATE', 'HARD')),
  duration_minutes integer check (duration_minutes > 0),
  xp_reward integer not null default 0 check (xp_reward >= 0),
  attribute_rewards jsonb not null default '[]'::jsonb,
  status text not null default 'AVAILABLE' check (status in ('AVAILABLE', 'ACTIVE', 'COMPLETED')),
  generated_on date,
  started_at timestamptz,
  paused_at timestamptz,
  paused_duration double precision not null default 0 check (paused_duration >= 0),
  completed_at timestamptz,
  is_bonus_reward boolean not null default false,
  created_at timestamptz not null default now()
);

create index quests_user_id_idx on public.quests (user_id);

-- The app's limits, enforced by the database as well as the server functions
create unique index quests_one_open_main_idx on public.quests (user_id)
  where type = 'main' and status <> 'COMPLETED';
create unique index quests_one_active_other_idx on public.quests (user_id)
  where type <> 'main' and status = 'ACTIVE';
create unique index quests_one_daily_a_day_idx on public.quests (user_id, generated_on)
  where type = 'daily';

create table public.quest_steps (
  id uuid primary key default gen_random_uuid(),
  quest_id uuid not null references public.quests (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  position integer not null check (position >= 0),
  title text not null check (char_length(title) between 1 and 200),
  done_at timestamptz,
  unique (quest_id, position)
);

create index quest_steps_user_id_idx on public.quest_steps (user_id);

create table public.unlocked_cloaks (
  user_id uuid not null references auth.users (id) on delete cascade,
  cloak text not null check (cloak in ('Midnight', 'Oxblood', 'Plum', 'Green', 'Yellow', 'Snow', 'Teal')),
  unlocked_at timestamptz not null default now(),
  primary key (user_id, cloak)
);

create table public.earned_achievements (
  user_id uuid not null references auth.users (id) on delete cascade,
  achievement text not null
    check (achievement in ('firstQuest', 'levelTwo', 'consistency', 'scholar', 'builder', 'master')),
  earned_at timestamptz not null default now(),
  primary key (user_id, achievement)
);

-- Every new login gets a profile and starting progress
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id);
  insert into public.player_progress (user_id) values (new.id);
  return new;
end;
$$;

revoke all on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- A cloak can only be worn once it's unlocked, and the profile's owner stays fixed
create function public.check_profile_update()
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

  new.updated_at := now();
  return new;
end;
$$;

revoke all on function public.check_profile_update() from public, anon, authenticated;

create trigger profiles_check_update
  before update on public.profiles
  for each row execute function public.check_profile_update();

-- Security: nothing is open to people who aren't signed in
alter table public.profiles enable row level security;
alter table public.player_progress enable row level security;
alter table public.quests enable row level security;
alter table public.quest_steps enable row level security;
alter table public.unlocked_cloaks enable row level security;
alter table public.earned_achievements enable row level security;

revoke all on public.profiles, public.player_progress, public.quests, public.quest_steps,
  public.unlocked_cloaks, public.earned_achievements from anon, authenticated;

grant select on public.profiles, public.player_progress, public.quests, public.quest_steps,
  public.unlocked_cloaks, public.earned_achievements to authenticated;
grant update (name, color, aspiration, archetype, cloak, photo_path) on public.profiles to authenticated;

create policy "Read own profile" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
create policy "Update own profile" on public.profiles
  for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "Read own progress" on public.player_progress
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "Read own quests" on public.quests
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "Read own steps" on public.quest_steps
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "Read own cloaks" on public.unlocked_cloaks
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "Read own badges" on public.earned_achievements
  for select to authenticated using ((select auth.uid()) = user_id);
