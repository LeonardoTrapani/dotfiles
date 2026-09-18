import assert from "node:assert/strict";
import test from "node:test";
import type { SubagentSnapshot } from "./src/domain.ts";
import {
  formatCheckResult,
  formatSubagentOutput,
  formatWaitResult,
} from "./src/result-exposure.ts";

const limits = { maxBytes: 48 * 1024, perAgentMaxBytes: 16 * 1024 };
const separator = "\n\n---\n\n";

function snapshot(
  id: string,
  finalText = "answer",
  status: SubagentSnapshot["status"] = "done",
): SubagentSnapshot {
  return {
    id,
    finalText,
    status,
    origin: "model",
    backend: "codex",
    title: "test",
    prompt: "test",
    cwd: "/tmp",
    createdAt: 0,
    meta: {},
    usage: {},
    transcript: [],
    liveTools: [],
    queued: [],
    turns: 1,
  };
}

function waitResult(snapshots: readonly SubagentSnapshot[]) {
  return formatWaitResult(
    snapshots.map((snap) => ({ id: snap.id, snapshot: snap })),
    limits,
  );
}

function checkResult(snap: SubagentSnapshot) {
  return formatCheckResult(snap, `${snap.id} [${snap.status}] "test"`);
}

test("check exposes exact settled output, errors, and empty answers", () => {
  assert.deepEqual(checkResult(snapshot("done")), {
    text: 'done [done] "test"\nTurns: 1\n\nLatest output:\nanswer',
    consumedIds: ["done"],
  });
  assert.deepEqual(
    checkResult({ ...snapshot("error", "", "error"), errorText: "failed" }),
    {
      text: 'error [error] "test"\nTurns: 1\nError: failed',
      consumedIds: ["error"],
    },
  );
  assert.deepEqual(checkResult(snapshot("empty", "")), {
    text: 'empty [done] "test"\nTurns: 1',
    consumedIds: ["empty"],
  });
});

test("check running previews never acknowledge and prefer live text", () => {
  assert.deepEqual(
    checkResult({
      ...snapshot("running", "old", "running"),
      liveAssistant: { text: " live answer ", thinking: "" },
    }),
    {
      text: 'running [running] "test"\nTurns: 1\n\nLatest output:\nlive answer',
      consumedIds: [],
    },
  );
  assert.deepEqual(checkResult(snapshot("running", "", "running")), {
    text: 'running [running] "test"\nTurns: 1\n\n(no text output yet)',
    consumedIds: [],
  });
});

test("check acknowledges exact preview limits, not byte or line truncation", () => {
  for (const output of ["é".repeat(1024), Array(20).fill("line").join("\n")]) {
    const result = checkResult(snapshot("exact", output));
    assert.deepEqual(result.consumedIds, ["exact"]);
    assert.equal(
      result.text,
      `exact [done] "test"\nTurns: 1\n\nLatest output:\n${output}`,
    );
  }
  for (const output of ["é".repeat(1025), Array(21).fill("line").join("\n")]) {
    const result = checkResult(snapshot("truncated", output));
    assert.deepEqual(result.consumedIds, []);
    assert.ok(result.text.endsWith("\n[...]"));
  }
});

test("wait preserves sections, errors, missing snapshots, and empty output", () => {
  assert.deepEqual(
    formatWaitResult(
      [
        { id: "missing" },
        { id: "done", snapshot: snapshot("done") },
        {
          id: "error",
          snapshot: { ...snapshot("error", "", "error"), errorText: "failed" },
        },
      ],
      limits,
    ),
    {
      text: [
        "## missing\n\n(no longer tracked)",
        '## done "test" finished\n\nanswer',
        '## error "test" failed\nError: failed\n\n(no output)',
      ].join(separator),
      consumedIds: ["done", "error"],
    },
  );
  assert.deepEqual(
    waitResult([snapshot("running", "answer", "running")]).consumedIds,
    [],
  );
});

test("output formatting retains transcript hint and reports truncation separately", () => {
  assert.deepEqual(formatSubagentOutput(snapshot("empty", ""), 1024), {
    text: "(no output)",
    truncated: false,
  });
  const snap = {
    ...snapshot("large", "é".repeat(1025)),
    meta: { sessionFilePath: "/tmp/session.jsonl" },
  };
  const result = formatSubagentOutput(snap, 2048);
  assert.equal(result.truncated, true);
  assert.match(
    result.text,
    /\[Output truncated: .* Full transcript in session file: \/tmp\/session.jsonl\]$/,
  );
  assert.ok(!result.text.includes("�"));
});

test("wait acknowledges only full sections surviving per-agent and total byte limits", () => {
  const result = waitResult([
    snapshot("short"),
    ...Array.from({ length: 5 }, (_, i) =>
      snapshot(`large-${i}`, Array(100).fill("é".repeat(100)).join("\n")),
    ),
    snapshot("omitted"),
  ]);
  assert.deepEqual(result.consumedIds, ["short"]);
  assert.match(result.text, /omitted|truncated/);
  assert.ok(!result.text.includes('## omitted "test"'));
  assert.ok(Buffer.byteLength(result.text, "utf8") <= limits.maxBytes);
});

test("wait per-agent byte and line limits acknowledge only complete output", () => {
  for (const [output, complete] of [
    ["é".repeat(8192), true],
    ["é".repeat(8193), false],
    [Array(600).fill("line").join("\n"), true],
    [Array(601).fill("line").join("\n"), false],
  ] as const) {
    const result = waitResult([snapshot("result", output)]);
    assert.deepEqual(result.consumedIds, complete ? ["result"] : []);
    assert.equal(result.text.includes("[Output truncated:"), !complete);
  }
});

test("wait does not acknowledge sections cut by the combined line limit", () => {
  const result = waitResult(
    Array.from({ length: 4 }, (_, i) =>
      snapshot(`sa-${i}`, Array(550).fill("line").join("\n")),
    ),
  );
  assert.deepEqual(result.consumedIds, ["sa-0", "sa-1", "sa-2"]);
  assert.ok(
    result.text.endsWith("[wait output truncated at the total output limit]"),
  );
});

test("wait global cutoff accounts for missing sections and multibyte titles", () => {
  const first = snapshot("first", "answer");
  const last = { ...snapshot("last", "answer"), title: "é".repeat(200) };
  const results = [
    { id: "missing" },
    { id: first.id, snapshot: first },
    { id: last.id, snapshot: last },
  ];
  const full = formatWaitResult(results, limits);
  const result = formatWaitResult(results, {
    ...limits,
    maxBytes: Buffer.byteLength(full.text, "utf8") + 127,
  });
  assert.deepEqual(result.consumedIds, ["first"]);
  assert.ok(
    result.text.endsWith("[wait output truncated at the total output limit]"),
  );
});

test("wait does not acknowledge a section when only its trailing newline was cut", () => {
  const snap = snapshot("last", "answer\n");
  const full = waitResult([snap]);
  const result = formatWaitResult([{ id: snap.id, snapshot: snap }], {
    ...limits,
    maxBytes: Buffer.byteLength(full.text, "utf8") + 127,
  });
  assert.deepEqual(result.consumedIds, []);
});
