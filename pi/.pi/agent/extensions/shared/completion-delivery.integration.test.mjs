import assert from "node:assert/strict";
import test from "node:test";
import { Agent } from "@earendil-works/pi-agent-core";
import {
  AgentSession,
  SessionManager,
  SettingsManager,
  convertToLlm,
  createEventBus,
  createExtensionRuntime,
} from "@earendil-works/pi-coding-agent";
import { createCompletionDelivery } from "./completion-delivery.ts";

const { loadExtensionFromFactory } = await import(
  new URL(
    "./core/extensions/loader.js",
    import.meta.resolve("@earendil-works/pi-coding-agent"),
  )
);
const model = {
  id: "fake",
  name: "fake",
  provider: "fake",
  api: "fake",
  reasoning: false,
  input: ["text"],
  contextWindow: 100000,
  maxTokens: 1000,
  cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
};
const usage = {
  input: 0,
  output: 0,
  cacheRead: 0,
  cacheWrite: 0,
  totalTokens: 0,
  cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
};

// Real Pi scheduler and extension bus, but a deterministic fake provider.
// Map-only tests cannot catch session-state vs active-loop-context differences.
async function scenario({
  sources = 2,
  final = false,
  consume = false,
  abort = false,
  idle = false,
  terminate = false,
  queuedUser = false,
  errorSecond = false,
  consumeSecond = false,
} = {}) {
  const runtime = createExtensionRuntime();
  const bus = createEventBus();
  const runner = { current: undefined };
  const deliveries = [];
  const calls = [];
  const errors = [];
  const extensions = [];
  for (let i = 0; i < sources; i++) {
    extensions.push(
      await loadExtensionFromFactory(
        (pi) => {
          deliveries.push(
            createCompletionDelivery(pi, {
              customType: `result-${i}`,
              buildMessage: (results) => ({
                content: results.map((r) => r.output).join("\n"),
              }),
            }),
          );
        },
        "/tmp",
        bus,
        runtime,
        `<completion-test-${i}>`,
      ),
    );
  }
  const settle = () => {
    for (let source = 0; source < deliveries.length; source++) {
      for (let i = 0; i < 22; i++) {
        deliveries[source].defer({
          id: `${source}-${i}`,
          output: `RESULT-${source}-${i}`,
        });
      }
      if (consume)
        deliveries[source].consume(
          Array.from({ length: 22 }, (_, i) => `${source}-${i}`),
        );
    }
  };
  const loader = {
    getExtensions: () => ({ extensions, errors: [], runtime }),
    getSystemPrompt: () => "test",
    getAppendSystemPrompt: () => [],
    getSkills: () => ({ skills: [] }),
    getAgentsFiles: () => ({ agentsFiles: [] }),
    getPrompts: () => ({ prompts: [] }),
  };
  const agent = new Agent({
    steeringMode: "one-at-a-time",
    initialState: { model, systemPrompt: "test", thinkingLevel: "off" },
    convertToLlm,
    transformContext: (messages) => runner.current.emitContext(messages),
    streamFn: async (_model, context) => {
      calls.push(structuredClone(context.messages));
      assert.ok(
        calls.length <= 4,
        "completion delivery caused a response flood",
      );
      const first = calls.length === 1;
      const tool =
        (first && !final && !idle && !abort) ||
        (calls.length === 2 && consumeSecond);
      if (first && (final || abort)) settle();
      const response = {
        role: "assistant",
        content: tool
          ? [
              {
                type: "toolCall",
                id: `test-tool-${calls.length}`,
                name: first ? "work" : "collect",
                arguments: {},
              },
            ]
          : [{ type: "text", text: "final" }],
        api: "fake",
        provider: "fake",
        model: "fake",
        usage,
        timestamp: Date.now(),
        stopReason:
          first && abort
            ? "aborted"
            : calls.length === 2 && errorSecond
              ? "error"
              : tool
                ? "toolUse"
                : "stop",
      };
      return {
        async *[Symbol.asyncIterator]() {
          yield {
            type: "done",
            reason: response.stopReason,
            message: response,
          };
        },
        result: async () => response,
      };
    },
  });
  const session = new AgentSession({
    agent,
    sessionManager: SessionManager.inMemory("/tmp"),
    settingsManager: SettingsManager.inMemory({
      compaction: { enabled: false },
      retry: { enabled: false },
    }),
    cwd: "/tmp",
    resourceLoader: loader,
    modelRuntime: { hasConfiguredAuth: () => true },
    extensionRunnerRef: runner,
    baseToolsOverride: {
      work: {
        name: "work",
        label: "work",
        description: "fake work",
        parameters: { type: "object", properties: {} },
        execute: async () => {
          if (queuedUser) await session.steer("user steering takes priority");
          settle();
          return {
            content: [{ type: "text", text: "tool finished" }],
            details: {},
            terminate,
          };
        },
      },
      collect: {
        name: "collect",
        label: "collect",
        description: "collect completed results",
        parameters: { type: "object", properties: {} },
        execute: async () => {
          for (let source = 0; source < deliveries.length; source++) {
            deliveries[source].consume(
              Array.from({ length: 22 }, (_, i) => `${source}-${i}`),
            );
          }
          return {
            content: [{ type: "text", text: "results retrieved" }],
            details: {},
          };
        },
      },
    },
  });
  try {
    await session.bindExtensions({ onError: (error) => errors.push(error) });
    await session.prompt("start", { expandPromptTemplates: false });
    if (idle) {
      deliveries[0].defer({ id: "late", output: "RESULT-late" });
      await session.waitForIdle();
    }
    assert.deepEqual(errors, []);
    assert.equal(session.isIdle, true);
    assert.equal(agent.hasQueuedMessages(), false);
    const completions = session.sessionManager
      .getEntries()
      .filter((e) => e.type === "custom_message");
    return { calls, completions };
  } finally {
    session.dispose();
  }
}

