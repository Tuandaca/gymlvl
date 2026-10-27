# GYMLVL × OPENGYM — MASTER MIGRATION PLAN

**Phiên bản kế hoạch:** 1.0 | **Ngày rà soát:** 27/10/2026  
**Mục tiêu:** Mobile-first GymLvl (iOS/Android), trải nghiệm fitness chuẩn, RPG Class/XP/Quest và AI PT an toàn.  
**Quyết định:** Giữ **Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL/Edge Functions**. Giữ UI **Bold Candy Neubrutalism**. **Không** chuyển sang React/Vite/Capacitor/Node-JSON backend.

> Đây là kế hoạch chuyển đổi, **chưa phải báo cáo code đã được triển khai hoặc test thực tế**. Nghiệm thu phải căn cứ log và thiết bị. Bản `main` của `Tuandaca/gymlvl` được GitHub trả về tại SHA `e0038038300d5bfaf3c4747094cf36a132eb8711` (20/04/2026); những thay đổi Teamwork trên máy có thể chưa push lên GitHub. Phải đóng băng/snapshot workspace hiện hành trước khi bắt đầu.

## A. Các nguồn chuẩn và chính sách reuse

| Nguồn | Vai trò | Chính sách |
|---|---|---|
| `Tuandaca/gymlvl` | Sản phẩm chính, Class/RPG, Flutter/Supabase | Giữ nguyên lịch sử người dùng và các chức năng hợp lệ; cải tiến dần |
| `emilfunk/opengym`, SHA `678bf5bf10446e8997a77d43e89c9b2721d8d0fc` (01/08/2026) | Tham chiếu AI Coach và bộ tính năng OpenGym đời 1.2 | Đọc tài liệu, thiết kế API/UX và viết mã Dart mới; **không copy/translate trực tiếp code AGPL** nếu chưa chọn nghĩa vụ AGPL |
| `DuarteSantos8/openGym`, SHA `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (27/10/2026) | Tham chiếu chức năng mới hơn, docs/UX/test | Theo dõi release nhưng **khóa commit** cho từng milestone; không tự động nâng theo main |
| `hasaneyldrm/exercises-dataset`, SHA `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` (16/07/2026) | **1.324** exercise metadata và multilingual step instructions | MIT áp dụng cho chữ/metadata/tooling. Giữ LICENSE/NOTICE và nguồn gốc; **loại mọi file và URL media không được phép** khỏi bản phát hành |
| `DuarteSantos8/openGym/catalogue` | Catalogue mới **5.632** exercise, bổ sung text/corrections | Những phần mới thường thuộc AGPL; chỉ đánh giá, **không mặc nhiên nhập trực tiếp** vào app không định phát hành theo AGPL |
| `Gym visual / gymvisual.com` | Ảnh, video, GIF minh họa | Bản quyền độc lập. **Không sử dụng, scrape, hotlink, copy từ repo hoặc feed AI** nếu chưa có giấy phép rõ ràng cho GymLvl |

**Quan trọng:** Phần mềm open source không đồng nghĩa toàn bộ ảnh và video của phần mềm đó là open source. Cấp phép mã nguồn AGPL không mở quyền cho media. Đây là phân tích thực tế, không thay thế tư vấn luật sư.

### Ma trận quyền / hoạt động của agent

- **GREEN:** đọc source OpenGym để phân tích yêu cầu; viết code Dart mới từ đặc tả hành vi; nhập 1.324 bản ghi chữ từ nguồn MIT kèm ghi nhận giấy phép; xây UI riêng; làm sạch metadata; viết bản dịch tiếng Việt được kiểm tra.
- **AMBER:** tái sử dụng snippet/code OpenGym AGPL, copy thiết kế biểu đạt đặc thù hoặc nhập 4.308 bản ghi mới từ catalogue gốc; chỉ sau quyết định giấy phép được phê duyệt (hoặc license khác do chủ sở hữu cấp).
- **RED:** dùng asset Gym visual từ OpenGym/dataset để phát hành GymLvl khi chưa có license; hotlink/CDN proxy để né license; feed hình/GIF vào AI; xóa `exercises` production, ghi `main` trực tiếp, deploy production ngoài phê duyệt.

## B. Nguyên tắc bất biến của sản phẩm

1. **MOBILE FIRST:** iOS + Android, trải nghiệm touch, offline logging, foreground/background và tính đúng timer.
2. **WORKOUT IS TRUTH:** Workout thực tế là nguồn dữ liệu chuẩn cho lịch sử, PR, XP và đề xuất AI. Không thưởng XP từ text/chat hoặc nút bấm giả.
3. **CLASS IS PRODUCT IDENTITY:** preserve primary/secondary class, class affinity, synergy, XP, levels, quests, level milestones; thêm vào tính năng OpenGym chứ không thay bằng app tracker thuần.
4. **AI IS ADVISORY:** AI được tạo *đề xuất* lịch/bài/thay đổi; người dùng phê duyệt. Hàm deterministic kiểm soát progressive overload, vùng an toàn, ghi log và XP.
5. **EXISTING USER DATA FIRST:** migration additive, idempotent, có rollback plan và backup. Không sửa ID bài tập đã được lịch sử workout tham chiếu.
6. **OFFLINE FRIENDLY:** ghi set local trước và sync retry idempotently; AI failure không chặn workout.
7. **SINGLE DESIGN SYSTEM:** Canvas `#fdf9f0`, surfaces trắng, ink `#111111`, stroke đen 2 px, hard-shadow 4/6/9 px; hot pink `#ff3d81`, yellow `#ffd23f`, mint `#3ddc97`, lilac `#c8a2ff`, coral `#ff6b5e`; Archivo Black heading, Space Grotesk body, Space Mono stats + fallback tiếng Việt; icon SVG thống nhất. Không gradient tím/neon; tránh chồng quá nhiều card/chữ.
8. **MEASURE, DON'T CLAIM:** chạy test thật, đo UI/performance trên thiết bị; ghi lại baseline và cải thiện, không tuyên bố 'production-ready' khi thiếu chứng cứ.

