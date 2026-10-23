-- Poker Night Shared: run once in Supabase SQL Editor.
-- Requires Supabase Auth anonymous sign-ins to be enabled in project settings.

create table if not exists public.poker_rooms (
  id uuid primary key default gen_random_uuid(),
  invite_code text not null unique,
  name text not null default 'Poker Night',
  state jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.poker_room_members (
  room_id uuid not null references public.poker_rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (room_id, user_id)
);

alter table public.poker_rooms enable row level security;
alter table public.poker_room_members enable row level security;

create or replace function public.is_poker_room_member(target_room uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.poker_room_members m
    where m.room_id = target_room and m.user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_poker_room_member(uuid) from public;
grant execute on function public.is_poker_room_member(uuid) to authenticated;

drop policy if exists "Members can read their rooms" on public.poker_rooms;
create policy "Members can read their rooms" on public.poker_rooms
for select to authenticated using (public.is_poker_room_member(id));

drop policy if exists "Members can update their rooms" on public.poker_rooms;
create policy "Members can update their rooms" on public.poker_rooms
for update to authenticated using (public.is_poker_room_member(id))
with check (public.is_poker_room_member(id));

drop policy if exists "Users can read their memberships" on public.poker_room_members;
create policy "Users can read their memberships" on public.poker_room_members
for select to authenticated using (user_id = (select auth.uid()));

create or replace function public.create_poker_room(room_name text, initial_state jsonb)
returns jsonb
language plpgsql security definer
set search_path = ''
as $$
declare
  new_room public.poker_rooms;
  new_code text;
begin
  if auth.uid() is null then raise exception 'Sign in is required'; end if;
  loop
    new_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
    exit when not exists (select 1 from public.poker_rooms r where r.invite_code = new_code);
  end loop;
  insert into public.poker_rooms(invite_code, name, state)
  values (new_code, left(coalesce(nullif(trim(room_name), ''), 'Poker Night'), 50), coalesce(initial_state, '{}'::jsonb))
  returning * into new_room;
  insert into public.poker_room_members(room_id, user_id) values (new_room.id, auth.uid());
  return to_jsonb(new_room);
end;
$$;

create or replace function public.join_poker_room(invite_code text)
returns jsonb
language plpgsql security definer
set search_path = ''
as $$
declare
  found_room public.poker_rooms;
begin
  if auth.uid() is null then raise exception 'Sign in is required'; end if;
  select * into found_room from public.poker_rooms r
  where r.invite_code = upper(trim(join_poker_room.invite_code));
  if not found then raise exception 'Room code not found'; end if;
  insert into public.poker_room_members(room_id, user_id)
  values (found_room.id, auth.uid()) on conflict do nothing;
  return to_jsonb(found_room);
end;
$$;

revoke all on function public.create_poker_room(text, jsonb) from public;
revoke all on function public.join_poker_room(text) from public;
grant execute on function public.create_poker_room(text, jsonb) to authenticated;
grant execute on function public.join_poker_room(text) to authenticated;

grant select, update on public.poker_rooms to authenticated;
grant select on public.poker_room_members to authenticated;

-- Enable live updates for the room row.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'poker_rooms'
  ) then
    alter publication supabase_realtime add table public.poker_rooms;
  end if;
end;
$$;
