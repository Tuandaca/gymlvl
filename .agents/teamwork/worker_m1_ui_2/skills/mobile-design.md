# Mobile Design Skill Summary & Local Reference

Source: `d:\Projects\gymlvl\.agent\skills\mobile-design\SKILL.md`

## Core Methodology
- Touch-first design: Minimum 48dp touch targets on Android, 44pt on iOS.
- Thumb-zone CTAs: Place high-frequency actions in the reachable lower zone.
- Micro-interactions: Tactile feedback, 80-140ms response curves, spring physics, downward-right translation for Neubrutalism button press.
- Responsive scaling: Support 320px small mobile to 1440px desktop without overflow or clipping. Extra vertical padding for Vietnamese diacritics in headers and badges.
- Const constructors and widget memoization in Flutter to avoid rebuild jank.
- Clean state and error recovery: empty states, error states with retry, clear loading states.
