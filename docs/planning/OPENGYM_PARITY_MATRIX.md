# GymLvl — OpenGym Parity Matrix

**Status:** Initial tracking framework (empty)
**Phase:** P1 — OpenGym Parity Baseline + Legal-Safe Exercise Catalogue (NOT STARTED)
**Purpose:** Track OpenGym capability vs GymLvl implementation status during P1. Detailed feature-by-feature parity analysis belongs to P1, not this document.

**Reference:** `DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (AGPL-3.0, behavioral reference only)

## Capability categories

| Category | OpenGym reference | GymLvl status | Classification | Notes |
|---|---|---|---|---|
| Exercise library | 6,554 exercises, search/filter, detail | 150 curated exercises, search/filter, detail | PARTIAL | Catalogue import pending P1 |
| Workout logging | Sets/reps/weight, timed holds, rest timer | Workout logging, active session, sets, rest timer, history | STRONG PARTIAL | Reuse existing GymLvl work |
| Routine & planning | Weekly routines, day assignment, scheduling | First-Week plan, newcomer journey | PARTIAL | P1 integration target |
| Progression | Linear, Greyskull, double, time, deload | Epley 1RM, PR detection, RPE/RIR, RPG bridge | PARTIAL | Reuse existing M4 work |
| Personal records | Est. 1RM (max 12 reps), PR charts | 1RM, PR detection | PARTIAL | Reuse existing M4 work |
| Advanced workout | Superset, timed exercise, cardio, screen awake | Supersets, modes, timers | PARTIAL | Reuse existing M3/M4 work |
| Analytics | History, heatmap, body map, muscle groups | Heatmap, weight trend, PR chart, muscle balance | PARTIAL | Reuse existing M5 work |
| Exercise utilities | Custom exercise, equipment profile, plan sharing | Not implemented | NOT STARTED | Evaluate in P2/P3 |
| AI planning | Intake, proposals, approval/revert, audit | Chat-only proxy only | NOT STARTED | P6, not P1 |
| RPG | Class, multi-class, synergy, quest, XP, level | Classes A–F, XP, levels, quests, streaks | PARTIAL | Preserve existing GymLvl RPG |

## License-excluded (do not import)

- OpenGym AGPL code, prompts, catalogue text, assets
- Gym visual media (images, GIFs, videos, thumbnails)
- Any media without explicit rights verification

## MIT-covered import candidates (P1)

- `hasaneyldrm/exercises-dataset` @ `7455efae41b330c265e7cd4b78dfa848e7ce5ebd`: ~1,324 text/metadata records, strip media, import with notice

## Tracking columns to populate in P1

- OpenGym feature ID / area
- GymLvl existing implementation (file paths)
- Classification: existing / partial / missing / deferred / license-excluded
- P1 action: reuse / adapt / import / defer / exclude
- Evidence: test file, migration, screen, or "not implemented"
