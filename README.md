# 제안서 완주판

제안서를 하나 끝낼 때마다 한 칸씩 나아가는 3D 모험 지도예요. 초대 링크를 받은 사람은 응원을 남길 수 있고, 기록과 스킬은 주인만 바꿀 수 있어요.

- `index.html` 페이지 전체
- `config.js` Supabase 연결 정보 (공개용 anon key만)
- `setup/supabase-setup.sql` 데이터베이스 설정

## 처음 한 번 설정

1. **Supabase 프로젝트 만들기**: https://supabase.com 에서 GitHub로 로그인 → New project (무료 플랜, 지역은 Northeast Asia (Seoul)).
2. **SQL 실행**: 대시보드 왼쪽 SQL Editor → New query → `setup/supabase-setup.sql` 내용을 전부 붙여넣고 Run.
   결과 표에 나온 `code` 값이 초대 코드예요. `https://pkb4273-bot.github.io/proposal-quest/#invite=<code>` 형태로 보내면 받은 사람만 응원을 남길 수 있어요. 코드는 이 저장소에 올리지 마세요.
3. **회원가입 끄기**: Authentication → Sign In / Providers → "Allow new users to sign up" 끄기.
   (이걸 꺼야 주인 말고는 아무도 로그인할 수 없어요.)
4. **주인 계정 만들기**: Authentication → Users → Add user → Create new user. 이메일·비밀번호 입력, "Auto Confirm User" 체크.
5. **연결 정보 넣기**: Project Settings → API에서 Project URL과 anon public 키를 복사해 `config.js`에 붙여넣기.
6. **GitHub Pages 켜기**: 저장소 Settings → Pages → Source를 "Deploy from a branch", Branch를 `main` / `(root)`로 저장.

## 쓰는 법

- 오른쪽 위 **주인 로그인**으로 들어가면 칸 전진, 되돌리기, 스킬 올리기, 응원 지우기가 보여요.
- 다른 사람은 로그인 없이 지도를 돌아다닐 수 있고, 초대 링크로 들어온 사람은 응원도 남길 수 있어요. (한 번 초대 링크로 들어오면 그 브라우저에서는 계속 남길 수 있어요.)
