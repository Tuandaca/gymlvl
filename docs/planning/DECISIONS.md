# GymLvl — Decision Log

**Status:** Active
**Established:** 2026-10-28
**Baseline:** `56c1122`
**Rule:** Every material change to architecture, schema strategy, licensing, dependency policy, or
milestone scope needs an entry here. Do not silently change a decision.

Status values:

- **ACCEPTED** — approved and in force.
- **PROPOSED** — recommended, not approved; implementation is blocked until accepted.
- **SUPERSEDED** — replaced by a later entry; keep for history.
- **RECORDED** — a fact or constraint, not a choice.

---

## Summary

| ID | Decision | Status | Date |
|---|---|---|---|
| D-001 | Preserve Flutter/Supabase/RPG/Candy architecture | ACCEPTED | 2026-10-27 |
| D-002 | No AGPL code reuse; MIT text only | ACCEPTED for current milestones; long-term posture OPEN | 2026-10-27 |
| D-003 | Third-party exercise media postponed | ACCEPTED | 2026-10-27 |
| D-004 | Re-baseline M1 to release-critical stabilization | PROPOSED | 2026-10-28 |
| D-005 | Drift as the local offline store | PROPOSED | 2026-10-27 |
| D-006 | Import all 1,324 MIT text records | PROPOSED | 2026-10-27 |
| D-007 | AI proposes; user approves; server applies | ACCEPTED (product contract); implementation pending | 2026-10-27 |
| D-008 | PostgreSQL remains authoritative for XP/rewards | ACCEPTED | Existing invariant |
| D-009 | No automatic commits, pushes, or tags | ACCEPTED | 2026-10-28 |
| D-010 | Memory files are the canonical process layer | ACCEPTED | 2026-10-28 |
| D-011 | Baseline is clean `56c1122`; M0's dirty snapshot is historical | RECORDED | 2026-10-28 |
| D-012 | Documentation-only bootstrap; no feature work | ACCEPTED | 2026-10-28 |
| D-013 | External backup required before memory edits | ACCEPTED | 2026-10-28 |

---

## D-001 — Preserve the existing platform

**Status:** ACCEPTED
**Context:** GymLvl is a working Flutter + Supabase fitness RPG. OpenGym is a React/Capacitor
application with a different backend.
**Decision:** Keep Flutter, Dart, Riverpod, GoRouter, Supabase/PostgreSQL/Edge Functions, the RPG
class system, and the Candy Neubrutalism design system. Do not migrate the client stack or adopt
OpenGym UI.
**Consequences:** OpenGym capabilities must be reimplemented natively in Dart/SQL or integrated as
data only. No code porting.

## D-002 — Licensing posture: reference-only AGPL, MIT text only

**Status:** ACCEPTED for current milestones (explicit user constraint). The long-term GymLvl license
posture remains OPEN (O-01, O-02).
**Context:** Both OpenGym repositories are AGPL-3.0. OpenGym B's app-store exception is not
transferable. The exercise dataset is MIT for text/data but excludes Gym visual media. GymLvl has no
LICENSE file.
**Decision:** Treat OpenGym code, prompts, catalogue text, and assets as reference-only. Import only
MIT text/metadata with attribution and notice. Do not import media. Do not copy AGPL code without an
approved compliance strategy.
**Consequences:** All OpenGym-derived behavior must be specified and independently implemented. A
clean-room process is required. GymLvl's own license/provenance remains unresolved.

## D-003 — Media postponed

**Status:** ACCEPTED (explicit user instruction)
**Context:** Exercise images/GIFs are proprietary Gym visual media; licensing is unresolved.
**Decision:** No download, hotlink, copy, generation, processing, or integration of third-party
exercise media. No licensing outreach in current milestones.
**Consequences:** The catalog is text/metadata only. `exercise_media` defaults to `unavailable`. Any
media milestone requires explicit authorization and written rights evidence.

## D-004 — Re-baseline M1

**Status:** PROPOSED — M1-01 is the proposed next task; the full six-task M1 scope requires approval
before M1-02.
**Context:** The original M1 (Candy foundation, theme cleanup, shell/auth routing) is already
implemented and verified. The actual blockers are release configuration and stale documentation.
**Decision:** Redefine M1 as release-critical stabilization: baseline evidence (M1-01), platform
config (M1-02), typography cleanup (M1-03), docs truth (M1-04), CI config regression (M1-05), and
rendered baseline screenshots (M1-06).
**Consequences:** No duplicate design-system work. The original plan is preserved; this is recorded
as a scope correction in `MASTER_PLAN.md` §6.

## D-005 — Local storage: Drift

**Status:** PROPOSED — not approved; do not add the dependency yet.
**Context:** GymLvl has no local database. Offline logging, catalog cache, and drafts need durable
local storage. Candidates: Drift, Isar, sqflite, raw SQLite.
**Decision:** Use Drift as the single local store if approved.
**Rationale:** Mature SQLite, typed queries, migrations, testability, good fit for cache + outbox +
drafts. `shared_preferences` remains for lightweight settings.
**Consequences:** Adds a dependency, code generation, and a local schema to maintain. Web/WASM is not
a release requirement. Requires an approved M3 design before implementation.

