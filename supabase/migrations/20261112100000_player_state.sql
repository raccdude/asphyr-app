-- Backend step 4b: what the app needs to load an account's quests and progress.
-- Times in replies are seconds since 1970, which the app decodes without a date format.

create or replace function private.epoch(p_time timestamptz)
returns double precision
language sql
immutable
set search_path = ''
as $$
  select extract(epoch from p_time)::double precision
$$;

create or replace function private.quest_json(p_quest uuid)
returns jsonb
language sql
stable
set search_path = ''
as $$
  select jsonb_build_object(
    'id', q.id,
    'type', q.type,
    'title', q.title,
    'description', q.description,
    'objective', q.objective,
    'icon_name', q.icon_name,
    'category', q.category,
    'difficulty', q.difficulty,
    'duration_minutes', q.duration_minutes,
    'xp_reward', q.xp_reward,
    'attribute_rewards', q.attribute_rewards,
    'status', q.status,
    'generated_on', q.generated_on,
    'started_at', private.epoch(q.started_at),
    'paused_at', private.epoch(q.paused_at),
    'paused_duration', q.paused_duration,
    'completed_at', private.epoch(q.completed_at),
    'is_bonus_reward', q.is_bonus_reward,
    'steps', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', s.id, 'position', s.position, 'title', s.title, 'done_at', private.epoch(s.done_at)
      ) order by s.position)
      from public.quest_steps s where s.quest_id = q.id
    ), '[]'::jsonb)
  )
  from public.quests q where q.id = p_quest
$$;

-- Everything the tabs show, oldest quest first. Also saves the phone's time zone, which
-- the daily limits count from. An unknown time zone is ignored.
create function public.get_player_state(p_time_zone text default null)
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
    'player', private.player_json(v_user)
  );
end;
$$;

revoke all on function private.epoch(timestamptz) from public, anon, authenticated;
revoke all on function private.quest_json(uuid) from public, anon, authenticated;
revoke all on function public.get_player_state(text) from public, anon;
grant execute on function public.get_player_state(text) to authenticated;
