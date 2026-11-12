-- Editing a quest. An untouched quest (available, no steps ticked) can change
-- everything, and its rewards are worked out again. Once it's started or a step is
-- ticked, only the title and description can change and the rewards stay, so a quest
-- can't be renamed into a harder one for more XP after the fact.

create function public.update_quest(
  p_quest uuid,
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
  v_quest public.quests;
  v_title text := upper(btrim(coalesce(p_title, '')));
  v_description text := nullif(btrim(coalesce(p_description, '')), '');
  v_category text := upper(btrim(coalesce(p_category, '')));
  v_steps text[] := coalesce(p_steps, '{}');
  v_step_count integer := coalesce(array_length(p_steps, 1), 0);
  v_is_untouched boolean;
  v_difficulty text;
begin
  perform private.lock_progress(v_user);
  v_quest := private.own_quest(v_user, p_quest);

  if v_quest.type = 'daily' or v_quest.status = 'COMPLETED' then
    perform private.fail('not_allowed');
  end if;

  if v_title = '' or char_length(v_title) > 200 or char_length(coalesce(v_description, '')) > 1000 then
    perform private.fail('invalid_input');
  end if;

  v_is_untouched := v_quest.status = 'AVAILABLE' and not exists (
    select 1 from public.quest_steps where quest_id = p_quest and done_at is not null
  );

  if not v_is_untouched then
    update public.quests set title = v_title, description = v_description where id = p_quest;
    return jsonb_build_object('quest', private.quest_json(p_quest), 'player', private.player_json(v_user));
  end if;

  -- The same checks as create_quest
  if not private.is_category(v_category) then
    perform private.fail('invalid_input');
  end if;

  if v_quest.type = 'main' then
    if p_duration_minutes is not null or v_step_count not between 3 and 10 or exists (
      select 1 from unnest(v_steps) s where btrim(coalesce(s, '')) = '' or char_length(btrim(s)) > 200
    ) then
      perform private.fail('invalid_input');
    end if;
  elsif v_step_count > 0 or coalesce(p_duration_minutes, 0) not in (15, 30, 60, 120) then
    perform private.fail('invalid_input');
  end if;

  v_difficulty := private.estimate_difficulty(v_title, v_description);

  update public.quests
  set title = v_title,
    description = v_description,
    category = v_category,
    difficulty = v_difficulty,
    duration_minutes = p_duration_minutes,
    xp_reward = case v_quest.type
      when 'main' then private.xp_per_step(v_difficulty) * v_step_count
      else private.timed_xp(p_duration_minutes, v_difficulty)
    end,
    attribute_rewards = private.quest_attributes(v_category, v_difficulty, p_duration_minutes)
  where id = p_quest;

  if v_quest.type = 'main' then
    delete from public.quest_steps where quest_id = p_quest;
    insert into public.quest_steps (quest_id, user_id, position, title)
    select p_quest, v_user, (s.ord - 1)::integer, btrim(s.title)
    from unnest(v_steps) with ordinality as s(title, ord);
  end if;

  return jsonb_build_object('quest', private.quest_json(p_quest), 'player', private.player_json(v_user));
end;
$$;

revoke all on function public.update_quest(uuid, text, text, text, integer, text[]) from public, anon;
grant execute on function public.update_quest(uuid, text, text, text, integer, text[]) to authenticated;
