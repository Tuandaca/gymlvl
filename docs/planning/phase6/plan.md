# Phase 6 — deployment and launch

Updated: 2026-10-26. This local plan is a scope/reference note, not a separate completion checklist.

Use docs/DEVELOPMENT.md for Supabase release steps. Identify the project, compare local/remote history, review every migration, verify a recovery path for affected data, pass local checks, then deploy non-destructive migrations and authenticated Edge Functions. No production reset or blind schema overwrite.

Web hosting, store identities/signing, privacy policy, screenshots and physical-device/network acceptance require actual configured targets. No provider or destination is assumed. Record deployed project/version/results only after real execution. Missing Docker/provider/signing/hosting credentials are blockers, not passing gates.

Authoritative status: [IMPLEMENTATION_STATUS.md](../../docs/IMPLEMENTATION_STATUS.md). Setup and release: [DEVELOPMENT.md](../../docs/DEVELOPMENT.md).

