# S1 — Skill Selection

**Source:** `Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI` @
`c4a059bbf7a8d6b2162071f0fbfe74053faa6d20` (MIT, mixed provenance — see `SOURCE_AUDIT.md`)
**Baseline:** GymLvl `main` @ `b4063c6`
**Selection size:** 20 skills, 6 rules, 6 workflows, 5 agent templates

## 1. Evaluation criteria

| Criterion | Weight | Meaning |
|---|---|---|
| Relevance | 30% | Applies to Flutter/Dart/Riverpod or Supabase/PostgreSQL/Deno |
| Correctness | 20% | Technically accurate for the pinned stack versions |
| Compatibility | 15% | Usable in OpenCode with limited rewriting |
| Context efficiency | 15% | Index first; sub-skills loaded on demand |
| Non-redundancy | 10% | Adds something the project lacks |
| Safety | 10% | No scripts, no Git writes, no destructive actions |

A skill was rejected if it scored poorly on relevance or safety regardless of quality.

## 2. Selected skills (20)

Paths are relative to `.agent/skills/` at the pinned commit.

| # | Skill | Category | Why selected | Required adaptation |
|---|---|---|---|---|
| 1 | `flutter-expert` | Flutter | Only Flutter-specific package; Dart 3/widget/perf coverage | Says "Riverpod 2.x"; project is Riverpod 3.x. Replace with project state conventions |
| 2 | `mobile-design` | Flutter / UX | Touch targets, thumb zone, Fitts' law, mobile anti-patterns | Strip the mandatory script (`mobile_audit.py`); read `flutter-critical-rules.md` only |
| 3 | `postgres-best-practices` | Supabase | Concise Supabase-specific PG guidance: RLS, JSONB, indexing, pooler | Remove Prisma/JS examples; keep RLS and JSONB rules |
| 4 | `postgresql` | PostgreSQL | Strongest schema/data-type/constraint reference in the library | Keep; project additive-migration rule overrides "gotchas" that suggest rewrites |
| 5 | `database-migrations-sql-migrations` | PostgreSQL | Expand/contract, validation, rollback discipline | Pre-release project: adopt safety checks, skip zero-downtime choreography |
| 6 | `ui-ux-pro-max` | UI/UX | Accessibility, touch, layout, typography modules are actionable | **Do not** import palettes/styles; Candy design system is authoritative |
| 7 | `accessibility-compliance-accessibility-audit` | UI/UX | WCAG audit structure and severity mapping | Map web ARIA advice to Flutter `Semantics`; drop HTML-specific items |
| 8 | `i18n-localization` | Localization | VI/EN concepts, pluralization, locale handling | Framework modules are React/Next/Python; keep concepts only |
| 9 | `test-driven-development` | Testing | Red-green-refactor discipline and "watch it fail" rule | Remove "delete production code" absolutism; never delete user work |
| 10 | `e2e-testing-patterns` | Testing | Critical-journey selection, flake control, CI artifacts | Replace Playwright/Cypress with Flutter integration tests and the Node harness |
| 11 | `systematic-debugging` | Debugging | 4-phase reproduce → isolate → understand → verify | Sub-skills sourced from `obra/superpowers`; record provenance |
| 12 | `dispatching-parallel-agents` | Orchestration | Clear parallel-vs-sequential decision rule | Enforce single-writer file ownership; no parallel edits to the same file |
| 13 | `subagent-driven-development` | Orchestration | Best end-to-end subagent workflow: implement → spec review → quality review | Remove per-task commits and `superpowers:*` dependencies; adapt to OpenCode |
| 14 | `context-management-context-save` | Context | Structured checkpoint capture for multi-session work | Drop vector DB / knowledge graph; save to the nine memory files |
| 15 | `context-management-context-restore` | Context | Session resumption and conflict handling | Same: file-based subset only |
| 16 | `context-window-management` | Context | Tiered context, serial-position, anti-truncation patterns | Apache-2.0 upstream source noted; verify notice compatibility before import |
| 17 | `architecture-decision-records` | Architecture | MADR/lightweight ADR templates map to `DECISIONS.md` | Keep MADR-lite; no `adr-tools` automation |
| 18 | `agent-security-review` | Security | Auth, secrets, input validation, SQL injection, rate limits | Add Supabase RLS/Edge specifics; drop Solana/blockchain module |
| 19 | `code-review-excellence` | QA | Severity-grouped review output and test notes | Thin wrapper; pair with existing project review rules |
| 20 | `data-quality-frameworks` | Data / catalog | Quality dimensions and validation contracts for imports | Replace Great Expectations/dbt with SQL assertions and catalog checks |

**Context cost of the 20 indexes:** ~35,600 characters (~9k tokens). Sub-skills are loaded only when
the task needs them; the routing matrix caps that at two modules per task.

## 3. Rejected skills (with reasons)