## C. Bản đồ tính năng phải tận dụng

| Nhóm | Tham khảo OpenGym | Tích hợp vào GymLvl | Độ ưu tiên |
|---|---|---|---|
| Exercise library | 1.324 MIT, hướng dẫn, muscle/equipment filter, search | API + cache local + EN/VI + màn chi tiết, placeholder nếu chưa có media | P0 |
| Workout logging | Sets/reps/weight, timed holds, rest timer, preset từ lần trước, bodyweight | Flutter offline-first log; autosave; resume; không phát sinh nhiều Supabase calls mỗi phím | P0 |
| Weekly planning | Routine mỗi ngày, kéo/chuyển buổi, share/import plan | Kế hoạch phù hợp lịch học/làm; ghép AI và Class goal | P1 |
| Progression | Linear, Greyskull LP, double progression, time; deload; lý do trọng lượng mục tiêu | Dart pure functions + golden tests từ các tình huống, không copy AGPL code | P1 |
| Personal records | Est.1RM (tối đa 12 reps), PR, effort RPE/RIR | Không ghi PR ảo khi thiếu dữ liệu; chart theo bài | P1 |
| Advanced workout | Superset, timed exercise, cardio, screen awake, nghỉ thông báo | Bổ sung từng phần; timer background/touch test | P1 |
| Analytics | History, heatmap, body map, nhóm cơ chưa tập, cân nặng | Giữ RPG Dashboard, thêm analytics chuyên môn | P2 |
| Exercise utilities | Custom exercise, equipment profile, plan sharing, imports Strong/Hevy/FitNotes | Lấy hữu ích, không cản MVP | P2/P3 |
| AI planning | Intake, tạo plan, giải thích, review RPE/RIR/stalls, approval/revert | Server-side provider adapter + schema validation + audit logs | P1/P2 |
| RPG riêng GymLvl | Class, multi-class, class synergy, quest, XP, level, graduation | Giữ, sửa tính đúng và liên kết Workout Completion | P0/P1 |
| Upstream mới | 5.632 bài, Health integrations, smartwatch | **Chỉ roadmap** sau legal/UX/scope; không tự chuyển vào release đầu | P3 |

