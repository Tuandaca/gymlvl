# A0.1 — Multi-Agent Governance Fix and Audit Checkpoint

**Date:** 2026-10-28
**Baseline:** `main` @ `9c8e142` = `origin/main`, clean at entry
**Acting agent:** built-in build agent (`gymlvl-orchestrator` still **not** active in this session)
**Status:** `PASS` for the configuration fix; Git push `BLOCKED` by the project deny rule
**Scope:** one agent permission rule, audit documents, planning records. No application, schema, CI, or
dependency change.

---

## 1. Root cause of the "orchestrator is not active" symptom

The five candidate explanations were separated, not conflated.

| Hypothesis | Verdict | Basis |
|---|---|---|
| OpenCode Desktop ignored the config | **Rejected** | The server reloaded the agent definition one second after the file write — `agent.updated` at `2026-10-28T07:06:41.988Z` in `~/.local/share/opencode/log/opencode.log` |
| `default_agent` is invalid or misspelled | **Rejected** | `.opencode/opencode.jsonc` parses; `default_agent = gymlvl-orchestrator`; the agent is registered (proved by the negative subagent test below) |
| Primary vs subagent invocation confusion | **Rejected as the cause, confirmed as a property** | `subagent(gymlvl-orchestrator)` → `"Agent gymlvl-orchestrator cannot run as a subagent"`, which shows `mode: primary` is enforced. A primary agent is only reachable by selecting it for a session |
| The current session inherited build-agent permissions | **Confirmed, and this is the real cause** | See §2 |
| An existing session needs a new session to adopt `default_agent` | **Confirmed** | OpenCode V2 documentation, *Config → Agent*: `default_agent` "Choose the primary agent used **when a session does not select one explicitly**" |

**Conclusion.** `default_agent` is a *session-creation* default, not a live switch. This session was
created before the setting existed (or with `build` selected explicitly), and OpenCode does not
re-bind an existing session when configuration reloads. Configuration reload **does** work — the
`agent.updated` event proves the edited definition was picked up by the running server — but it
updates the definition, not the session's selected agent.

## 2. Evidence that the acting profile is the build agent

Each of these would be denied under the orchestrator profile as configured before this stage:

| Action taken in this session | Denied for orchestrator? | Observed |
|---|---|---|
| `edit .opencode/opencode.jsonc` (S3 checkpoint, twice) | yes — `edit *` deny, no `.opencode/**` allow | succeeded |
| write `…\Temp\opencode\gymlvl-s3-commit-msg.txt` | yes — `external_directory *` deny | succeeded |
| write `docs/audit/README.md` (A0) | yes — no `docs/audit/*` allow at the time | succeeded |
| run `npm.cmd test`, `git ls-remote`, `git add`, `git commit` | yes — not on the orchestrator shell allowlist | succeeded |

Four independent paths, all outside the orchestrator allowlist. Confidence `High`.

## 3. The change

One rule added to `.opencode/agents/gymlvl-orchestrator.md`, after the existing edit allows:

```yaml
  # `*` matches across `/`, so this covers docs/audit/phases/ as well.
  # Added in A0.1 to close FND-GOV-001. Do not widen further.
  - action: edit
    resource: "docs/audit/*"
    effect: allow
```

Nothing else changed. The diff is 5 added lines (3 of them comments) in one file.

`docs/audit/*` is the minimum sufficient resource because OpenCode's permission matching uses
whole-value wildcards in which `*` matches **zero or more characters including `/`** (OpenCode V2
permissions guide, *Matching*). One rule therefore covers `docs/audit/README.md` and
`docs/audit/phases/A1_ARCHITECTURE.md` alike.

## 4. Verification

