# Future proposal — admin panel

Updated: 2026-10-26. This local plan is a scope/reference note, not a separate completion checklist.

The latest historical commit documented a possible Next.js admin portal. There is no admin application, deployed API, admin_accounts schema, custom-role provisioning, or current release dependency. Preserve docs/admin as a future proposal.

Before implementation, define least-privilege roles, server-managed app_metadata claims, column/table grants, RLS, audited transactions and revocation. Browser clients use a publishable key plus user session. Service-role keys remain server-side. Do not copy the top-level JWT database role into an application-role design.

Authoritative status: [IMPLEMENTATION_STATUS.md](../../docs/IMPLEMENTATION_STATUS.md). Setup and release: [DEVELOPMENT.md](../../docs/DEVELOPMENT.md).

