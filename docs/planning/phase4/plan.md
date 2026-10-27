# Phase 4 — AI Coach

Updated: 2026-10-26. This local plan is a scope/reference note, not a separate completion checklist.

Original scope: text/chat (optional voice), bounded user profile and recent workout context, a server-side AI proxy, safe advice, timeout/rate-limit/provider-failure behavior, and manual-workout fallback. The old Gemini/Claude examples did not select or configure a provider.

Use the configured server-only compatible chat endpoint described in DEVELOPMENT.md. No provider secret may be shipped to Flutter. FastAPI remains optional and unimplemented. Automatic workout actions, technique tools, voice, and body-metric logging are future scope requiring confirmation and audited mutation contracts; generated advice must never grant XP or become a workout record automatically.

Authoritative status: [IMPLEMENTATION_STATUS.md](../../docs/IMPLEMENTATION_STATUS.md). Setup and release: [DEVELOPMENT.md](../../docs/DEVELOPMENT.md).