**Không đưa vào milestone đầu:** camera đánh giá kỹ thuật tập, AI tự đặt tải tập không có giới hạn, social PvP leaderboard, watch app, Google/Apple Health, nutrition diagnosis; chúng tăng đáng kể nguy cơ sai chuyên môn và phân tán công sức.

## D. Tách kiến trúc/module

- Flutter feature modules: `features/exercise_library`, `features/workout`, `features/training_plan`, `features/progression`, `features/quests`, `features/coach`, `features/analytics`; component dùng chung ở `core/design_system`, typed repository interfaces ở `core/data`.
- Supabase PostgreSQL là nguồn sự thật cho catalog metadata, profiles, routines, workouts, exercise logs, ledger XP, quests, coach proposals; RLS đúng user; edge functions chỉ cho thao tác server và AI gateway.
- App local cache: SQLite/Drift hoặc Isar (chọn **một** giải pháp sau tech spike) cho exercise catalogue, workout drafts, sync outbox, cache version. `shared_preferences` chỉ cho setting nhẹ, không làm nơi lưu workout lâu dài.
- Media: `exercise_media` riêng với `status` (`unavailable`,`licensed`,`pending`), `license_id`,`provider`,`object_key`,`checksum`,`format`,`attribution`,`permitted_use`; object store/CDN tách với PostgreSQL, thumbnails và clips chỉ hiển thị khi có quyền.
- AI adapter: Flutter `CoachRepository` -> authenticated Edge Function/backend -> selected AI provider. Không bao giờ gửi secrets/AI key trong client. Kết quả là typed JSON **proposal**, backend validate exercise IDs, load/range, consent, plan ownership, version; snapshot -> approve -> apply atomically; revert preserve workout history.
- Workout/RPG: one authenticated idempotent command `complete_workout(workout_id, idempotency_key)` trong DB transaction, hàng ghi `xp_ledger` unique keys, class xp/streak/quest/PR updates nhất quán; không chain các call làm nguồn sai lệch.

### Dữ liệu (gợi ý schema, chưa áp dụng production)

`exercise_catalog(id UUID, source, external_id, slug, name_en, equipment_code, body_part_code, primary_muscle_code, secondary_muscles, movement_type, difficulty, active, source_version, provenance, UNIQUE(source, external_id))`  
`exercise_instructions(exercise_id, locale, steps JSONB, notes, review_status, source_license)`  
`exercise_media(id, exercise_id, kind, object_key, attribution, license_reference, rights_status, checksum)`  
`exercise_aliases(alias, locale, canonical_exercise_id)`  
`training_plans / plan_days / planned_exercises`  
`workout_events(idempotency_key, user_id, workout_id, event_type, payload, synced_at)`  
`xp_ledger(source_workout_id, recipient_type, recipient_id, xp_delta, rule_version, UNIQUE(source_workout_id, recipient_type, recipient_id, rule_version))`  
`coach_profiles / coach_consents / coach_proposals / coach_proposal_items / coach_audit_logs`

Giữ tương thích với bảng GymLvl hiện hữu (`exercises`, `workouts`, `workout_exercises`, `workout_sets`, `exercise_prs`, classes, quests). Không mặc định đổi tên/xóa bảng ngay; chọn migration additive hoặc view/adapter tùy audit. `source/external_id` là khóa chống duplicate; bản dịch/media có thể tăng phiên bản mà không làm mất workout history.

## E. Milestones thực thi theo thứ tự, có quality gate

### M0 — Baseline, protect ongoing Antigravity work, legal inventory (bắt buộc)

**Phạm vi:** snapshot branch/tag workspace hiện tại; ghi SHA, `git status`, diff, tests hiện có, known broken; chụp ảnh UI hiện tại. Inventory license từng nguồn, nguồn thứ ba, cấu trúc database, RLS, migration, secrets. Đọc `pubspec`, workout flows, edge functions, seed SQL. Tạo file `PROJECT_CONSTITUTION.md`, `UPSTREAM_SOURCE_MANIFEST.json`, `LICENSE_LEDGER.csv`, `BASELINE_REPORT.md`, `TASK_BOARD.md`.

