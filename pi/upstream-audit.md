# Pi upstream audit — 2026-09-18

## Result

**No missing upstream implementation updates found in `subagents`, `background-terminals`, or `workflows`.** All three already contain the latest upstream path revision, **`21f40f41fb98e088281a6fcd512388d82bddf911` (2026-07-24 UTC)**. Their upstream trees have not changed since then, despite newer repository commits. Local differences are committed adaptations and a substantial **uncommitted completion-delivery redesign**, not evidence of an old import. Do not overwrite these directories with upstream copies.

One relevant newer repository change is the **MIT license added 2026-09-07 UTC**, explicitly covering prior commits. No copied upstream license was found among tracked files under `pi/`; preserve its notice in a separately approved change. [License commit][license-commit] · [License text][license] · [Prior-commit clarification][readme-license]

## Scope and evidence

- Observed at **2026-09-18T12:00:08Z**; cloned `https://github.com/davis7dotsh/my-pi-setup` into fresh **`/tmp/my-pi-setup-audit.ImPphT`** (macOS canonical path: `/private/tmp/my-pi-setup-audit.ImPphT`). Clone retained for inspection.
- Upstream default branch: `main`; fetched HEAD **`5a0863f442402aa35cb0830805d67639957c7172`**, authored/committed **2026-09-06T17:51:57-07:00 = 2026-09-07T00:51:57Z**. It merges the license change, not extension code. [HEAD][head]
- Local checkout HEAD: **`5a2837d81a03b548d44c886bc5ece38960c22c36`**, **2026-09-02T22:23:44+02:00**. The only local commit touching the three target extension paths is their introduction in **`1235ecb294535e8604b58d08203e82beeccf9c24`**, **2026-08-31T14:22:27+02:00** (`feat: big chunky update`). [Local import][local-import]
- Compared **upstream history → local committed blobs → actual dirty working files** separately. Enumerated upstream tracked files, compared bytes/Git blob hashes, searched all fetched history for best-matching snapshots, inspected substantive diffs, lifecycle code and relevant test sources. Ignored installed `node_modules` for source parity.
- Read root and relevant local `AGENTS.md`. **No installs, builds, tests, upstream program execution, browser testing, plugin/settings edits, staging, commits, resets or checkouts.** Only repository file written by this audit: this note. Test descriptions below mean inspected test code, not successful test runs. Findings do not require assumptions from current Pi API docs; runtime compatibility remains unverified.
- Remaining extensions are deliberately left to the parent audit. Supporting `shared/` code is included only where needed for these three.

## 1. Latest path commits and import baseline

All dates below are UTC; original commit timezones are preserved above where useful.

| Path | Latest upstream path commit | Date | What it changed |
|---|---|---|---|
| `extensions/subagents` | [`21f40f4`][pi82] | 2026-07-24 06:52:32Z | Pi 0.82 compatibility plus cancellation, child-backend and memory-bound hardening |
| `extensions/background-terminals` | [`21f40f4`][pi82] | 2026-07-24 06:52:32Z | Spill backpressure and 256 MiB per-stream spill cap; dependency refresh |
| `extensions/workflows` | [`21f40f4`][pi82] | 2026-07-24 06:52:32Z | Session-creation compatibility, sandbox wrapper isolation and byte-count validation |
| `extensions/shared` | [`87eda8c`][orchestration] | 2026-07-13 21:18:24Z | Shared orchestration helpers; subsequent local changes are not missing upstream updates |

### Strong evidence: exact blobs, not similar-looking code

These directory tree IDs are **identical at `21f40f4` and current upstream HEAD**:

| Upstream directory | Git tree ID |
|---|---|
| `subagents` | `16405f9de2ed33afc4b480efd96a3c98e2ebde39` |
| `background-terminals` | `bd5f7ce0f9e55d01b9a1e1bc2af5f645b69486ed` |
| `workflows` | `f882e71a3fa4d4a71c0a36d41c0e955eab34e09f` |

