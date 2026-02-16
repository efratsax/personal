-- ============================================================
-- Overlap Dating Utility — Initial Schema Migration
-- ============================================================

-- 1. Extensions
-- ============================================================
create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists "postgis"   with schema extensions;

-- 2. Custom Enum Types
-- ============================================================
create type privacy_level as enum ('public', 'blurred', 'hidden');
create type vibe          as enum ('coffee', 'culture', 'drinks');
create type match_status  as enum ('pending', 'staked', 'verified', 'expired');

-- 3. Profiles
-- ============================================================
create table profiles (
  id                    uuid primary key references auth.users(id) on delete cascade,
  display_name          text not null,
  reliability_score     integer not null default 100
                        check (reliability_score >= 0),
  charm_ids             uuid[] default '{}',
  current_token_balance integer not null default 0
                        check (current_token_balance >= 0),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

comment on table  profiles is 'One row per authenticated user.';
comment on column profiles.reliability_score is 'BLE-verified attendance score; starts at 100.';
comment on column profiles.charm_ids is 'Up to 3 personality-perk UUIDs selected by the user.';
comment on column profiles.current_token_balance is 'Number of $10 commitment tokens held.';

-- 4. Availability Pins
-- ============================================================
create table availability_pins (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references profiles(id) on delete cascade,
  location      geography(point, 4326) not null,
  time_range    tstzrange not null,
  privacy_level privacy_level not null default 'blurred',
  vibe          vibe not null,
  created_at    timestamptz not null default now(),

  -- Prevent a user from posting overlapping time windows
  constraint no_overlapping_pins
    exclude using gist (user_id with =, time_range with &&)
);

comment on table  availability_pins is 'Ephemeral map pins; hard-deleted 24 h after time_range upper bound.';
comment on column availability_pins.location is 'WGS-84 point; revealed as fuzzy circle until match is staked.';
comment on column availability_pins.time_range is 'Inclusive start / exclusive end window for the date.';

-- Spatial index for proximity queries
create index idx_pins_location on availability_pins using gist (location);

-- Fast lookup by owner
create index idx_pins_user_id on availability_pins (user_id);

-- 5. Matches
-- ============================================================
create table matches (
  id          uuid primary key default uuid_generate_v4(),
  pin_id      uuid not null references availability_pins(id) on delete cascade,
  initiator   uuid not null references profiles(id) on delete cascade,
  joiner      uuid not null references profiles(id) on delete cascade,
  status      match_status not null default 'pending',
  match_uuid  uuid not null default uuid_generate_v4(),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint different_users check (initiator <> joiner)
);

comment on table  matches is 'Links two users around a single availability pin.';
comment on column matches.match_uuid is 'Unique BLE handshake identifier broadcast during the meeting window.';

create index idx_matches_initiator on matches (initiator);
create index idx_matches_joiner    on matches (joiner);
create index idx_matches_pin       on matches (pin_id);

-- 6. Handy updated_at trigger
-- ============================================================
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_profiles_updated_at
  before update on profiles
  for each row execute function set_updated_at();

create trigger trg_matches_updated_at
  before update on matches
  for each row execute function set_updated_at();

-- 7. Row Level Security
-- ============================================================

-- ---- Profiles ------------------------------------------------
alter table profiles enable row level security;

-- Users can read their own profile
create policy "profiles_select_own"
  on profiles for select
  using (id = auth.uid());

-- Users can update only their own profile
create policy "profiles_update_own"
  on profiles for update
  using (id = auth.uid());

-- Users can insert their own profile row (sign-up)
create policy "profiles_insert_own"
  on profiles for insert
  with check (id = auth.uid());

-- ---- Availability Pins ---------------------------------------
alter table availability_pins enable row level security;

-- Owner can do anything with their own pins
create policy "pins_owner_all"
  on availability_pins for all
  using (user_id = auth.uid());

-- Authenticated users can see public and blurred pins on the map
create policy "pins_select_visible"
  on availability_pins for select
  using (privacy_level in ('public', 'blurred'));

-- ---- Matches -------------------------------------------------
alter table matches enable row level security;

-- Participants can view their own matches
create policy "matches_select_own"
  on matches for select
  using (initiator = auth.uid() or joiner = auth.uid());

-- Only the joiner creates the match row (the "Knock")
create policy "matches_insert_joiner"
  on matches for insert
  with check (joiner = auth.uid());

-- Participants can update match status (accept / stake / verify)
create policy "matches_update_own"
  on matches for update
  using (initiator = auth.uid() or joiner = auth.uid());