**Không làm:** refactor lớn, import media, xóa tables, deploy.  
**Gate:** mọi quyết định UI/mobile/RPG/AI/legal được ghi bằng câu testable; có rollback branch; `flutter analyze`/`flutter test` được chạy và ghi kết quả *pass/fail thực*, không che lỗi baseline.

### M1 — Stabilize code + Candy Neubrutalism foundation

**Phạm vi:** resolve hai `AppTheme` trùng nhau; xây `CandyScaffold`, `CandyCard`, `CandyButton`, `CandyInput`, `CandySheet`, `CandyToast`, typography/tokens/semantic colors; repair shell navigation, loading/error/empty states và auth redirect. Pinned dependencies sau regression checks. UI responsive touch, Vietnamese font fallback, accessible controls, page transitions, loading phản hồi ngay. Sửa tests cũ out-of-sync và CI cơ bản Android Flutter test/analyze; iOS build khi có macOS runner.

**Không làm:** chuyển React, đổi Supabase, làm lại mọi màn cùng một PR.  
**Gate:** Dashboard + navigation + một screen Workout dùng design system thống nhất; không dead tap; tests actual pass hoặc có blocker phân loại, screenshot Android/iOS được kiểm tra; Android release build thử thành công trên môi trường hỗ trợ.

### M2 — Exercise data ingestion + legal-safe offline catalogue

**Phạm vi:** import **chỉ** metadata/instructions MIT từ bản data 1.324 exercise đã khóa SHA; `LICENSE`, `NOTICE`, provenance; chọn taxonomy, normalized IDs, slug, alias, equipment, beginner tags, type strength/time/cardio; ETL `extract -> validate -> normalize -> dry_run -> upsert`; safety/duplicate report. Strip `image`, `gif_url` và asset path trước khi triển khai, media `unavailable` mặc định; dịch Việt tự động theo batch + checklist QA ưu tiên khoảng 100–150 bài phổ biến. Local cache, versioned incremental refresh, search/filter.

**Không làm:** nhập ảnh, `TRUNCATE`, overwrite 22 bài cũ; auto-translations không có review vào gợi ý AI mức cao.  
**Gate:** source row count đúng theo manifest (dự kiến 1.324), unique source+ID, không duplicate khi chạy ETL 2–3 lần, existing workout references giữ nguyên, RLS read catalog đúng, search/filter offline chạy, license scan không thấy media trái phép, test mapping nhóm cơ đầy đủ.

### M3 — Professional workout core, offline reliability

**Phạm vi:** phân biệt modes `reps-weight`, `bodyweight`, `timed`, `cardio`; tạo plan/routines, chọn ngày tập, add/remove/reorder exercise, set logging autosave local, batch/debounce DB, timers pause/resume đúng, rest timer, wake-lock, superset ưu tiên sau flows cơ bản, editable history correction, workout resume sau kill app, zero/empty/error states. Không fallback bài khác khi ID không tìm được; dùng explicit missing-data state.

**Gate:** 12 tình huống E2E gồm offline start/set/end/reconnect, simultaneous updates, duplicate taps, bodyweight plank (không bị ép 5 kg), cancel, restart/restore, fast category switching, interrupted network, invalid reps, background timer; no lost sets; count remote writes được đo và cải thiện so với baseline.

### M4 — Deterministic progression + trustworthy RPG bridge

**Phạm vi:** reimplement progression by written spec: linear, double, Greyskull, timed; no load increase after missed reps; deload/stall; est 1RM cap 12 reps; personal records; formula unit tests. Normalize class affinities, primary/secondary XP, synergy, graduation, quests, Vietnam-local-day streaks. Fix category matching push/pull/legs/full-body through typed tags not fuzzy `ilike`; server-side idempotent transaction with ledger for finish/reward; daily quest uniq per user/date; authoritative dates/UTC window.

**Gate:** golden test table: identical workout retried 3 times = **one** reward; concurrent completion = one ledger; partial failure rollback; retry succeeds after network outage; class multiplier reproducible; no XP on invalid/uncompleted workouts; VN 23:59/00:01 date tests; target actions start correct quest workout; full flow (quest -> workout -> finish -> XP -> update profile) verified.

