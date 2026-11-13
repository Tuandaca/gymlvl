# P9.6 lower-priority cleanup plan

**Scope:** Section 28 of the P9 request. Inspect named candidates, fix only
confirmed low-severity defects, and avoid a cosmetic refactor. Preserve
`main` at `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`, the verified dirty
owner/P9 worktree and all closed production gates. No Git or production write.

## Candidate audit

- `PlateBreakdown.toString()` refers to the current
  `PlateCalculationResult.toString()` in `plate_calculator.dart`. It prints the
  count as the denomination and rounds fractional denominations to one
  decimal. Existing tests check only broad number substrings. Add a RED test
  for count and 1.25 kg precision, then fix diagnostic text only.
- Inspect legacy theme/font code against actual app consumers; change only if
  a live mismatch or dead code with concrete impact is confirmed. The
  adversarial/UI regression harnesses currently default to the obsolete dark
  theme while the app uses Candy light theme; switch those harnesses to the
  production theme and registered current fonts, without changing assets.
  Bundled Archivo/Space Grotesk/Space Mono files have identical glyph tables
  to Inter and require a separate truthful font/provenance decision; no media
  procurement or silent replacement in P9.6.
- Inspect feature flags, misleading comments and compatibility code. Keep
  intentionally closed P9/M3 production flags and user-history compatibility.
  Correct verified stale backup/import comments and an internal FNV helper
  misnamed `_sha1` without changing fingerprint bytes.

## Ownership

- Lead: plate calculator/test, stale comments/internal helper name,
  integration and planning checkpoint.
- UI QA: the two regression harness files; no production UI or asset edits.
- Independent reviewers: read-only theme/font and feature/comment audits.

## Verification

- Focused plate regression RED then GREEN; relevant calculator tests.
- Full analyzer, format and Flutter tests after any code change.
- Isolated generated-code guard if source changes could affect generation.
- Record dispositions for every named candidate in the defect graph and the
  required task board/handoff/changelog.
