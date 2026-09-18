import assert from "node:assert/strict";
import test from "node:test";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  createCompletionDelivery,
  formatCompletionBatch,
} from "./completion-delivery.ts";

type Result = { id: string; output: string };
type Message = {
  role: "custom";
  customType: string;
  content: string;
  details: { completionDeliveryId: string };
};
type Handler = (event: unknown, ctx: ExtensionContext) => unknown;

function harness() {
  const handlers = new Map<string, Handler[]>();
  const bus = new Map<string, ((data: unknown) => void)[]>();
  const sent: { message: Message; triggerTurn: boolean; deliverAs: string }[] =
    [];
  let idle = false;
  let pendingMessages = false;
  let failSend = false;
  const controller = new AbortController();
  const ctx = {
    isIdle: () => idle,
    hasPendingMessages: () => pendingMessages,
    signal: controller.signal,
    sessionManager: {
      getSessionId: () => "test-session",
    },
  } as unknown as ExtensionContext;
  const pi = {
    events: {
      on(name: string, handler: (data: unknown) => void) {
        bus.set(name, [...(bus.get(name) ?? []), handler]);
      },
      emit(name: string, data: unknown) {
        for (const handler of bus.get(name) ?? []) handler(data);
      },
    },
    on(name: string, handler: Handler) {
      handlers.set(name, [...(handlers.get(name) ?? []), handler]);
    },
    sendMessage(
      message: Omit<Message, "role">,
      options: { triggerTurn: boolean; deliverAs: string },
    ) {
      if (failSend) throw new Error("session unavailable");
      sent.push({ message: { role: "custom", ...message }, ...options });
    },
  } as unknown as ExtensionAPI;
  const source = (customType: string) =>
    createCompletionDelivery<Result>(pi, {
      customType,
      buildMessage: (results) => ({
        content: results.map((r) => `${r.id}: ${r.output}`).join("\n"),
      }),
    });
  const delivery = source("test-completions");
  async function emit(name: string, event: unknown = {}) {
    for (const handler of handlers.get(name) ?? []) await handler(event, ctx);
  }
  async function turnEnd(
    tools = true,
    stopReason = tools ? "toolUse" : "stop",
  ) {
    await emit("turn_end", {
      message: { role: "assistant", stopReason },
      toolResults: tools ? [{}] : [],
    });
  }
  async function append(index: number) {
    await emit("message_end", { message: sent[index]!.message });
  }
  return {
    delivery,
    source,
    sent,
    emit,
    turnEnd,
    append,
    controller,
    setIdle(value: boolean) {
      idle = value;
    },
    setFailSend(value: boolean) {
      failSend = value;
    },
    setPendingMessages(value: boolean) {
      pendingMessages = value;
    },
  };
}

test("22 completions join the next tool response, not 22 post-final continuations", async () => {
  const h = harness();
  await h.emit("session_start");
  for (let i = 0; i < 22; i++)
    h.delivery.defer({ id: `job-${i}`, output: "done" });
  assert.equal(h.sent.length, 0);
  await h.turnEnd();
  assert.equal(h.sent.length, 1);
  assert.equal(h.sent[0]!.deliverAs, "steer");
  assert.equal(h.sent[0]!.triggerTurn, true);
  assert.equal(h.sent[0]!.message.content.split("\n").length, 22);
  await h.append(0);
  await h.turnEnd(false);
  h.setIdle(true);
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 1);
});

test("different extensions share one steering batch and acknowledgment", async () => {
  const h = harness();
  const other = h.source("other-completions");
  await h.emit("session_start");
  h.delivery.defer({ id: "terminal", output: "built" });
  other.defer({ id: "subagent", output: "reviewed" });
  await h.turnEnd();
  assert.equal(h.sent.length, 1);
  assert.equal(h.sent[0]!.message.customType, "background-completions");
  assert.match(h.sent[0]!.message.content, /terminal: built/);
  assert.match(h.sent[0]!.message.content, /subagent: reviewed/);
  await h.append(0);
  await h.turnEnd(false);
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 1);
});

test("failed shared submission releases every contributing extension", async (t) => {
  t.mock.method(console, "error", () => {});
  const h = harness();
  const other = h.source("other-completions");
  await h.emit("session_start");
  h.delivery.defer({ id: "terminal", output: "built" });
  other.defer({ id: "subagent", output: "reviewed" });
  h.setFailSend(true);
  await h.turnEnd();
  h.setFailSend(false);
  await h.turnEnd();
  assert.equal(h.sent.length, 1);
  assert.match(h.sent[0]!.message.content, /terminal: built/);
  assert.match(h.sent[0]!.message.content, /subagent: reviewed/);
});

test("a successful result retrieval before the tool boundary consumes its notification", async () => {
  const h = harness();
  await h.emit("session_start");
  h.delivery.defer({ id: "read", output: "already returned by tool" });
  h.delivery.defer({ id: "unread", output: "new result" });
  h.delivery.consume(["read"]);
  await h.turnEnd();
  assert.equal(h.sent[0]!.message.content, "unread: new result");
});