### M5 — Analytics + routine quality & novice user journey

**Phạm vi:** weekly calendar/reschedule, history, PR/1RM chart, muscle heatmap, weight trend, training consistency, effort RPE/RIR, equipment profile and custom exercise. Local aggregate cache. Onboarding for beginner and create First Week routine; class choice maps to training objective but **Class is not a medical or exercise constraint**. Warnings for medical/safety red flags, conservative default progression; localized instruction quality review.

**Gate:** novice can answer onboarding, select Class, receive a beginner-safe plan, understand exercise instructions, complete 3 workouts, see meaningful feedback. Data charts reconcile totals with logged history. Missing data explicitly identified rather than invented.

### M6 — AI PT v1 (plan design, revisions, controlled explainability)

**Phạm vi:** selectable AI provider through server gateway, rate limit/budgets, consent per user, allowlisted data, structured JSON schema; prompts grounded in **licensed text** and user history only; onboarding goals/equipment/expertise/time availability; recommend exercise IDs only from verified catalogue; plan generation, question-answering with retrieval, weekly review after actual workouts, suggestion diff and rationale, preview/apply/revert and audit trail. RPE/RIR/adherence trend summary; repeated suggestions suppressed. AI cannot write XP/PR, override safety checks, or execute arbitrary code.

**Gate:** fixture/no-AI tests, schema validation invalid IDs/ranges/injury triggers, injection protection in user notes/instructions, gateway failure fallback, consent withdrawn prevents data transfer, token/latency/cost counters, deterministic load stays unchanged unless approved valid plan change. Human safety review of representative beginner prompts; **no unverified medical/rehab instructions**.

### M7 — Licensed media integration (parallel with M2–M6, deployment gated)

**Phạm vi:** ask Gym visual written commercial license or source alternative with unambiguous rights. Maintain rights register and contract evidence; prepare asset-manifest with resolution, media type, permitted countries/platforms, streaming vs bundled/offline, attribution, modification rights, caching/CDN, subscription monetization, renewal/termination. Pilot 30–50 key exercises before bulk import. Then batch asset ingest (from authorized delivery, **not scraping**), format optimizations only if permitted, checksum, CDN, prefetch and offline playback, fallbacks.

**Gate:** asset-owner explicit permission matching actual usage including caching/CDN and app-store distribution; release scan has no unlicensed media; all screen attribution matches license; fallback screens good when no rights/media. Do not encode raw media in AI input or use it to generate derived media unless contract expressly allows.

### M8 — iOS/Android release hardening and quality audit

**Phạm vi:** Android physical device smoke + lower-performance device tests; iOS real/simulator with Mac runner; permission audits, background interruptions, data export/deletion, privacy policy, support email, age policy, app store screenshots, crash reports opt-in, Sentry/etc only if approved. Database RLS/permission penetration checks; backups; recovery runbook; usage budgets/free-tier alert; version migration; accessibility font scales, 60fps target where feasible, memory/cache sizing; security/provider keys handling. UX Candy audit every released screen, not only dashboard.

**Gate:** device test matrix signed off; Android signed artifact and iOS TestFlight/archive build where environment/accounts available; TestFlight/App Store publication only with user's approval; end-to-end game + fitness + AI on real account in staging; no P0/P1 regression, known P2 disclosed, legal ledger green and no secrets in git.

### M9 — Optional expansion AFTER MVP

5.632 catalogue adoption only after rights/AGPL choice; stronger periodization, custom calendars, workouts export/import, Health Connect/HealthKit, widget/watch integration, accessibility voice cues, gym geolocation if opt-in, video form analysis only after expert validation and separate video privacy design, seasonal RPG campaigns and Class-specific training story arcs.

## F. Quy trình pháp lý MEDIA — tối thiểu thao tác thủ công

**S1 Agent tự làm:** lập `LICENSE_LEDGER.csv`: item, exact source URL, SHA/version, owner, license, redistribution, commercial, edit/resize, host/cache/offline, AI usage, attribution, evidence link, status, action owner. Thu thập file `LICENSE` và `NOTICE` nguyên văn. Chọn shortlist 100–150 động tác cốt lõi để định giá media thay vì mua cả thư viện ngay.

