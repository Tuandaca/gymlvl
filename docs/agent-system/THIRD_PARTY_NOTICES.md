# Third-Party Notices — Agent Resources

**Status:** active ledger. Every adapted resource must have a row here before it is written into
`.opencode/`.
**Source repository:** <https://github.com/Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI>
**Pinned commit:** `c4a059bbf7a8d6b2162071f0fbfe74053faa6d20`
**Retrieved:** 2026-10-28
**License:** MIT — Copyright (c) 2026 Dokhacgiakhoa

## 1. What "adapted" means here

GymLvl does not vendor upstream files. Each imported skill is **rewritten** as a short,
project-native instruction document that:

- keeps the method or principle that made the upstream skill useful;
- removes stack assumptions that do not apply (React, Prisma, Playwright, Node, Airflow);
- removes every script invocation, installer, MCP configuration, and Git write command;
- adds GymLvl invariants that override conflicting upstream advice;
- credits the source path and upstream provenance in a footer.

The upstream text is therefore not reproduced verbatim, and no upstream executable content is
installed. The MIT notice below is preserved because the adapted works are derived from MIT-licensed
material.

## 2. MIT license notice

```text
MIT License

Copyright (c) 2026 Dokhacgiakhoa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 3. Ledger

| # | Local artifact | Upstream path | Upstream provenance | License | Adaptation notes |
|---|---|---|---|---|---|
| 1 | `.opencode/skills/flutter-expert/SKILL.md` | `.agent/skills/flutter-expert/` | Repository original | MIT | Riverpod 2.x replaced with Riverpod 3.1; Bloc/GetX/MobX/Provider/Stacked recommendations removed; web/desktop/embedded scope removed; sub-skill links not vendored |
| 2 | `.opencode/skills/postgres-best-practices/SKILL.md` | `.agent/skills/postgres-best-practices/` | Repository original | MIT | Prisma and Supabase-JS application guidance removed; kept RLS, index, JSONB, pooling rules; added additive-migration and `complete_workout` invariants |
| 3 | `.opencode/skills/postgresql/SKILL.md` | `.agent/skills/postgresql/` | Repository original | MIT | Condensed to schema-design rules for this project; removed partitioning, pgvector, PostGIS, TOAST, collation, and time-series material; "safe evolution" reworded to additive-only |
| 4 | `.opencode/skills/test-driven-development/SKILL.md` | `.agent/skills/test-driven-development/` | Repository original | MIT | Removed the "delete production code" absolutism and per-task commit steps; mapped Red/Green/Refactor to `flutter test`; added preserve-user-work override |
| 5 | `.opencode/skills/systematic-debugging/SKILL.md` | `.agent/skills/systematic-debugging/` | **`obra/superpowers`** (recorded in upstream frontmatter body) | MIT (repository); upstream project MIT | Upstream file is an index only. The four phases and 5-Whys method were written out from the referenced method; added Flutter/Supabase evidence commands |
| 6 | `.opencode/skills/context-window-management/SKILL.md` | `.agent/skills/context-window-management/` | **`vibeship-spawner-skills` (Apache 2.0)** — recorded in upstream frontmatter | Apache-2.0 upstream | Upstream is an index only. Wrote a file-based adaptation limited to tiering, serial position, and summarization; **no** vector store, embedding, or external memory. Apache-2.0 attribution retained here |

## 4. Deliberately not imported

| Resource | Reason |
|---|---|
| `.agent/mcp_config.json` | Installs third-party MCP servers via `npx`; supply-chain exposure |
| `.agent/scripts/*` | Executable content; never run per `AGENTS.md` |
| `.agent/agents/*.md` | Written for another CLI runtime; re-authored instead |
| `.agent/rules/*.md` | Use a non-native `trigger:` schema and reference `GEMINI.md` |
| `.agent/workflows/*.md` | Contain `npm start manager`, browser scraping, and shell blocks |
| `ui-ux-pro-max`, `mobile-design`, `i18n-localization`, `accessibility-*` | Deferred to wave 2; design conflicts must be resolved first |
| 14 remaining selected skills | Wave 2, gated on wave 1 validation |

## 5. Attribution obligation for redistributors

If GymLvl is redistributed, this file must ship with it, together with the MIT notice in §2 and the
Apache-2.0 attribution for the context-management adaptation in §3 row 6. The Apache-2.0 upstream
notice was not reproduced verbatim because its full text was not retrieved in S1; S2 records only the
provenance string from the upstream frontmatter. **Before any public release, retrieve and include the
full Apache-2.0 license text, or replace skill 6 with an original GymLvl document.** This is recorded
as an open item in `DECISIONS.md`.
