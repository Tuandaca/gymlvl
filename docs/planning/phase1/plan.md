# Phase 1 — authentication and onboarding

Updated: 2026-10-26. This local plan is a scope/reference note, not a separate completion checklist.

Implement Supabase email/password registration, confirmation-aware sign-in, session restoration, sign-out, protected routing and recoverable errors. Public identity rows must be created by a trusted trigger, not by an unauthenticated confirmation-pending client.

Onboarding validates profile/schedule/class choices and initializes server-owned progression transactionally. The client cannot write level/XP/title/award state. Language, keyboard, narrow-layout and failure states require verification.

Authoritative status: [IMPLEMENTATION_STATUS.md](../../docs/IMPLEMENTATION_STATUS.md). Setup and release: [DEVELOPMENT.md](../../docs/DEVELOPMENT.md).