[Subagent snapshot][sa-tree] · [Terminal snapshot][bt-tree] · [Workflow snapshot][wf-tree]

| Directory | Upstream tracked files | Exact matches in local HEAD | Exact matches in working tree |
|---|---:|---:|---:|
| `subagents` | 28 | 24 | 19 |
| `background-terminals` | 18 | 16 | 12 |
| `workflows` | 17 | 17 | 17 |
| `shared` | 8 | 7 | 7 |

Counts include upstream manifests, lockfiles, docs and tests; local-only files are not in the denominator. Missing/deleted files count as non-matches.

Every runtime source file in the three target directories matched upstream at local HEAD. The committed mismatches are tests/docs/lockfiles, not missing implementation. Representative identical upstream/local-HEAD blobs:

| File (under `extensions/`) | Git blob ID |
|---|---|
| `subagents/src/backends/pi.ts` | `0966014abf93eed099d7e38584fecb5d5055e9e9` |
| `subagents/src/backends/claude.ts` | `5eb00e2fae8b31f3f9244fd446a21a8ea98bc40f` |
| `subagents/src/backends/codex.ts` | `e7fb033c64bcb2c5555cdb2eb37564bc1ce32433` |
| `subagents/src/manager.ts` | `cb183acb1efbf901e4a313a4e6f0899a605207fa` |
| `background-terminals/src/manager.ts` | `0d1a0ac1f4617159e51d37076e570a9b65b84d8c` |
| `workflows/sandbox-child.cjs` | `8206358a8fa5cc2f3e1b30ce7fcb55c96f29ed56` |
| `workflows/runner.ts` | `63b1bf3a9703b6d209b7877fd46635e9335e6c4d` |

**Baseline conclusion, high confidence:** `21f40f4` is the earliest upstream revision with the imported source-content snapshot. Comparing all fetched commits yields 14 equally good snapshot candidates for the target directories; six are reachable from current main HEAD: `21f40f4`, `2657bae`, `4a37b78`, `73bf4d8`, `07f6392`, `5a0863f`. They cannot be distinguished from these copied directories alone.

**Exact checkout provenance remains unknown.** No upstream revision marker was found under local `pi/`. Given the local import's Git date, a main checkout between `21f40f4` and `73bf4d8` is chronologically consistent; the September license commits postdate that import. This is inference, not proof of the actual checkout used. Do not label the baseline as definitively `73bf4d8` merely because it was the latest dated main commit then.

## 2. Subagents — current upstream already imported

### Upstream evolution and fixes present locally

- **2026-07-14 UTC:** promoted the multi-backend Effect implementation; autonomous permissions configured; further Effect lifecycle improvements followed. Current implementation supports Pi in-process sessions, Claude Agent SDK and Codex app-server, with manager-owned scopes and a four-running/64-tracked limit. These are not features still waiting to be imported. [Promotion][sa-promotion] · [Permission change][sa-permissions] · [Effect improvements][effect-improvements] · [Manager][sa-manager]
- **2026-07-16 UTC:** `/btw` side sessions and formatting/Unicode title fixes. Current code uses code-point-aware title truncation, hides `origin: "btw"` entries from model tools, and records their answers through `appendEntry` rather than normal completion delivery. All present locally; the dirty completion refactor retains the `/btw` branch. [Feature][btw-feature] · [Formatting fix][btw-format] · [Unicode fix][btw-unicode] · [Visibility/title helper][btw-helper] · [Delivery branch][sa-delivery]
- **2026-07-24 UTC:** spawn/cancel now pass tool abort signals; Claude disallows native `Agent`/`Task`; Codex has Windows tree-kill handling; Pi uses the shared tool-timeout guard and no longer passes `modelRegistry` to session creation; manager bounds transcript entries (512), transcript text (64 Ki characters), live text/thinking tails (128 Ki characters), final text (1 Mi characters). These changes are all retained locally. The text caps use string slicing, not UTF-8 byte accounting. [Pi 0.82 diff][pi82] · [Manager bounds][sa-manager] · [Pi backend][sa-pi] · [Codex backend][sa-codex]

