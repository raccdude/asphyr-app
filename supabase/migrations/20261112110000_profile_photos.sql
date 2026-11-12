-- Backend step 5: profile photos, in a private bucket. Each person has one photo at
-- `<their id>/avatar.jpg`, and only they can read or change it.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', false, 2097152, array['image/jpeg'])
on conflict (id) do nothing;

create policy "Read own photo" on storage.objects
  for select to authenticated
  using (bucket_id = 'avatars' and name = (select auth.uid())::text || '/avatar.jpg');

create policy "Add own photo" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and name = (select auth.uid())::text || '/avatar.jpg');

create policy "Replace own photo" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and name = (select auth.uid())::text || '/avatar.jpg')
  with check (bucket_id = 'avatars' and name = (select auth.uid())::text || '/avatar.jpg');

create policy "Remove own photo" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and name = (select auth.uid())::text || '/avatar.jpg');

-- The app had no length limits, so these are generous
alter table public.profiles
  add constraint profiles_name_length check (char_length(name) <= 100),
  add constraint profiles_aspiration_length check (char_length(aspiration) <= 100);

-- A profile can only point at its own photo
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

  if new.photo_path is not null and new.photo_path <> new.id::text || '/avatar.jpg' then
    raise exception 'A profile can only use its own photo';
  end if;

  new.updated_at := now();
  return new;
end;
$$;

revoke all on function public.check_profile_update() from public, anon, authenticated;