**S2 User chỉ cần gửi yêu cầu cấp phép** qua biểu mẫu chính thức: https://gymvisual.com/contact-gymvisual (agent soạn sẵn nội dung tiếng Anh phía dưới).

**S3 Yêu cầu văn bản xác nhận tối thiểu:** (a) iOS + Android store + dịch vụ cloud cho GymLvl, (b) ứng dụng miễn phí hoặc freemium/subscription có hợp lệ không, (c) số bài/asset và resolution, (d) streaming qua Supabase Storage/CDN hoặc bên thứ ba, (e) downloadable offline caching/local device, (f) resized/re-encode/crop/compression, (g) branding/attribution/credits, (h) phạm vi địa lý và thời hạn, (i) redistribution app package, (j) chia sẻ dữ liệu media với AI: **không dự định làm, nhưng cần xác nhận nếu tương lai thay đổi**, (k) cấp quyền cho một cá nhân hoặc doanh nghiệp, (l) chi phí/bao gồm hỗ trợ cập nhật.

**S4 Agent ghi trạng thái:** `unlicensed` cho đến khi nhận email/contract cụ thể. Không suy diễn quyền từ việc media thấy trên GitHub, từ 180 px, hay từ gói được bán trên web.

**S5 Agent thực hiện khi hợp lệ:** chỉ dùng media do bên cấp phép cung cấp; lưu proof + checksum; tối ưu theo quyền; `media_assets` có attribution; CI thất bại nếu media `unlicensed` bị tham chiếu bởi release.

**S6 Nếu không có kinh phí hoặc họ từ chối:** không block MVP. App có 1.324 bài với hướng dẫn chữ; làm khoảng 30–50 hướng dẫn do chính bạn/quay với người hướng dẫn có consent, thuê illustrator/animator theo hợp đồng chuyển quyền thích hợp, hoặc thay bằng nội dung media từ nguồn khác cấp phép rõ. Không lấy GIF của Gym visual đưa vào AI để vẽ lại.

### Email xin phép — chỉ cần copy và gửi qua contact form

**Subject:** Commercial licensing enquiry — exercise animation assets for GymLvl iOS/Android fitness app

Hello Gym visual team,

I am developing GymLvl, a mobile-first fitness education and workout tracking application for iOS and Android. It provides guided workouts, training plans, and game-style progression. The app may be offered initially for free and later as a freemium/subscription service.

I would like to request a written quotation and license terms for using your exercise images and animations, initially for approximately 100–150 core exercises, with a possible expansion to a larger catalogue.

Could you please clarify whether a license would cover:
1. Inclusion in distributed iOS/Android apps and display to end users;
2. Streaming through our own storage/CDN, including Supabase, and local caching/offline viewing;
3. Compression, format conversion (GIF/video/WebP) and resizing for mobile performance;
4. Commercial use including free, subscription and in-app purchase models;
5. Required attribution, permitted resolutions, territory, duration, renewals and pricing;
6. Whether assets may be included in app packages or must remain server-hosted;
7. Whether a license is available for a student-led project with limited budget;
8. Which assets can be licensed in bulk and how they are delivered.

We do not intend to use the assets for AI training, AI image generation or redistribution as a media library.

Please provide the applicable written license terms and a quote. Thank you.

Best regards,
GymLvl project team

> Ghi chú: người dùng cần tự gửi/nhận email; agent có thể chuẩn bị và lưu contract/proof, **không tự coi như đã được cấp quyền**.

## G. Quy tắc Teamwork / context isolation / anti-hallucination

**Mỗi lượt chỉ xử lý 1 milestone.** Lead tạo checklist tối đa khoảng 5–8 task có thể kiểm thử, cấp ownership độc quyền file và tách PR/branch. Agent không tự tạo thêm roadmap scope; handoff bằng tài liệu (không chuyển hàng chục nghìn token chat cũ). Khi token context lớn, mở phiên mới dùng chỉ `PROJECT_CONSTITUTION.md`, `CURRENT_STATE.md`, `TASK_BOARD.md`, `DECISION_LOG.md`, source manifest và files liên quan.