**Permission boundary:** Claude requests `bypassPermissions` plus `allowDangerouslySkipPermissions`; Codex requests `approvalPolicy: "never"`, `sandbox: "danger-full-access"`. These are inherited upstream choices, not local regressions or newly missing updates. Claude's untrusted-project setting restriction does not convert this into an OS sandbox. Continue treating delegated working directories/tasks as trusted. [Claude options][sa-claude] · [Codex options][sa-codex-permissions]

### Committed local customizations

- `claude.test.ts`: expands the live smoke test into a follow-up-turn context/session continuity test.
- `manager.test.ts`: checks preserved native session ID, session-file path and user-message history over follow-up turns.
- `docs/design-plan.md`: portable paths instead of the author's home directory.
- `package-lock.json`: metadata changes only, **no dependency version differences**. Differences are 95 `peer` fields, four `libc` fields and two empty optional-platform package records. Runtime dependency ranges match upstream; locked Claude SDK remains `0.3.218`, Effect `4.0.0-beta.101`, `@effect/tsgo` `0.24.3`.

Primary local evidence: [imported subagents][local-sa] and its diff against [upstream snapshot][sa-tree]. The extra continuity tests do **not** imply a separate local backend fix: backend source is byte-identical.

### Uncommitted redesign — preserve, do not replace

Local [`index.ts`](.pi/agent/extensions/subagents/index.ts), [`src/manager.ts`](.pi/agent/extensions/subagents/src/manager.ts), new [`src/result-exposure.ts`](.pi/agent/extensions/subagents/src/result-exposure.ts) and [`shared/completion-delivery.ts`](.pi/agent/extensions/shared/completion-delivery.ts) intentionally replace upstream's idle/`agent_settled`, per-result `followUp` delivery:

- Cross-extension completion batching at `turn_end`, plus idle/settled fallback; submission uses `steer` with `triggerTurn: true`.
- Session-scoped synchronous event-bus collection combines terminal and subagent results; token-matched custom `message_end` acknowledges a submission. Pending snapshots survive submission failure; abort/error pauses wake-up until a new `agent_start`.
- Settlement publishes before waking waiters; wait/cancel interest is now pruning coordination, **not acknowledgment**. Manager's legacy `consumed` callback argument is always false.
- `subagent_check` consumes only complete settled previews; `subagent_wait` consumes only complete, untruncated result sections surviving both per-agent and aggregate output limits. Truncated/omitted outputs remain pending. Cancellation returns status only and does not itself consume completion output.
- Removed per-extension `src/result-delivery.ts` and `result-delivery.test.ts`; replaced by shared tests and local `tool-consumption.test.ts`. Package test scripts and design notes changed accordingly.

Local regression sources: [scheduler tests](.pi/agent/extensions/shared/completion-delivery.test.ts), [Pi fake-model integration tests](.pi/agent/extensions/shared/completion-delivery.integration.test.mjs), [result-exposure tests](.pi/agent/extensions/subagents/tool-consumption.test.ts). These three shared delivery files and the two new subagent files were untracked when inspected; the deletions and edits were also pre-existing work.

The one committed `shared/` mismatch is `dashboard-state.ts`: local code generalizes `PullRequestInfo`/`pullRequest` into `ChangeRequestInfo`/`changeRequest` with pull-request/merge-request kinds. That belongs to the parent dashboard/GitLab audit, not an orchestration update; do not replace all of `shared/` during a sync.

Upstream still has the old implementation; recopying it would undo this work. The old code marks in-flight wait interest consumed and drains deferred results into one follow-up per result. Its wait handler consumes all requested IDs before output budgeting. The local work addresses real differences in those semantics, but this audit did **not** validate its runtime correctness. [Upstream delivery][sa-delivery] · [Upstream wait][sa-wait] · [Upstream manager][sa-manager]

## 3. Background terminals — lifecycle fixes already present

