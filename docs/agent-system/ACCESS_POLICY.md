# Agent Access Policy (D-024)

**Status:** Active
**Established:** 2026-10-28
**Decision:** [`docs/planning/DECISIONS.md`](../planning/DECISIONS.md) D-024 — supersedes D-022 and
changes the mechanism of D-019.
**Scope:** `.opencode/opencode.jsonc` plus the `permissions` block of the seven agent definitions.
**Contract:** `AGENTS.md` outranks this document.

This file records **what the configuration actually enforces**, how that was verified, and what remains
unverified. It is not a description of intent. Every claim below names the command or file behind it.

---

## 1. Rule model (why the configuration is shaped the way it is)

OpenCode V2 evaluates permissions as an ordered rule list. Three properties drive the design:

1. **Last match wins.** The broad access rules are written first, and the approval gates after them.
   Reordering the array would silently disable the gates.
2. **Agent rules are appended after global rules.** An agent-level rule can restrict or widen the
   global set because it is evaluated later. A per-agent `shell "*" → allow` would therefore cancel
   every global `ask`.
3. **`*` matches across `/`.** One `edit "*"` rule covers every path depth.

Consequence: the orchestrator and the five development specialists carry **no `permissions` block at
all**. They inherit the global set exactly. `qa-reviewer` and `context-keeper` carry rules that only
restrict. This is deliberate and is the single most important thing to preserve when editing the
configuration.

Source: OpenCode V2 *Permissions* guide (`https://opencode.ai/v2/docs/permissions`), sections
*Matching*, *Agents*, *Actions*.

## 2. Effective permissions

| Agent | Mode | Edit | Shell | Web | Delegation | Notes |
|---|---|---|---|---|---|---|
| `gymlvl-orchestrator` | primary | any path | any command, gates apply | allow | six specialists | no agent rules |
| `flutter-specialist` | subagent | any path | any command, gates apply | allow | denied | no agent rules |
| `supabase-specialist` | subagent | any path | any command, gates apply | allow | denied | no agent rules |
| `exercise-catalog` | subagent | any path | any command, gates apply | allow | denied | no agent rules |
| `ui-ux-specialist` | subagent | any path | any command, gates apply | allow | denied | no agent rules |
| `qa-reviewer` | subagent | **denied** | allowlist, `deny` fallback | **denied** | **denied** | 41 agent rules |
| `context-keeper` | subagent | **denied** | allowlist, `deny` fallback | **denied** | **denied** | 21 agent rules |

Approval gates (`ask`) inherited by every agent unless that agent is stricter:

| Class | Examples |
|---|---|
| Git history rewrite | `git push --force*`, `-f`, `--mirror`, `--delete`, `<ref> +<ref>`, `reset --hard`, `rebase`, `filter-branch`, `commit --amend`, `branch -D`, `restore`, `checkout --`, `clean`, `stash drop|clear` |
| Bulk deletion | `Remove-Item -Recurse`, `rm -rf`, `rm -r`, `rmdir /s` |
| Production DB / deploy | `supabase db push`, `db reset --linked`, `db remote`, `link`, `unlink`, `functions deploy`, `projects`, `secrets`, `psql` |
| Secrets | read of `*.env`, `*.env.*`, `*.pem`, `*.p12`, `*.keystore`, `*.jks`, `*id_rsa*`, `*id_ed25519*`, `*.git-credentials`; the same files via `Get-Content`, `type`, `cat`, `more` |

Not gated, by design: `git commit`, `git fetch`, `git pull`, `git merge`, `git push` (normal),
`flutter pub add`, `dart run build_runner`, `supabase start|stop`, `supabase db reset` (local),
`npm`/`node` tooling, file creation and deletion inside the repository.

## 3. Static verification — effective permission simulation

The rule files are not proof of behaviour, so the effective rule set was rebuilt and resolved
programmatically: global rules first, agent rules appended, `*` and trailing-` *` semantics applied,
last match wins, no match ⇒ `ask`.

```text
node C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-perm-check.mjs D:\Projects\gymlvl
```

Result (2026-10-28, working tree at `425686c` + D-024 changes):

```text
PARSE .opencode/opencode.jsonc      : OK (73 global rules, default_agent=gymlvl-orchestrator)
PARSE gymlvl-orchestrator.md        : OK (0 agent rules, mode=primary)
PARSE flutter-specialist.md         : OK (0 agent rules, mode=subagent)
PARSE supabase-specialist.md        : OK (0 agent rules, mode=subagent)
PARSE exercise-catalog.md           : OK (0 agent rules, mode=subagent)
PARSE ui-ux-specialist.md           : OK (0 agent rules, mode=subagent)
PARSE qa-reviewer.md                : OK (41 agent rules, mode=subagent)
PARSE context-keeper.md             : OK (21 agent rules, mode=subagent)
RULES VALIDATED: 73 global + 62 agent
RESULT: PASS (0 probe failures, 0 schema problems)
```