## D-006 — Catalog import scope

**Status:** PROPOSED
**Context:** The dataset has 1,324 MIT text records; GymLvl has 150 curated exercises. OpenGym B's
6,554-record catalogue is AGPL and cannot be imported.
**Decision:** Import all 1,324 MIT text/metadata records in M2, behind a reviewable ETL, preserving
existing UUIDs and adding source-keyed rows.
**Consequences:** Requires provenance columns, idempotency, search/pagination, and a duplicate-merge
strategy. A curated 300–500 subset remains an acceptable fallback if review capacity is limited.

## D-007 — AI Coach is proposal-based

**Status:** ACCEPTED as a product contract (explicit user requirement). Implementation is pending M6;
no code is authorized yet.
**Context:** The current coach is a chat proxy with no typed output, validation, or approval. The
product requires safe beginner programming.
**Decision:** Build an intake → proposal → validation → user approval → transactional apply/revert
architecture. The AI never writes progression or completed workouts; the deterministic engine owns
load math.
**Consequences:** Requires new coach tables, an Edge gateway, a validator, consent records, audit
logs, and kill switches. Core training remains independent of AI.

## D-008 — Server-authoritative progression

**Status:** ACCEPTED (existing invariant)
**Context:** XP, levels, streaks, quests, PRs, and achievements are progression data.
**Decision:** `complete_workout` is the only award path. Clients may display estimates only. No
client or AI write access to progression tables.
**Consequences:** Any new mode or reward must be validated and awarded server-side. RLS/grants must
not be weakened.

## D-009 — No automatic Git writes

**Status:** ACCEPTED
**Context:** The workspace previously contained 166 uncommitted entries; losing them was the top
risk.
**Decision:** Agents never commit, push, tag, rebase, reset, clean, checkout, switch, or stash
without explicit approval. Checkpoints are recorded as branch/SHA/remote refs; tags require
approval.
**Consequences:** Work may remain uncommitted between sessions. The handoff must state the exact
tree state and preserve a verified external backup when needed.

## D-010 — Canonical memory files

**Status:** ACCEPTED (this bootstrap)
**Context:** M0 produced a report only in a chat transcript; a new session could not find it. The
project needs model-independent continuity.
**Decision:** Maintain the nine files listed in `AGENTS.md` §12 as the canonical process layer:
master index, audit record, project context, architecture, decisions, task board, handoff, and
changelog.
**Consequences:** Every task updates the board, handoff, and changelog. The original master plan is
preserved untouched and referenced, never overwritten.

## D-011 — Current baseline is `56c1122`

**Status:** RECORDED
**Context:** M0 observed HEAD `e003803` with 166 dirty entries. Between sessions the work was
committed as `56c1122` (381 files, +33,198/−8,080) and pushed to
`origin/codex/supabase-product-audit`.
**Decision:** Treat `56c1122` as the clean baseline. The M0 dirty-state finding is historical, not
current.
**Consequences:** G-02 in the defect register is resolved. The actor/timing of the commit is
unverified. Future audits must record the commit they ran against.

## D-012 — Documentation-only bootstrap

**Status:** ACCEPTED (explicit user instruction)
**Context:** The user authorized only the persistent memory/handoff system in this session.
**Decision:** Create/update the nine memory files only. Do not start M1 implementation, catalog
import, schema changes, UI refactors, or feature work.
**Consequences:** No application code, SQL, CI, or dependency changes. The next session starts at
M1-01 with explicit approval.

## D-013 — Verified external backup before edits

**Status:** ACCEPTED
**Context:** The user required preservation of the workspace before changes.
**Decision:** Create a Git bundle of all refs and a `git archive` of HEAD outside the working tree,
then verify: bundle clone HEAD == repository HEAD; archive file count == Git tree file count; record
SHA-256 hashes.
**Consequences:** Backup evidence is recorded in `SESSION_HANDOFF.md`. The backup is not a substitute
for an approved commit; it is a recovery artifact.

---

## Open decisions

These remain unresolved and block later milestones:

| ID | Question | Blocks | Owner |
|---|---|---|---|
| O-01 | GymLvl's own license and contributor rights | M8 / distribution | Project owner + legal |
| O-02 | AGPL posture (stay proprietary vs adopt AGPL) | Any OpenGym-derived reuse | Project owner + legal |
| O-03 | Approval of Drift | M3 | Project owner |
| O-04 | Approval of full 1,324 import vs curated subset | M2 | Project owner |
| O-05 | AI provider and cost policy | M6 | Project owner |
| O-06 | Android SDK/device availability | M1-02, M1-05, M8 | Project owner |
| O-07 | Live Supabase project and credential ownership | M2+ verification | Project owner |
| O-08 | Provenance of the 150 curated exercise texts | Catalog trust / M2 | Project owner |
| O-09 | Checkpoint tag name and creation approval | M1-01 | Project owner |
