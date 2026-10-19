---
name: match-source-loop
description: >-
  Runs a source-parity loop: a builder subagent implements, an independent
  verifier subagent compares against the source reference, repeating until PASS.
  Use when the user wants to match, port, or copy an upstream implementation,
  framework, SDK, or protocol ("match source", "copy Flue", "keep going until
  parity"), or asks for one subagent to build while another verifies. Do not use
  for one-off edits, pure code review, or tasks without a concrete source
  reference.
---
# match-source-loop

Orchestrate a parity loop: a **builder** subagent implements, an independent **verifier** compares behavior against the source, repeat until PASS. A parity point closes only on a verifier PASS or a gap the user accepts.

## 1. Agreement

Read what already exists first: spec, plan, or design files produced by earlier work or other skills, project instructions, decisions from the conversation. Extract the scope from those; ask one concise question only for gaps that materially change the implementation.

Write the **agreement** — the contract every later prompt and verdict traces back to. Put it in the spec file when one exists, otherwise state it explicitly in context:

- Source reference: path, URL, package, SDK, or commit.
- Target path.
- Behaviors to match.
- Behaviors explicitly out of scope.
- Required checks and constraints (package manager, style, architecture).

Done when the agreement exists and separates match from no-match.

## 2. Split into parity points

A **parity point** is one independently verifiable behavior from the agreement's match list, sized so a single verifier run can judge it. Done when every behavior to match maps to exactly one point.

## 3. Build

For the active parity point, spawn a builder:

```text
You are implementing source-parity changes in <target-path>.

Agreement: <file path or inline summary>
Parity point: <behavior>

Source references to inspect first:
- <source file or URL>

Target files:
- <target files>

Constraints: do not commit; preserve unrelated changes; follow the agreement's checks and project instructions.

Required behavior:
1. <criterion>

Required tests:
1. <scenario>

Run: <format / typecheck / lint / test commands>
Return: files changed, behaviors matched, known gaps, checks run and results.
```

## 4. Verify

Spawn a verifier that shares no conclusions with the builder and compares behavior, not whether code exists:

```text
You are an independent verifier in <target-path>. Do not modify files.

Agreement: <file path or inline summary>
Parity point: <behavior>

Source references:
- <source file or URL>

Target files:
- <target files and tests>

Verification criteria:
1. <criterion>

Run checks if feasible: <typecheck / lint / test commands>

Return exactly:
- Verdict: PASS or FAIL
- Findings: concrete bullets with file/line references
- Checks: commands and results
```

## 5. Loop

- PASS → point closed; next point.
- FAIL → feed only the verifier's concrete findings into the next builder pass; back to step 3. Trust the verdict; overrule it only with concrete counter-evidence.
- One point active at a time; parallelize independent points only on user request.

Ask the user before closing a point that would change product behavior, public API shape, persistence model, deployment target, or security assumptions beyond the agreement.

## 6. Close out

A gap may remain only if the user accepted it, the agreement puts it out of scope, or the source behavior cannot apply to the target platform. Re-run required checks, then summarize: behaviors matched against their source references, files changed, verifier passes, remaining gaps (accepted or not), and check results.
