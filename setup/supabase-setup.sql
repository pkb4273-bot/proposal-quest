-- 제안서 완주판 · Supabase 설정
-- Supabase 대시보드 > SQL Editor > New query 에 전체를 붙여넣고 Run 한 번이면 끝나요.

-- 1) 테이블
create table if not exists public.steps (
  lap        int  not null,
  step       int  not null check (step between 1 and 20),
  name       text not null default '' check (char_length(name) <= 80),
  date       text not null default '' check (char_length(date) <= 10),
  filled_at  timestamptz not null default now(),
  primary key (lap, step)
);

create table if not exists public.meta (
  id   text primary key,
  data jsonb not null default '{}'::jsonb
);

create table if not exists public.cheers (
  id         bigint generated always as identity primary key,
  name       text not null default '' check (char_length(name) <= 12),
  text       text not null check (char_length(btrim(text)) between 1 and 40),
  created_at timestamptz not null default now()
);

-- 2) 권한: 누구나 읽기, 누구나 응원 쓰기, 기록·스킬·응원 삭제는 로그인한 주인만
alter table public.steps  enable row level security;
alter table public.meta   enable row level security;
alter table public.cheers enable row level security;

drop policy if exists "anyone reads steps"  on public.steps;
drop policy if exists "anyone reads meta"   on public.meta;
drop policy if exists "anyone reads cheers" on public.cheers;
drop policy if exists "anyone cheers"       on public.cheers;
drop policy if exists "owner writes steps"  on public.steps;
drop policy if exists "owner writes meta"   on public.meta;
drop policy if exists "owner deletes cheers" on public.cheers;

create policy "anyone reads steps"  on public.steps  for select using (true);
create policy "anyone reads meta"   on public.meta   for select using (true);
create policy "anyone reads cheers" on public.cheers for select using (true);
create policy "anyone cheers"       on public.cheers for insert to anon, authenticated with check (true);
-- 회원가입을 꺼두므로 로그인할 수 있는 사람은 주인 한 명뿐이에요 (README 3단계)
create policy "owner writes steps"  on public.steps  for all    to authenticated using (true) with check (true);
create policy "owner writes meta"   on public.meta   for all    to authenticated using (true) with check (true);
create policy "owner deletes cheers" on public.cheers for delete to authenticated using (true);

-- 3) 응원 도배 방지: 1분에 20개까지
create or replace function public.cheers_rate_limit() returns trigger
language plpgsql as $$
begin
  if (select count(*) from public.cheers where created_at > now() - interval '1 minute') >= 20 then
    raise exception 'too many cheers, try again later';
  end if;
  return new;
end $$;
drop trigger if exists cheers_rate_limit on public.cheers;
create trigger cheers_rate_limit before insert on public.cheers
  for each row execute function public.cheers_rate_limit();

-- 4) 실시간 반영 (응원이 들어오면 보고 있던 사람 화면에 바로 말풍선)
do $$ begin
  alter publication supabase_realtime add table public.steps, public.meta, public.cheers;
exception when duplicate_object then null; end $$;

-- 5) 지금까지 기록 옮기기 (Claude 아티팩트에서 가져온 1번째 판 3건)
insert into public.meta (id, data) values ('state', '{"lap": 1}') on conflict (id) do nothing;
insert into public.steps (lap, step, name, date, filled_at) values
  (1, 1, '경남 시범솔루션 제안서',      '2026-08-31', '2026-10-14T07:28:27.563Z'),
  (1, 2, '울산 시범솔루션 제안서',      '2026-10-02', '2026-10-14T07:28:52.508Z'),
  (1, 3, '진주 AI도시 기본계획 제안서', '2026-10-19', '2026-10-14T07:29:07.221Z')
on conflict (lap, step) do nothing;