| Skill | Reason |
|---|---|
| `mobile-developer` | Redundant with `flutter-expert`; React Native/native breadth dilutes Flutter focus |
| `frontend-dev-guidelines` | React + TypeScript + MUI + TanStack; wrong stack |
| `sql-optimization-patterns` | Thin wrapper; no content beyond `postgresql` + playbook |
| `database-design` | Thin decision list; subsumed by `postgresql` |
| `database-migration` | 905-character stub; superseded by the SQL migrations skill |
| `sql-pro` | Generic OLTP/OLAP; overlaps `postgresql` without Supabase specifics |
| `data-engineering-data-pipeline` | Airflow/Spark/Delta Lake/Kafka; enterprise overkill for a single ETL import |
| `unit-testing-test-generate` | Redundant with TDD + the existing 126-test Flutter suite |
| `testing-patterns` | Thin pyramid/AAA index; project already follows this |
| `debugging-strategies` | Overlaps `systematic-debugging`; less structured |
| `agent-orchestration` | LangGraph/AutoGen framing; no OpenCode primitives; our matrix covers it |
| `multi-agent-brainstorming` | Useful but overlaps planning/review; adds process weight |
| `performance-profiling` | Core Web Vitals/Lighthouse; not Flutter profiling |
| `agent-memory-systems` | Duplicates the nine memory files and context skills |
| `architecture-patterns` | Clean/Hexagonal/DDD advocacy conflicts with existing feature-first layout |
| `screen-reader-testing` | Web screen-reader focus; Flutter semantics differ |
| `nextjs-supabase-auth`, `neon-postgres`, `postgres-mcp` | Wrong framework/provider/tooling |
| All pentest/cloud/blockchain/SEO/growth skills | Out of scope and violate project boundaries |

## 4. Selected rules (6)

| Rule | Path | Use | Conflict to resolve |
|---|---|---|---|
| Strict protocol | `rules/strict-protocol.md` | Reinforces "no push without approval" | References `GEMINI.md` and `/protocol-reset`; keep the Git rule only |
| Code quality | `rules/code-quality.md` | Anti-patterns, naming, error handling | JS/TS naming; translate to Dart conventions |
| Database | `rules/database.md` | 3NF, FK indexes, migration safety, rollback | "Always add updated_at"/soft delete may not fit existing tables; do not retrofit |
| Testing standard | `rules/testing-standard.md` | Pyramid, AAA, coverage targets | Coverage percentages are aspirational; keep behavior-first |
| UI design | `rules/ui-design.md` | Spacing, hierarchy, contrast | Mandates dark mode and glassmorphism; **reject those parts** |
| Security | `rules/security.md` | Secrets, SQL injection, incident protocol | Generic web advice; add RLS and Edge-function rules |

Rejected rules: `architecture-review`, `backend`, `frontend`, `business`, `compliance`, `devops`,
`growth-strategy`, `logging-monitoring`, `malware-protection`, `runtime-watchdog`, `system-update`,
`system-reasoning`, `docs-update`, `error-logging`, and the three `GEMINI.*` variants. They either
duplicate `AGENTS.md` or target a different runtime.

## 5. Selected workflows (6)

| Workflow | Adaptation |
|---|---|
| `workflows/plan.md` | Keep the discovery → plan → user-approval gate; drop `GEMINI.md` DNA references |
| `workflows/orchestrate.md` | Keep phase separation and review loop; drop `npm start manager`, browser scraping, `walkthrough.md` |
| `workflows/test.md` | Map to `flutter test`, SQL harness, and Edge tests; keep "test must fail first" |
| `workflows/audit.md` | Map to `AGENTS.md` §5 status vocabulary and Definition of Done |
| `workflows/debug.md` | Keep evidence-first RCA; map incident log to `CHANGELOG_AI.md`, not `ERRORS.md` |
| `workflows/mobile.md` | Keep mobile-first, safe areas, device matrix; **remove** `npx expo prebuild` |

Rejected workflows: `deploy`, `release-version`, `seo`, `growth-max`, `portfolio`, `blog`, `preview`,
`realtime`, `monitor`, `update`, `compliance`, `deep-security-audit` (pentest-oriented),
`performance-max` (web), `ui-ux-pro-max` (duplicates the skill).

## 6. Selected agent templates (reference only)

| Template | Reuse |
|---|---|
| `orchestrator.md` | Delegation matrix, conflict arbitration, anti-patterns; rewrite for OpenCode |
| `test-engineer.md` | Risk-based test discovery, flaky-test triage, pyramid |
| `database-architect.md` | Schema discovery questions, expand/contract, DB anti-patterns |
| `quality-inspector.md` | "Ready for operations" gate and rejection protocol |
| `codebase-expert.md` | Impact analysis and consistency enforcement |

Rejected templates: `frontend-specialist`, `backend-specialist` (generic web/Node),
`accessibility-expert`, `i18n-specialist` (web-only, thin), `project-planner` (duplicates
`TASK_BOARD.md`), `security-pentester`/`penetration-tester` (out of scope), cloud/devops/SEO agents.

## 7. Attribution requirements

Every imported module must carry:

1. Source repository URL and pinned SHA `c4a059bb…`.
2. Original skill path.
3. License: MIT, copyright 2026 Dokhacgiakhoa, plus the upstream notice where the module records
   one (`obra/superpowers`, `vibeship-spawner-skills` Apache-2.0, `affaan-m`).
4. A statement that GymLvl adapted the text and does not execute upstream scripts.

A single `docs/agent-system/THIRD_PARTY_NOTICES.md` will hold the ledger in S2. Do not import a module
whose upstream provenance cannot be recorded.

## 8. Decision summary

- **Import now (S2, adapted):** 6 core skills — `flutter-expert`, `postgres-best-practices`,
  `postgresql`, `test-driven-development`, `systematic-debugging`, `context-window-management`.
- **Import second wave:** the remaining 14, only after the core loop is validated.
- **Never import verbatim:** rules with `GEMINI.md` dependencies, workflows with runtime commands,
  any script, MCP config, or agent prompt that assumes another CLI.
- **Local `.agent/` directory:** leave untouched; reconcile in S2 before installing anything.
