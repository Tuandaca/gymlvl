# P9 analyzer quality plan

**Scope:** Section 27 of the P9 request and the current `TASK_BOARD.md` task.
Baseline `flutter analyze` on 2026-11-13 at `main` `c68e577` returned 60
issues: zero errors, warnings and info lints. The CI command fails on those
diagnostics. Keep the dirty owner/P9 worktree and production gates intact.

## Method

1. Group diagnostics by owning file and rule. Remove dead/unused code without
   losing awaited side effects or test coverage. Fix info lints through local
   syntax changes, not global suppression.
2. For a warning that reveals a behavior defect, write a focused failing test
   before changing source. The generic CSV `workout` column fallback is the
   first confirmed example.
3. Avoid a new dependency policy. Replace the single transitive `collection`
   use with equivalent local equality over `ImportedSet` elements.
4. Run focused analyzer/tests per owner, then full `flutter analyze`, format,
   Flutter tests, and isolated generated-code guard. Review changed paths and
   record exact results in board/handoff/changelog.

## File ownership

- Analytics specialist: `csv_import_service.dart`, `backup_import_service.dart`,
  `import_models.dart` under `app/lib/features/analytics`.
- AI specialist: `routine_application_service.dart` and two AI trainer test
  files with unused imports.
- UI specialist: CSV export, exercise progress, body measurements, onboarding
  controller and unlock card files with info lints.
- QA: the ten test files named by the baseline diagnostics.
- Lead: `supabase_workout_repository.dart`, the new generic CSV fallback test,
  integration verification, planning and defect records.

## Acceptance

- `flutter analyze` exits 0 with `No issues found!`.
- The generic CSV `date,workout,reps,weight` RED test becomes GREEN.
- Relevant focused tests and the full Flutter suite pass.
- Full isolated code generation still matches all tracked generated outputs.
- No unrelated path, dependency, global lint suppression, Git ref or
  production resource is changed.
