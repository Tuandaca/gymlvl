# P9.4 AI trainer hardening plan

## Current boundary

The Edge Function is the authoritative 7-day context builder: it reads an
authenticated owner's profile and completed workout summaries. The PT client
context currently contains empty workout/set arrays and synthetic readiness;
the Edge Function ignores the submitted `context` object, while the client
prompt leaks the account UUID and unverified placeholder counts upstream.
The PT screens invoke AI on opening. The older chat screen has a visible
disclosure and an explicit Send action. The Edge response is text only, so
PT recommendations must remain advisory and unvalidated.

## Ordered implementation

1. Add Edge RED tests: absent/false per-request consent prevents quota,
   context fetch and external egress; client `context` is not treated as
   verified context; provider prompt contains no account UUIDs. Preserve
   malformed input and quota ordering.
2. Require explicit `consent: true` at the Edge boundary. The PT screens show
   VI/EN disclosure and a Generate action before watching the recommendation
   provider. Chat Send remains the explicit action after its disclosure and
   sends consent. Remove the client `context` payload and UUID/placeholder
   facts from PT prompt; server context remains bounded and owner-scoped.
3. Keep text output advisory with no validated actionable items. Check the
   existing human-approval application path and ensure it cannot apply text
   as a structured recommendation.
4. Run focused Edge, Flutter, analyzer, format, full regression and record
   remaining quality debt. No new provider, media, schema, or production write.

## Local checkpoint (2026-11-13)

Implemented D-054. Independent review found incomplete VI/EN disclosure,
an asynchronous persisted-locale race, and stale post-response wording; all
were corrected. The longer chat disclosure then failed narrow bilingual
viewport tests, so it was bounded and made scrollable. Final Flutter suite:
803/803 PASS; Edge checks/tests: 58/58 PASS; Dart format: 306/0 PASS;
analyzer: FAIL with 60 warnings/info issues. Production Edge deployment and
live provider validation were NOT RUN. No Git or production write.