**Ownership:** Lead/router/theme contracts; Agent DATA migrations/ETL; Agent WORKOUT Dart; Agent BACKEND SQL/Edge; Agent AI provider + schema; Agent QA tests/CI/visual. Một file chỉ một owner tại một thời điểm. Cần thay đổi shared contract -> proposal với lead trước.

**Một task hợp lệ phải có:** `ID`, business outcome, source pointers with SHA, files owned, files forbidden, design contract, DB contract, acceptance tests, destructive-op prohibitions, output evidence. Mỗi PR nhỏ, CI check + independent critic/auditor + lead integration test, có rollback. Nếu lỗi hoặc thiếu quyền, ghi blocker thay vì tạo fake UI/claim completed.

**Quality Gates (không được bypass):** code compiles; `flutter analyze`, `flutter test`; relevant SQL/Deno/integration tests; Android smoke, iOS runner as available; schema migration dry run; legal status green for distributed assets; fixtures for AI; no secrets; no history loss; screenshots matching Candy style. Ghi rõ `PASS`, `FAIL`, `NOT RUN` với log, môi trường và commit.

**Định dạng báo cáo ngắn sau mỗi milestone** (`HANDOFF_M{n}.md`):

```
Milestone / Git commit / Branch:
Changed files and modules:
What is delivered and demonstrated:
Tests actually run (command, environment, result):
Runtime screenshots / recordings:
Metrics before and after:
Open P0/P1 bugs:
Data migration and rollback:
Licenses and media sources used:
Architecture decisions needing approval:
Next milestone dependencies:
```

**Không cho** agent chạy `git reset --hard`, xóa local progress, rewrite toàn repo, `TRUNCATE/DROP` dữ liệu production, force push, provision paid services, tạo public release, hoặc copy AGPL/proprietary assets không được phép. Những hành động này bắt buộc user approval.

## H. Chỉ dẫn orchestration ban đầu cho Antigravity

```text
GYMLVL WORKSTREAM RULES — READ FIRST
Goal: Mobile-first iOS/Android RPG fitness app, existing Flutter/Riverpod/GoRouter/Supabase stack only. Preserve Candy Neubrutalism visual language and original Class/Multi-Class/XP/Quest progression.
Sources: Tuandaca/gymlvl (target); emilfunk/opengym (AI patterns); DuarteSantos8/openGym (upstream patterns); hasaneyldrm/exercises-dataset (MIT text-only data). Pin SHAs listed in the master plan. No direct copying/translation of AGPL source; no unlicensed Gym visual media, hotlinks, screenshots, extracted packs or AI-based transformations.
START M0 ONLY. Inspect actual current Antigravity workspace and preserve all prior uncommitted/committed work. Do not assume the GitHub remote is current. Produce SOURCE_MANIFEST, LICENSE_LEDGER, baseline quality report, module map, dependency graph, and a detailed executable M1 backlog, then STOP for review.
Task discipline: <=8 isolated tasks in one milestone, exclusive file ownership, max 1 feature per worker, independent QA, test evidence, status PASS/FAIL/NOT RUN, no fake claims. Don't alter production DB, buy a plan, deploy or push directly to main. Supply handoff files and ask for approval to start M1.
```

**Template cho M1–M8:**

```text
GYMLVL MILESTONE EXECUTION
Read PROJECT_CONSTITUTION.md, CURRENT_STATE.md, TASK_BOARD.md, DECISION_LOG.md, UPSTREAM_SOURCE_MANIFEST.json, LICENSE_LEDGER.csv, and HANDOFF from the previous milestone. Do not reconstruct from unrelated previous chat.
Execute ONLY milestone M{N} from GymLvl_OpenGym_Migration_Master_Plan.md. Treat all other milestones as out of scope. First create a 5–8 item scoped execution plan with testable exit criteria and file ownership; run independent critique. Implement on isolated branches; stop on legal uncertainty or missing secrets rather than guessing. Before declaring done, run tests, attach exact commands/logs/screenshots/metrics and create HANDOFF_M{N}.md. Do not deploy, upgrade Supabase, change the primary stack, erase previous work, or proceed automatically to M{N+1}.
```