### Upstream evolution and retained behavior

- **2026-07-14–15 UTC:** initial extension, repeated lifecycle hardening, then **`8126656` (2026-07-15T07:19:41Z)** fixes kill classification at signal time. Natural exit must retain its actual result even if descendants subsequently need killing. That manager and its tests are already local. [Lifecycle history endpoint][terminal-kill-fix] · [Earlier hardening][terminal-hardening]
- **2026-07-24 UTC:** bounded full-log spills and stream backpressure, already imported. Limits: eight running, 32 tracked, 2 MiB in-memory retained per stream, **256 MiB spill per stream**. Spill cap/error clears the advertised full-log path and adds an error note, rather than promising an unlimited complete capture. [Manager constants][bt-manager-limits] · [Spill implementation][bt-spill] · [Pi 0.82 diff][pi82]
- Process lifecycle remains upstream-identical: shell invocation, stdin ignored, POSIX detached process groups/Windows tree-kill support, scoped cleanup, SIGTERM→SIGKILL escalation, bounded stdio/spill cleanup, final settlement after flush, shutdown cleanup. No new upstream process-management fixes are missing. [Process management][bt-manager] · [Output buffer][bt-output]

### Local changes

Committed HEAD changes only portable documentation paths and lockfile metadata (two empty optional-platform `@effect/tsgo` records; no version differences). The current dirty tree changes `index.ts`, docs and test script, deletes the old delivery helper/test, and shares the new completion scheduler described above. **`src/manager.ts`, `src/output.ts`, prompt builders, runtime, UI and existing lifecycle tests still exactly match upstream.** [Committed terminal files][local-bt]

The adapter deliberately ignores the upstream manager's `consumed` argument, so an interrupted `bg_kill` wait need not suppress completion. `bg_status`/`bg_kill` acknowledge after constructing a successful response, with abort checks. These are local integration changes, not omitted upstream commits. [Local adapter](.pi/agent/extensions/background-terminals/index.ts)

**Documentation/test-contract follow-up:** the dirty guide says kill-interest never produces a consumed settlement and describes corresponding manager tests. But the unchanged manager still computes `consumed = killInterest > 0`, and unchanged manager tests retain that upstream contract. The adapter ignores the flag, so this mismatch alone does not establish a runtime defect. Clarify manager callback versus adapter acknowledgment semantics; add adapter-level aborted-kill/status exposure coverage before declaring the redesign verified. Also qualify legacy “complete full logs” wording for the 256 MiB cap. [Manager callback][bt-consumed] · [Local guide](.pi/agent/extensions/background-terminals/docs/implementation-guide.md)

## 4. Workflows — exact current source, different completion architecture

**All 17 upstream files are byte-identical in both local HEAD and working tree.** Only local additions: package manifest/lockfile (`acorn: ^8.17.0`) and installed dependencies, making the copied directory independently resolvable. Upstream has no per-workflow package manifest. No source update/cherry-pick is needed. [Upstream directory][wf-tree] · [Local imported directory][local-wf]

### Important upstream fixes already retained

- **2026-07-13 UTC:** controller, sandbox, persistence/orchestration refinements and per-call timeout work. RunController caps **four concurrent calls per workflow run** and **32 total calls**, tracks tasks and uses bounded shutdown. This is not a shared global cap across workflow runs and the separate subagent manager. [Timeout change][tool-timeouts] · [Orchestration change][orchestration] · [Controller][wf-controller]
- **2026-07-14T08:11:23Z, `3e22612`:** fail a provider request that produces no first assistant response event within 45 seconds. This is a first-response watchdog, not a whole-workflow deadline or a guarantee against every later stall. Per-tool timeout protection is separate. [Watchdog commit][wf-watchdog-commit] · [Runner][wf-runner]
- **2026-07-24 UTC, `21f40f4`:** removed `modelRegistry` from session creation; isolated workflow source using `vm.compileFunction` instead of interpolating it into the host accounting wrapper; added a wrapper-escape/unawaited-agent regression test; enforced phase IPC length in bytes rather than string length; catches serialization failures. All present locally. [Pi 0.82 diff][pi82] · [Sandbox child][wf-child] · [Sandbox tests][wf-sandbox-tests]

