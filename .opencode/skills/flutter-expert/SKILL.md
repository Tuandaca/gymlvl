---
name: Flutter Expert
description: Dart 3 and Flutter 3 widget, state, routing, and performance guidance for GymLvl. Use when implementing or refactoring a screen, widget, Riverpod notifier, router guard, or Flutter test.
---

# Flutter Expert

## When to use

- Building or changing a screen, widget, or reusable component.
- Adding or reshaping a Riverpod provider/notifier.
- Touching routing, redirects, or session gates.
- Diagnosing rebuilds, jank, layout overflow, or disposal bugs.

## When not to use

- SQL, RLS, migrations, or Edge Functions → `postgres-best-practices`.
- Design tokens, colour, or accessibility policy → `ui-ux-specialist`.
- Pure test-strategy questions → `test-driven-development`.

## Project invariants (these override any generic advice)

1. **Riverpod 3.1**, with `riverpod_annotation` 4 codegen. Use the patterns already in
   `app/lib/`. Do not introduce Bloc, GetX, Provider, MobX, Redux, or Stacked.
2. **Feature-first layout.** New code goes in `app/lib/features/<feature>/{data,domain,presentation}`.
   Shared infrastructure goes in `app/lib/core/`.
3. **The client never writes progression.** XP, levels, streaks, quest rewards, PRs, and completed
   workouts come from the server. A provider may *preview* a number; it must not persist one.
4. **Candy design tokens only.** Read colours, spacing, and type from the theme. Do not hardcode a hex
   value or invent a palette.
5. **Both locales must render.** Any user-visible string goes through localization; verify Vietnamese
   diacritics, not just English.
6. **Do not change dependencies.** No `pubspec.yaml` edit without explicit approval.

## Working method

1. **Locate before writing.** Find the existing feature folder, its repository, and its provider.
   Reuse the established shape rather than inventing a parallel one.
2. **Model the state.** Decide whether the change is local widget state, a `Notifier`, or a
   `FutureProvider`. Server-owned data is read through a repository, not fetched in `build`.
3. **Write the widget.** Prefer small `const` widgets over one large `build`. Extract a widget when a
   subtree rebuilds for an unrelated reason.
4. **Handle the async edges.** Every `await` in a widget has a `mounted`/`context.mounted` guard.
   Every controller, listener, and subscription is disposed.
5. **Verify.** `flutter analyze` must be clean for the touched files; run the relevant
   `flutter test` target.

## Widget rules that matter here

- `const` constructors wherever the inputs are constant — it is the cheapest rebuild win available.
- Give list items a stable `ValueKey`; do not use the index for reorderable or filtered lists.
- Keep `build` free of I/O, formatting loops, and provider reads that could be hoisted.
- Use `ListView.builder`/`SliverList` for the exercise and history lists; never `Column` inside a
  scroll view for unbounded data.
- Wrap long text in `Flexible`/`Expanded`; assume Vietnamese labels are 20–30% wider than English.
- Respect `SafeArea` and the minimum 48×48 touch target.
- Prefer `Theme.of(context)` lookups once per `build`, not per child.

## Riverpod rules

- One notifier per feature concern; keep derived values in `Provider`s rather than recomputing in
  widgets.
- Do not call `ref.read` inside `build` for values that should trigger a rebuild — use `watch`.
- `ref.listen` for side effects (navigation, snackbars), not for state derivation.
- Dispose timers, stream subscriptions, and `TextEditingController`s in `ref.onDispose`.
- Never store a `BuildContext` in a notifier.

## Anti-patterns

| Anti-pattern | Why it hurts here |
|---|---|
| `setState` around server data | Duplicates the repository as a second source of truth |
| Business logic in `build` | Runs on every frame; hides testability |
| Catching and swallowing an error | Breaks the `PASS`/`FAIL` evidence trail |
| `!` on a nullable provider value | Crashes the screen instead of showing a state |
| Copying a widget "just to tweak it" | Creates two divergent screens |
| Adding a package to solve a layout issue | Unapproved dependency, review burden |

## Verification

```text
flutter analyze
flutter test test/<target>_test.dart
```

Report the exact command and its result. A clean analyze is not a passing feature.

---

*Adapted for GymLvl from `Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI` @ `c4a059bb`, path
`.agent/skills/flutter-expert/`. MIT, © 2026 Dokhacgiakhoa. Rewritten: Riverpod 3 replacing Riverpod
2.x, non-Flutter state libraries removed, sub-skill modules not vendored. See
`docs/agent-system/THIRD_PARTY_NOTICES.md`.*
