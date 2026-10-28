# S1 — External Skill Library Source Audit

**Session:** S1 (discovery and selection only)
**Date:** 2026-10-28
**GymLvl baseline:** `main` @ `b4063c6` (clean working tree at session start)
**External repository:** <https://github.com/Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI>
**Pinned commit:** `c4a059bbf7a8d6b2162071f0fbfe74053faa6d20`
**Default branch at pin:** `main`; last push `2026-06-11T05:08:42Z`
**License:** MIT (repository `LICENSE`, copyright 2026 Dokhacgiakhoa), with mixed upstream
provenance noted below.
**Status:** audit only. No repository content was executed, installed, or vendored.

> The external repository was treated as untrusted input. Only the GitHub tree API and
> `raw.githubusercontent.com` reads were used. No script, installer, hook, MCP server, CLI, or
> workflow from the library was run.

## 1. Scope and method

| Step | Method |
|---|---|
| Pin | Resolved the default branch head to `c4a059bb…` before reading |
| Inventory | Recursive Git tree (26,547 paths), names and metadata only |
| Shortlist | Keyword/domain filter over 575 skill directories |
| Deep read | 25 `SKILL.md` files (the session cap) plus 3 sub-skill modules |
| Supporting read | 6 agent templates, 6 rules, 6 workflows (full text); 1 agent headings only |
| Not read | The remaining 550 skills, 264 shared files, 17,000+ test fixtures, CLI/web source |

## 2. Inventory

| Resource class | Count | Location |
|---|---|---|
| Skills (`SKILL.md` each) | **575** | `.agent/skills/<name>/` |
| Agent templates | **51** | `.agent/agents/*.md` |
| Rules | **27** | `.agent/rules/*.md` |
| Workflows | **33** | `.agent/workflows/*.md` |
| Shared technical resources | 264 files | `.agent/.shared/` |
| All `.agent` files | 9,109 | `.agent/` |
| All repository files | 26,547 | repo root |

**Total named prompt resources inventoried: 686** (575 skills + 51 agents + 27 rules + 33
workflows). The 264 shared files are supporting references, not independently loadable skills.

Other top-level content exists but was **not** used: `cli/` (41 files), `scripts/` (25), `web/` (37),
`tests/` (17,272 fixtures), `setup.js`, `update.js`, `.github/` (3), and an MCP configuration at
`.agent/mcp_config.json`.

## 3. Structural model

- **Master skill + fractal sub-skills.** Most `SKILL.md` files are short indexes (0.8k–3k
  characters) that link to `sub-skills/*.md` (3–27 modules each). The index alone is often generic;
  the useful detail lives one level down.
- **Every referenced sub-skill exists.** Spot-checked all 25 shortlisted skills: 0 broken relative
  links. The package is internally consistent.
- **Several skills are thin wrappers** that add no standalone advice beyond "open
  `resources/implementation-playbook.md`" (e.g. `sql-optimization-patterns`,
  `data-quality-frameworks`, `code-review-excellence`).
- **Agent templates are long role prompts**, not machine-readable configuration. They assume a
  specific CLI (`npm start manager`, `npx prisma`, `npx playwright`).
- **Rules use a `trigger:` frontmatter field** (always_on / glob / model_decision) that is not an
  OpenCode native field.
- **Workflows use `$ARGUMENTS` and `/slash` conventions** from a different agent runtime, and several
  reference `GEMINI.md`, `walkthrough.md`, `task.md`, and their own DNA files.

## 4. Broken internal references

| Referenced from | Missing target |
|---|---|
| `.agent/agents/orchestrator.md` | `.agent/.shared/ai-master/ORCHESTRATION_PROTOCOL.md` |
| `.agent/agents/orchestrator.md` | `.agent/AGENT_FLOW.md` |
| `.agent/agents/orchestrator.md` | `.agent/MASTER_GUIDE.md` |
| `workflows/orchestrate.md` | `npm start manager` / `cli/index.js` runtime, `security_scan.sh`, `lint_check.sh` |

The templates remain usable as prose, but any direct import would carry dangling instructions.

## 5. Licensing and provenance

- Repository license is **MIT**; reuse requires the copyright and permission notice.
- The MIT file also lists upstream inspiration: Antigravity Kit (`vudovn`), Antigravity Awesome
  Skills and UI/UX Pro Max (`sickn33`), MCP standards, Vercel/antfu, Fabric.
- **Per-skill provenance is inconsistent.** Examples found in frontmatter or body:
  - `systematic-debugging` — "Source: obra/superpowers".
  - `context-window-management` — "source: vibeship-spawner-skills (Apache 2.0)".
  - `agent-security-review` — `author: affaan-m`.