| Check | Method | Result | Status |
|---|---|---|---|
| Rule present and correctly ordered | parse frontmatter, list edit rules | `edit *` deny first, then `docs/planning/*`, `docs/agent-system/*`, `docs/audit/*` | `PASS` |
| No escalation beyond one directory | parse all action/resource/effect triples | edit 4 rules (1 deny, 3 allow); shell 15 (1 deny, 14 allow, unchanged); subagent 7 (1 deny, 6 allow, unchanged); webfetch/websearch/external_directory unchanged | `PASS` |
| Orchestrator still primary | `subagent(gymlvl-orchestrator)` | `"Agent gymlvl-orchestrator cannot run as a subagent"` | `PASS` |
| Six subagent allows intact | parse | `flutter-specialist`, `supabase-specialist`, `exercise-catalog`, `ui-ux-specialist`, `qa-reviewer`, `context-keeper` | `PASS` |
| `qa-reviewer` read-only | parse all rules | exactly one `edit` rule: `*` → deny; no allow | `PASS` |
| `context-keeper` read-only | parse all rules | exactly one `edit` rule: `*` → deny; no allow | `PASS` |
| Global Git floor intact | read `opencode.jsonc` | deny push, reset --hard, clean -fd, clean -fdx, filter-branch; ask commit, tag, rebase, checkout, switch, stash | `PASS` |
| Definition reloaded by the server | log `agent.updated` event | `2026-10-28T07:06:41.988Z`, one second after the write | `PASS` |
| End-to-end write as the orchestrator | requires a session running as orchestrator | not attempted — the profile is not active here | `NOT RUN` |
| Push the checkpoint | `git push origin main` | `{"error":{"type":"permission.rejected","message":"Permission denied: shell"}}` | `BLOCKED` |

Independent verification: `qa-reviewer` inspected all seven agent files and returned `PASS` on checks
1–6 of the list above (see §6 for the one item it got wrong).

**Second independent datapoint for `FND-GOV-003`.** The push attempt was rejected at the tool boundary:
the shell call was never executed, so no part of the command string ran. That is a stronger result than
the S3 observation (where the deny surfaced on a later sub-command) and confirms the mechanism from the
other direction: a shell invocation containing a denied segment is refused as a whole. It also confirms
that the Git floor cannot be reached by appending `git push` to an allowed prefix.

## 5. Finding resolutions

| Finding | Before | After | Basis |
|---|---|---|---|
| `FND-GOV-001` | `Accepted`, P2 | **`Fixed`** | The rule exists, is ordered correctly, was reloaded, and introduces no other capability. End-to-end write remains `NOT RUN` and is tracked as an open item |
| `FND-GOV-003` | `Needs Verification`, P3 | **`False Positive`** | OpenCode V2 documents that a `shell` resource is a "scanner-produced command string; compound commands may produce **several**", with last-match-wins per resource. `cd X; git push` therefore produces two resources; the `cd *` allow covers the first and the global deny covers the second. This exactly matches the observed `permission.rejected` in S3 |

`FND-GOV-003` is retained with its disproof rather than deleted, per `README.md` §7.

## 6. One reviewer claim that was wrong

`qa-reviewer` reported a pre-existing gap: "`opencode.jsonc:9` `git push *` does not match bare
`git push`". This is **incorrect**. The OpenCode V2 permissions guide states that "a shell pattern
ending in ` *` also matches the command without arguments", using `git status *` → matches `git status`
as the example. `git push *` therefore matches bare `git push`.

Recorded here so the claim is not carried into a later stage as a finding. No register entry was
created for it. This is the second time in two stages that a reviewer produced a plausible but wrong
claim; both were caught by reading the authoritative source rather than by trusting the delegation.

## 7. Remaining governance gaps

1. **The orchestrator is still not the active agent in this session.** Only a new session (or explicit
   selection) changes that. Until then, audit artifacts are written by the build agent. The permission
   *defect* is fixed; the *operating model* is not yet exercised.
2. **A0/A0.1 artifacts were authored by an agent without the orchestrator's scope guardrails.** This is
   a process observation, not a defect in the files.
3. `FND-GOV-002` (stale baseline prose) remains `Accepted`; it is a W4 documentation task.

## 8. Git

| Item | Value |
|---|---|
| Branch | `main` |
| HEAD at entry | `9c8e142` |
| Remote at entry | `9c8e142` |
| Commit | `e400dbc` — `chore(audit): allow orchestrator audit writes and checkpoint A0/A0.1`; 14 files, +1622/−38; tree clean after |
| Push | attempted once and **denied**. Exact response: `{"error":{"type":"permission.rejected","message":"Permission denied: shell"}}`. The `git push *` → `deny` rule matched the command string and the whole tool call was refused, so no part of the command ran. No workaround applied. |
| Remote after | still `9c8e142` — the checkpoint is **local only** until a human pushes it |