## I. Công việc người dùng **không thể/không nên hoàn toàn ủy quyền**

| Quyết định của bạn | Cách giảm thủ công |
|---|---|
| Cấp phép media | Agent tự làm bảng lựa chọn, soạn email; bạn chỉ gửi/duyệt hợp đồng/chi phí |
| Xác định mô hình nguồn mở (AGPL vs không) | Agent xuất ma trận reuse; bạn chốt lựa chọn; nếu thương mại nên hỏi luật sư IP |
| Cấp Supabase staging/keys & AI provider | Agent soạn checklist cấu hình; bạn tự giữ bí mật key, không dán trong chat/repo |
| Thử trải nghiệm tập gym thực | Agent dựng script 10–12 tình huống; bạn test thực + feedback vấn đề cơ thể/UX |
| Kiểm duyệt chuyên môn | Agent tạo shortlist bài và câu hướng dẫn cần review; chuyên gia thể thao kiểm duyệt các bài nguy cơ cao |
| Apple Developer/Google Play accounts | Agent chuẩn bị tài sản, pipeline, declarations; bạn chịu trách nhiệm tài khoản, thanh toán, ký release |

## J. Cách phân bổ chi phí

- **Hiện tại:** Supabase Free cho metadata, profile, XP, user workouts/staging; dùng video placeholders/asset gốc tự tạo. Miễn chưa có media rights thì thêm storage không mang lại quyền dùng media.
- **Nâng Pro khi có ngưỡng:** sát quota database/storage/egress, dữ liệu cần backup vận hành, nhiều người dùng thật, không chấp nhận pause project. Giá/trần cần xác minh lại ngay trước khi mua: https://supabase.com/pricing.
- **AI:** tracking cost theo token/job, mô hình thấp chi phí cho FAQs, higher reasoning cho điều chỉnh plans khó; caching replies theo phiên bản plan; cap per user/ngày; user consent. AI cost riêng Supabase cost.
- **Media:** có thể là khoản chi lớn hơn database. Lập pilot 30–50 clips, rồi 100–150, sau khi người dùng chứng minh nhu cầu mới mở rộng cả nghìn clips.

## K. Definition of Done toàn chuyển đổi

1. Android/iOS thực chạy mobile-first, UI Candy Neubrutalism đồng nhất, accessible, mượt có đo lường.
2. Người mới thực hiện onboarding -> Class -> tailored plan -> đúng bài từ thư viện -> workout -> stats + XP/Quest; không bị dead end.
3. 1.324 bài metadata+instructions nhập đúng phép, provenance có log; tiếng Việt ưu tiên các bài phổ biến đã được kiểm tra; media không có rủi ro giấy phép.
4. Offline/reconnect không mất set, workout XP không tính hai lần, day/streak đúng múi giờ VN, no truncation history.
5. AI có consent, không chẩn đoán, chỉ đề xuất lịch, giải thích nguồn, reviewer/user phê duyệt, revert được; outage không gián đoạn workout.
6. Từng milestone có handoff, changesets, passing/reported tests, evidence; app store release chỉ sau phê duyệt + license.

## Links cần lưu

- User project: https://github.com/Tuandaca/gymlvl
- AI fork: https://github.com/emilfunk/opengym
- Upstream: https://github.com/DuarteSantos8/openGym
- 1.324 MIT data: https://github.com/hasaneyldrm/exercises-dataset
- Dataset license: https://github.com/hasaneyldrm/exercises-dataset/blob/main/LICENSE
- OpenGym third-party notices: https://github.com/DuarteSantos8/openGym/blob/main/NOTICE.md
- OpenGym catalogue guide: https://github.com/DuarteSantos8/openGym/blob/main/catalogue/README.md
- Gym visual licensing terms: https://gymvisual.com/content/3-terms-and-conditions-of-use
- Gym visual contact: https://gymvisual.com/contact-gymvisual
- Supabase pricing: https://supabase.com/pricing
- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- GNU AGPL FAQ: https://www.gnu.org/licenses/gpl-faq.en.html