test("queued user messages leave completions retractable until their response", async () => {
  const h = harness();
  await h.emit("session_start");
  h.delivery.defer({ id: "one", output: "done" });
  h.setPendingMessages(true);
  await h.turnEnd();
  assert.equal(h.sent.length, 0);
  h.setPendingMessages(false);
  h.delivery.consume(["one"]);
  await h.turnEnd();
  assert.equal(h.sent.length, 0);
});

test("a completion during a final response requests one batched continuation", async () => {
  const h = harness();
  await h.emit("session_start");
  h.delivery.defer({ id: "one", output: "done" });
  h.delivery.defer({ id: "two", output: "done" });
  await h.turnEnd(false);
  assert.equal(h.sent.length, 1);
  assert.equal(h.sent[0]!.triggerTurn, true);
  await h.append(0);
  await h.turnEnd(false);
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 1);
});

test("a genuine idle completion still wakes the model", async () => {
  const h = harness();
  await h.emit("session_start");
  h.setIdle(true);
  h.delivery.defer({ id: "late", output: "done" });
  assert.equal(h.sent.length, 1);
  assert.equal(h.sent[0]!.triggerTurn, true);
  await h.append(0);
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 1);
});

test("a result arriving after the last turn boundary is delivered at settlement", async () => {
  const h = harness();
  await h.emit("session_start");
  await h.turnEnd(false);
  h.delivery.defer({ id: "late", output: "done" });
  h.setIdle(true);
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 1);
  assert.equal(h.sent[0]!.triggerTurn, true);
});

test("submission is not acknowledgment and repeated boundaries cannot resubmit it", async () => {
  const h = harness();
  await h.emit("session_start");
  h.delivery.defer({ id: "one", output: "done" });
  await h.turnEnd();
  await h.turnEnd();
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 1);
  await h.append(0);
  await h.turnEnd();
  assert.equal(h.sent.length, 1);
});

test("acknowledging an older batch does not consume a newer settlement of the same job", async () => {
  const h = harness();
  await h.emit("session_start");
  h.delivery.defer({ id: "one", output: "first run" });
  await h.turnEnd();
  h.delivery.defer({ id: "one", output: "second run" });
  await h.append(0);
  await h.turnEnd();
  assert.equal(h.sent.length, 2);
  assert.equal(h.sent[1]!.message.content, "one: second run");
});

for (const stopReason of ["aborted", "error"]) {
  test(`${stopReason} does not restart the agent; unread results survive until work resumes`, async () => {
    const h = harness();
    await h.emit("session_start");
    h.delivery.defer({ id: "one", output: "done" });
    await h.turnEnd(false, stopReason);
    h.setIdle(true);
    await h.emit("agent_settled");
    h.delivery.defer({ id: "two", output: "finished after abort" });
    assert.equal(h.sent.length, 0);
    h.setIdle(false);
    await h.emit("agent_start");
    await h.turnEnd();
    assert.equal(h.sent.length, 1);
    assert.match(h.sent[0]!.message.content, /one: done\ntwo:/);
  });
}

test("an aborted queued batch can be retried without discarding pending results", async () => {
  const h = harness();
  await h.emit("session_start");
  h.delivery.defer({ id: "one", output: "done" });
  await h.turnEnd(false);
  // Escape discarded the steering batch before it was appended.
  await h.turnEnd(false, "aborted");
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 1);
  await h.emit("agent_start");
  await h.turnEnd();
  assert.equal(h.sent.length, 2);
});

test("a terminating tool turn still delivers genuinely new results through steering", async () => {
  const h = harness();
  await h.emit("session_start");
  h.delivery.defer({ id: "one", output: "done" });
  await h.turnEnd();
  await h.append(0);
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 1);
});

test("shutdown ignores late callbacks and clears all pending/submitted work", async () => {
  const h = harness();
  h.delivery.defer({ id: "before-start", output: "ignored" });
  await h.emit("session_start");
  h.delivery.defer({ id: "old", output: "done" });
  await h.emit("session_shutdown");
  h.setIdle(true);
  h.delivery.defer({ id: "shutdown-kill", output: "ignored" });
  await h.emit("agent_settled");
  assert.equal(h.sent.length, 0);
  await h.emit("session_start");
  h.delivery.defer({ id: "new", output: "done" });
  assert.equal(h.sent[0]!.message.content, "new: done");
});

test("synchronous submission failure preserves results for a later boundary", async (t) => {
  t.mock.method(console, "error", () => {});
  const h = harness();
  await h.emit("session_start");
  h.delivery.defer({ id: "one", output: "done" });
  h.setFailSend(true);
  await h.turnEnd();
  h.setFailSend(false);
  await h.turnEnd();
  assert.equal(h.sent.length, 1);
});

test("batches bound total UTF-8 output and retain every job's retrieval hint", () => {
  const sections = Array.from({ length: 22 }, (_, i) => ({
    text: `job-${i}\n${"😀".repeat(20_000)}`,
    retrievalHint: `Read job-${i}.`,
  }));
  const text = formatCompletionBatch(sections);
  assert.ok(Buffer.byteLength(text) <= 48 * 1024);
  assert.ok(!text.includes("�"));
  for (let i = 0; i < 22; i++) assert.ok(text.includes(`Read job-${i}.`));
});
