# Phase 2.8 — class progression reference

Updated: 2026-10-26. This local plan is a scope/reference note, not a separate completion checklist.

The implementation uses user_classes rather than an authoritative active_classes JSON field on profiles. Primary/secondary choice, synergy, XP allocation and class switching must be validated on the server. Profile input is not permission to set class XP or level.

CLASS_SYSTEM_SPEC.md retains design vocabulary; actual tested rules are in PROGRESSION_GUIDE.md. Any future graduation locks or retrospective rules require explicit eligibility and idempotency regression tests.

Authoritative status: [IMPLEMENTATION_STATUS.md](../../docs/IMPLEMENTATION_STATUS.md). Setup and release: [DEVELOPMENT.md](../../docs/DEVELOPMENT.md).