### Architecture and integration implications

- Workflow script runs in a separate permission-restricted Node child, with constrained filesystem access/environment, 128 MiB old-space setting, bounded source/args/IPC, token validation and at most 32 agent requests. Requires a Node runtime supporting `--permission`; unsupported runtimes reject rather than silently run unrestricted. The child VM wrapper rejects unawaited/in-flight agent calls. This isolates orchestration code; the **Pi agent sessions invoked by `agent()` execute in the parent process with trust-aware resources**, not inside that Node permission boundary. [Sandbox parent][wf-sandbox] · [Sandbox child][wf-child] · [Runner][wf-runner]
- Structured output uses a terminating tool; agents return explicit `{ ok, output, structured?, error? }` outcomes. Artifacts hold script, arguments, statuses, result and bounded transcripts; inspection is not resumable execution. [Runner][wf-runner] · [Workflow entry point][wf-index]
- Background mode is enabled only when `ctx.hasUI`; runs deliberately survive parent-turn Escape but abort on session shutdown. Completion still calls **`pi.sendUserMessage(..., { deliverAs: "followUp" })`** in its own finalizer, with only a catch for submission failure. It **does not participate** in the local terminal/subagent batching, delivery-token acknowledgment or abort/error pause policy. This is an inherited architectural difference, not an upstream update omitted locally. [Background and shutdown lifecycle][wf-index]

Recommendation: decide explicitly whether workflows should retain this independent policy. If the intended product rule is “all background results batch and never auto-resume an aborted parent,” workflows remain outside it. A separate adaptation would need lifecycle tests; blindly transplanting the subagent helper is not a proven fix. The existing shutdown path attempts a completion follow-up during cleanup; assess that ordering rather than assuming the catch proves safe delivery.

## 5. Actual upstream delta after the matching snapshot

`git log 21f40f4..HEAD` contains only:

| Commit | UTC date | Change | In target directories? |
|---|---|---|---|
| [`2657bae`][trim-config] | 2026-07-25 | Ignore/remove tracked `models.json`, trim upstream `AGENTS.md` | No; do not copy upstream config policy into local settings |
| [`4a37b78`][recap] | 2026-07-31 | Summaries recap prompt | No; parent audit scope |
| [`73bf4d8`][spark] | 2026-08-04 | New `spark-strict-tools` extension | No; parent audit scope |
| [`07f6392`][license-commit] | 2026-09-07 | MIT license and README clarification covering prior commits | Repository-level attribution follow-up |
| [`5a0863f`][head] | 2026-09-07 | License PR merge | No extension implementation change |

Thus “upstream has newer commits” is true, but “these three copied implementations are behind” is not supported.

## 6. Recommended next steps and uncertainties

1. **Do not bulk-sync or cherry-pick `21f40f4`: it is already present.** Keep the local completion redesign and existing continuity tests intact.
2. **Preserve MIT attribution** in an approved follow-up, including the copyright/permission notice; upstream explicitly licenses prior commits. This audit made no license-file changes.
3. **Validate the dirty redesign separately before committing it.** Inspect/run its existing fake-model integration tests against the actual installed Pi version, plus end-to-end adapter consumption tests (abort, output omission, error, shutdown, concurrent user steering). Current test files express intent, not evidence they pass. Do not restore the deleted local delivery maps.
4. **Resolve workflows' completion policy explicitly**, rather than assuming shared batching covers it. Keep “per-workflow concurrency” distinct from the separate subagent manager's cap.
5. **Fix documentation drift** around terminal manager consumption versus adapter acknowledgment, capped logs, and legacy design-plan claims. Do not import stale upstream docs over newer local design decisions.
6. **Record a durable source baseline when changes are next approved:** repository URL, `21f40f4` source-content snapshot, audited HEAD `5a0863f`, and an explicit local patch inventory. Blob equality identifies content ancestry, not exact checkout provenance.