function seen(messages) {
  return (JSON.stringify(messages).match(/RESULT-[\w-]+/g) ?? []).length;
}

test(
  "44 completions across two extensions reach the next normal response in one batch",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario();
    assert.deepEqual(calls.map(seen), [0, 44]);
    assert.equal(completions.length, 1);
    assert.equal(completions[0].customType, "background-completions");
  },
);

test(
  "single-extension batches keep their existing message type",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario({ sources: 1 });
    assert.deepEqual(calls.map(seen), [0, 22]);
    assert.equal(completions[0].customType, "result-0");
  },
);

test(
  "results consumed by tools never enter the steering queue",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario({ consume: true });
    assert.deepEqual(calls.map(seen), [0, 0]);
    assert.equal(completions.length, 0);
  },
);

test(
  "completions during a final answer cause only one shared continuation",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario({ final: true });
    assert.deepEqual(calls.map(seen), [0, 44]);
    assert.equal(completions.length, 1);
  },
);

test(
  "aborted parent is not restarted by pending completions",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario({ abort: true });
    assert.equal(calls.length, 1);
    assert.equal(completions.length, 0);
  },
);

test(
  "a genuinely late idle result wakes the model once",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario({ idle: true });
    assert.deepEqual(calls.map(seen), [0, 1]);
    assert.equal(completions.length, 1);
  },
);

test(
  "terminating tools do not strand new results in session-only context",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario({ terminate: true });
    assert.deepEqual(calls.map(seen), [0, 44]);
    assert.equal(completions.length, 1);
  },
);

test(
  "a queued user response can consume results before any completion is submitted",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario({
      queuedUser: true,
      consumeSecond: true,
    });
    assert.deepEqual(calls.map(seen), [0, 0, 0]);
    assert.equal(completions.length, 0);
  },
);

test(
  "a queued user response failing does not leave a completion that restarts the agent",
  { timeout: 10000 },
  async () => {
    const { calls, completions } = await scenario({
      queuedUser: true,
      errorSecond: true,
    });
    assert.deepEqual(calls.map(seen), [0, 0]);
    assert.equal(completions.length, 0);
  },
);