66 probes covered: orchestrator edit on `app/`, `supabase/`, `docs/audit/` and `.opencode/`; normal
push versus five force-push forms; `reset --hard`, `clean`, `rebase`, `amend`; `flutter`/`dart`/`npm`
commands; bulk deletion; local versus production Supabase; webfetch/websearch; external directories;
secret reads through both the `read` tool and shell; delegation to an allowed specialist, a blocked
built-in (`general`), and the primary agent; and the reviewer read-only matrix.

The validator is kept outside the repository on purpose: it is a development tool, not program state.
Two probes initially failed and exposed real gaps, both fixed before this record was written — the
`.env` gate did not cover shell, and `Get-Content *.env` did not match `*.env.production`.

## 4. Runtime verification

| Check | Command / probe | Result |
|---|---|---|
| Config parsed by the server | `agent.updated` events at `2026-10-28T07:33:43.390Z` … `07:34:31.580Z`, one per file write | `PASS` |
| Active agent of the authoring session | `GET /api/session/ses_e7e999dd2ffdO3oGdRJnVFBuY1` → `"agent":"build"` | `PASS` — see §5 |
| Shell access (primary) | `node --version` → `v22.17.1`; `Get-ChildItem`, `Select-String`, `Remove-Item` all executed | `PASS` |
| Git read access | `git status --porcelain=v1`, `git log --oneline -8`, `git rev-parse HEAD`, `git ls-remote origin refs/heads/main` → `9c8e142…` | `PASS` |
| Web access | `webfetch https://opencode.ai/v2/docs/permissions` → 200, full page | `PASS` |
| Orchestrator write, previously denied path | `opencode run --agent gymlvl-orchestrator …` wrote `app/.perm-probe-2.md`; independent `Test-Path` → `True`, `Get-Content` → `probe` | `PASS` |
| Orchestrator shell, previously denied command | same session: `node --version` → `v22.17.0` | `PASS` |
| Delegation | `subagent(qa-reviewer)` completed a review | `PASS` |
| Reviewer write denial | qa-reviewer: `Set-Content docs/audit/.qa-write-probe.md` → `{"error":{"type":"permission.rejected","message":"Permission denied: shell"}}` | `PASS` (denied) |
| Reviewer Git write denial | qa-reviewer: `git commit --allow-empty -m "probe"` → `permission.rejected`; `git rev-parse --short HEAD` unchanged | `PASS` (denied) |
| Reviewer has no write tool | qa-reviewer: `tools.write` / `tools.edit` → `Unknown tool` | `PASS` (absent) |
| Reviewer web denial | rule-based; not exercised at runtime | `NOT RUN` |
| Secret gate at runtime | no `.env`, `.pem` or key file exists in the workspace | `NOT RUN` — blocked by absence of a fixture |
| Android/iOS build after config change | not attempted; no product file changed | `NOT RUN` |

## 5. How the active agent is proven

The authoring session is `ses_e7e999dd2ffdO3oGdRJnVFBuY1`. Its server record reports
`"agent":"build"`, so this document and the D-024 change were written by the built-in **build** agent,
not by the orchestrator. The orchestrator was exercised in separate throwaway sessions through
`opencode-cli.exe run --agent gymlvl-orchestrator`, which is the only reliable way to bind a primary
agent (D-023: `default_agent` is a session-creation default, not a live switch).

Two honest caveats from that exercise:

1. The first orchestrator probe reported a successful write of `app/.perm-probe-orchestrator.md` and
   `Test-Path` → `True` inside that session, but the file was absent when the cleanup step ran
   minutes later. The cause was not established. The probe was therefore repeated with the assertion
   made from a **different** session (`Test-Path` → `True`, `Get-Content` → `probe`), and only that
   second result is relied on. A nested session's self-report is not independent evidence.
2. `opencode-cli.exe` returns exit code 1 after a successful run because PowerShell raises
   `NativeCommandError` on the CLI's stderr banner. The exit code is not evidence; the tool output is.

## 6. Known limitations

- **Compound commands are checked per segment.** A reviewer's single-command allowlist therefore
  denies `git status; flutter analyze` even though both halves are allowed. This is a usability cost,
  accepted because it keeps the reviewer surface narrow (see `FND-GOV-003` for the matching semantics).
- **`ask` depends on a human reading the prompt.** Saved "allow always" approvals are project-scoped
  and cannot override a configured `deny`, which is why the reviewer rules keep `deny` rather than
  `ask`.
- **Shell is not a sandbox.** The permissions guide states that shell runs with the host user's full
  filesystem, process and network authority. The gates are a guardrail against mistakes, not a
  containment boundary.
- **The secret gates are pattern-based.** An obfuscated path (`Get-Content ("." + "env")`) is not
  matched. The `read`-tool gates are stronger than the shell gates.

## 7. Changing the policy

1. Edit `.opencode/opencode.jsonc` only, unless an agent must be *stricter* than the global set.
2. Keep allows before gates. Never add a per-agent broad allow.
3. Add or update a probe in the validator for every new gate, and require `0 probe failures`.
4. Re-run one runtime denial probe for any agent that must stay read-only.
5. Record the change in `docs/planning/DECISIONS.md`; permission changes are material by definition
   (`AGENTS.md` §0.3, §11).