Limitations: read-only static audit; no live Claude/Codex/Pi sessions or test execution; no installed-version compatibility/security guarantee; no review of unmerged remote branches as recommended updates. History/blob search included fetched refs, but current-update recommendations target default-branch HEAD only. Git author/committer dates are recorded metadata, not independently verified wall-clock provenance. Dirty files cannot have honest commit permalinks; relative links above refer to the working snapshot inspected on 2026-09-18. Other extensions/settings are outside the deep audit.

## 7. Remaining copied extensions — independent comparison

Compared a second fresh upstream clone at the same HEAD (`/tmp/ben-pi-audit-main.PGWxav`) against the actual local files:

| Extension | Result |
|---|---|
| `model-info` | Entire directory identical, including lockfile. |
| `file-search` | Latest upstream source plus local startup disabling of built-in `find`/`grep`; lockfile differs. |
| `git-info` | Latest upstream source plus local GitLab merge-request support and tests; lockfile differs. |
| `ui-customization` | Latest upstream source plus display of local generalized PR/MR state. |
| `shared` | Upstream helpers retained; local PR/MR dashboard state and new completion-delivery files. |

All four copied extension paths were last changed upstream by [`21f40f4`][pi82]. No missing implementation updates found. Sources: [file-search](https://github.com/davis7dotsh/my-pi-setup/tree/5a0863f442402aa35cb0830805d67639957c7172/extensions/file-search), [git-info](https://github.com/davis7dotsh/my-pi-setup/tree/5a0863f442402aa35cb0830805d67639957c7172/extensions/git-info), [model-info](https://github.com/davis7dotsh/my-pi-setup/tree/5a0863f442402aa35cb0830805d67639957c7172/extensions/model-info), [UI](https://github.com/davis7dotsh/my-pi-setup/tree/5a0863f442402aa35cb0830805d67639957c7172/extensions/ui-customization).

Upstream extensions absent from the local extensions directory: `ask-user` (multiple-choice questions), `copy-all` (copy conversation), `firecrawl-search` (web search/crawl/scrape), `summaries` (automatic run recaps), and `spark-strict-tools` (sets strict function tools specifically for provider `spark-deepseek`). These are optional additions, not updates missing from copied plugins; all existed before the August 31 import. Latest addition: [`spark-strict-tools`, August 4][spark]; recap prompt last changed [July 31][recap].

The live `~/.pi/agent/extensions` tree matches the dotfiles extension tree, excluding installed `node_modules`, with one extra live-only file: `herdr-agent-state.ts`. This file is not present in Ben's current upstream tree. No extension code changed during this audit.

## Primary-source links

[head]: https://github.com/davis7dotsh/my-pi-setup/commit/5a0863f442402aa35cb0830805d67639957c7172
[pi82]: https://github.com/davis7dotsh/my-pi-setup/commit/21f40f41fb98e088281a6fcd512388d82bddf911
[local-import]: https://github.com/LeonardoTrapani/dotfiles/commit/1235ecb294535e8604b58d08203e82beeccf9c24
[local-sa]: https://github.com/LeonardoTrapani/dotfiles/tree/1235ecb294535e8604b58d08203e82beeccf9c24/pi/.pi/agent/extensions/subagents
[local-bt]: https://github.com/LeonardoTrapani/dotfiles/tree/1235ecb294535e8604b58d08203e82beeccf9c24/pi/.pi/agent/extensions/background-terminals
[local-wf]: https://github.com/LeonardoTrapani/dotfiles/tree/1235ecb294535e8604b58d08203e82beeccf9c24/pi/.pi/agent/extensions/workflows
[sa-tree]: https://github.com/davis7dotsh/my-pi-setup/tree/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents
[bt-tree]: https://github.com/davis7dotsh/my-pi-setup/tree/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/background-terminals
[wf-tree]: https://github.com/davis7dotsh/my-pi-setup/tree/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/workflows
[sa-promotion]: https://github.com/davis7dotsh/my-pi-setup/commit/c95da6bf52c338bac30a230d37fe57d5b9cdb772
[sa-permissions]: https://github.com/davis7dotsh/my-pi-setup/commit/458a2b3fd3744d2be90714b9b849f817f18e5e2c
[effect-improvements]: https://github.com/davis7dotsh/my-pi-setup/commit/84e4bfb96af15f23c4340decf7a8b243ccd87c32
[btw-feature]: https://github.com/davis7dotsh/my-pi-setup/commit/887f63c83227d46a4eb06baa7fce974ff3cc0de5
[btw-format]: https://github.com/davis7dotsh/my-pi-setup/commit/3014b028137fb84b1c6344ac0630b2268dad1e76
[btw-unicode]: https://github.com/davis7dotsh/my-pi-setup/commit/d72827e6deb162ab2c6c6b02675d72859869746e
[btw-helper]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents/src/by-the-way.ts
[sa-manager]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents/src/manager.ts
[sa-pi]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents/src/backends/pi.ts
[sa-claude]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents/src/backends/claude.ts#L327-L342
[sa-codex]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents/src/backends/codex.ts
[sa-codex-permissions]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents/src/backends/codex.ts#L889-L898
[sa-delivery]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents/index.ts#L180-L262
[sa-wait]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/subagents/index.ts#L380-L449
[terminal-kill-fix]: https://github.com/davis7dotsh/my-pi-setup/commit/8126656d32b59b367c778ef07676339aeff48bac
[terminal-hardening]: https://github.com/davis7dotsh/my-pi-setup/commit/de8fa9266583b008e425b9ffa3c047f76d99cb3c
[bt-manager-limits]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/background-terminals/src/manager.ts#L38-L55
[bt-manager]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/background-terminals/src/manager.ts
[bt-spill]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/background-terminals/src/manager.ts#L470-L529
[bt-consumed]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/background-terminals/src/manager.ts#L409-L421
[bt-output]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/background-terminals/src/output.ts
[tool-timeouts]: https://github.com/davis7dotsh/my-pi-setup/commit/a521616ac4ec4f718fd3e343ee07fa716190d490
[orchestration]: https://github.com/davis7dotsh/my-pi-setup/commit/87eda8cc57247ec5eec8b0f775307b348d605d8a
[wf-watchdog-commit]: https://github.com/davis7dotsh/my-pi-setup/commit/3e226120bc7149d8e31d523a337a2eb62102002a
[wf-controller]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/workflows/controller.ts
[wf-runner]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/workflows/runner.ts
[wf-sandbox]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/workflows/sandbox.ts
[wf-child]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/workflows/sandbox-child.cjs
[wf-sandbox-tests]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/workflows/sandbox.test.ts
[wf-index]: https://github.com/davis7dotsh/my-pi-setup/blob/21f40f41fb98e088281a6fcd512388d82bddf911/extensions/workflows/index.ts
[trim-config]: https://github.com/davis7dotsh/my-pi-setup/commit/2657bae6e054a2817e4483f6cdce8ab9c9eafcfd
[recap]: https://github.com/davis7dotsh/my-pi-setup/commit/4a37b7830bda00d4a7e861218f70e70097ddf2e8
[spark]: https://github.com/davis7dotsh/my-pi-setup/commit/73bf4d826f39b5cab6b7865e706ba4a2669629ca
[license-commit]: https://github.com/davis7dotsh/my-pi-setup/commit/07f639202bf1ad466df80b003215f17a9dfa7107
[license]: https://github.com/davis7dotsh/my-pi-setup/blob/07f639202bf1ad466df80b003215f17a9dfa7107/LICENSE
[readme-license]: https://github.com/davis7dotsh/my-pi-setup/blob/07f639202bf1ad466df80b003215f17a9dfa7107/README.md#L18-L20
