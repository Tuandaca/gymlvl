---
description: Implement a mobile-first GymLvl screen or flow
agent: ui-ux-specialist
---

Implement this mobile-first work: $ARGUMENTS

## Before writing

1. Read the neighbouring screen and reuse its structure.
2. Confirm the layout in both `en` and `vi`, at 320 dp, 390 dp, and 768 dp.
3. Identify the Candy tokens you will use. If one is missing, add a theme token — never a literal.

## Requirements

- Safe areas respected on notch and gesture-bar devices.
- 48×48 minimum touch targets; primary actions reachable in the thumb zone.
- One clear primary action per screen; secondary actions visually subordinate.
- Scrollable content for short heights and 200% text scale, with no overflow.
- Loading, empty, error, and offline states designed — not just the happy path.
- Semantics labels on icon-only controls; reading order matches visual order.
- Vietnamese diacritics verified in the rendered font.

## Boundaries

- You own presentation, theme, and l10n only. Business logic goes to `flutter-specialist`.
- No new packages, icon packs, fonts, or animation libraries.
- No dark-mode variant and no alternative palette. Bold Candy is authoritative.
- No mock data left in a screen that should read from a provider.

## Verify

```text
flutter analyze
flutter test test/<relevant>_test.dart
```

Then have `qa-reviewer` check the narrow-width and large-text cases. A screen that only works at
390 dp with default text is not done.