- Consequence: a single repository-level MIT notice is **not sufficient attribution** for every
  module. S2 must keep a per-skill provenance ledger and import only skills whose provenance is
  recorded and compatible.

## 6. Security observations

| Observation | Risk | Handling |
|---|---|---|
| Skills instruct agents to run bundled scripts (`mobile_audit.py`, `lighthouse_audit.py`, `security_scan.sh`, `lint_check.sh`) | Untrusted code execution | Never execute; adapt to project-native commands |
| `mcp_config.json` installs `@upstash/context7-mcp` and `shadcn` via `npx` | Supply-chain and network exposure | Do not install; no MCP changes in S1/S2 without approval |
| Workflows invoke `npm start manager`, `npx expo prebuild`, browser scraping | Automated actions outside project policy | Strip from any adaptation |
| Agent prompts assert mandatory questions and "stop" gates | Prompt-injection style control over the agent | Re-write as project-owned instructions; never follow verbatim |
| Skills reference production DDL and zero-downtime backfills | Destructive-change risk | Project additive-only rule overrides |

No secrets were found in the inspected files. The MCP config contains only placeholder API keys.

## 7. OpenCode compatibility

| Artifact | Compatibility | Required adaptation |
|---|---|---|
| `SKILL.md` with YAML `name` + `description` | Structurally compatible with OpenCode skills | Add GymLvl trigger text, provenance header, and remove unsupported fields or leave them inert |
| Master + sub-skill links | Compatible as progressive disclosure | Vendor only needed modules; do not copy all sub-skills |
| Agent templates | Not an OpenCode agent config | Re-author as OpenCode agent definitions (name, description, mode, tools/permissions) |
| Rules with `trigger:` | Not native | Convert to `AGENTS.md`/agent instructions or OpenCode rules |
| Workflows with `$ARGUMENTS` | Not native | Convert to OpenCode commands or documented procedures |
| `.agent/mcp_config.json` | Different config path and runtime | Do not port |

Environment check: the GymLvl repository has **no `opencode.json` and no `.opencode/` directory**.
OpenCode is configured globally on this machine, so S2 must confirm the exact project-level skill and
agent paths against the installed OpenCode Desktop version before creating anything.

## 8. Existing local state (important)

The GymLvl working tree already contains a **gitignored `.agent/` directory** (1,043 files):

- 9 skills: `ai-engineer`, `api-documenter`, `database-migration`, `full-stack-scaffold`,
  `mcp-builder`, `mobile-design`, `modern-web-architect`, `performance-engineer`,
  `tdd-master-workflow`.
- 6 agents: backend, debugger, frontend, mobile-developer, orchestrator, project-planner,
  test-engineer.
- 14 rules including `GEMINI.md`, `code-quality.md`, `testing-standard.md`, `security.md`.
- It is an **older, different edition**: local `mobile-design/SKILL.md` is 15,304 bytes versus 2,051
  bytes at the pinned upstream commit.
- `.gitignore` ignores `.agent/` even though its comment says the folder is safe to commit.

Also present and tracked: `.agents/teamwork/` (120 files) from the earlier multi-agent run. Both
directories are user/agent work and must not be modified or deleted in S1/S2 without an explicit
decision. S2 must choose **reuse, supersede, or ignore** rather than silently creating a third copy.

## 9. Top risks

| ID | Risk | Mitigation |
|---|---|---|
| R1 | Context bloat from 575 skills and fractal sub-skills | Lazy loading; ≤3 skill packages per task; index-only default |
| R2 | Conflicting design guidance (palettes, dark mode) against Candy | Candy tokens are authoritative; import only a11y/touch/layout modules |
| R3 | Commit/push and destructive Git instructions inside skills | Project `AGENTS.md` overrides; no Git writes by any agent |
| R4 | Untrusted scripts and MCP installers | Never execute; no MCP changes |
| R5 | License/provenance gaps for some modules | Per-skill ledger; import only recorded MIT-compatible sources |
| R6 | Duplicate local `.agent` install | Reconcile in S2 before vendoring |
| R7 | Generic enterprise advice (Airflow, Spark, Kubernetes) | Reject non-applicable skills |
| R8 | Skills that assume web/React/Playwright | Adapt to Flutter/Deno; otherwise reject |
| R9 | Agents editing the same files in parallel | Single-writer rule; orchestrator owns file ownership |
| R10 | Memory duplication (vector DB, knowledge graph) | File-based memory remains canonical |
