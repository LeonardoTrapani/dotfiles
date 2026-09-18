import { randomUUID } from "node:crypto";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

const MAX_BATCH_BYTES = 48 * 1024;
const COLLECT_COMPLETIONS = "dotfiles:collect-completions:v1";
const BATCH_TYPE = "background-completions";

type CompletionMessage = {
  content: string;
  details?: Record<string, unknown>;
};
type Collection = {
  sessionId: string;
  token: string;
  batches: {
    customType: string;
    ids: string[];
    message: CompletionMessage;
    release: () => void;
  }[];
};

export function formatCompletionBatch(
  sections: readonly { text: string; retrievalHint: string }[],
): string {
  if (sections.length === 0) return "";
  const separator = "\n\n---\n\n";
  const budget = Math.floor(
    (MAX_BATCH_BYTES - separator.length * (sections.length - 1)) /
      sections.length,
  );
  return sections
    .map(({ text, retrievalHint }) => {
      const bytes = Buffer.from(text);
      if (bytes.length <= budget) return text;
      const suffix = `\n\n[Batch output truncated. ${retrievalHint}]`;
      let end = Math.max(0, budget - Buffer.byteLength(suffix));
      while (end > 0 && (bytes[end]! & 0xc0) === 0x80) end--;
      return bytes.subarray(0, end).toString("utf8") + suffix;
    })
    .join(separator);
}

/** Collect across extensions before submitting: Pi's default steering queue
 * takes one message at a time, so even separate per-extension batches would
 * add turns. The event bus also works across independently loaded modules. */
export function createCompletionDelivery<T extends { id: string }>(
  pi: Pick<ExtensionAPI, "on" | "sendMessage" | "events">,
  options: {
    customType: string;
    buildMessage: (results: readonly T[]) => CompletionMessage;
  },
) {
  const pending = new Map<string, T>();
  let context: ExtensionContext | undefined;
  let paused = false;
  let submitted: { token: string; results: readonly T[] } | undefined;

  pi.events.on(COLLECT_COMPLETIONS, (data) => {
    const collection = data as Collection;
    if (
      !context ||
      paused ||
      submitted ||
      pending.size === 0 ||
      collection.sessionId !== context.sessionManager.getSessionId()
    )
      return;
    const results = [...pending.values()];
    const message = options.buildMessage(results);
    submitted = { token: collection.token, results };
    collection.batches.push({
      customType: options.customType,
      ids: results.map((result) => result.id),
      message,
      release: () => {
        if (submitted?.token === collection.token) submitted = undefined;
      },
    });
  });

  const acknowledge = (message: {
    role: string;
    customType?: string;
    details?: unknown;
  }) => {
    if (
      !submitted ||
      message.role !== "custom" ||
      (message.customType !== options.customType &&
        message.customType !== BATCH_TYPE) ||
      !message.details ||
      typeof message.details !== "object" ||
      !("completionDeliveryId" in message.details) ||
      message.details.completionDeliveryId !== submitted.token
    )
      return;
    for (const result of submitted.results) {
      if (pending.get(result.id) === result) pending.delete(result.id);
    }
    submitted = undefined;
  };

  const flush = () => {
    if (!context || paused || submitted) return;
    // User messages take priority. Queuing behind one would let its tool
    // calls consume results we can no longer retract from Pi's queue, or
    // leave a completion that restarts the agent after that response fails.
    if (context.hasPendingMessages()) return;
    const collection: Collection = {
      sessionId: context.sessionManager.getSessionId(),
      token: randomUUID(),
      batches: [],
    };
    pi.events.emit(COLLECT_COMPLETIONS, collection);
    if (collection.batches.length === 0) return;
    const first = collection.batches[0]!;
    const multiple = collection.batches.length > 1;
    try {
      pi.sendMessage(
        {
          customType: multiple ? BATCH_TYPE : first.customType,
          content: multiple
            ? formatCompletionBatch(
                collection.batches.map((batch) => ({
                  text: `${batch.customType}: ${batch.ids.join(", ")}\n\n${batch.message.content}`,
                  retrievalHint:
                    "Use bg_status or subagent_wait for the IDs listed above.",
                })),
              )
            : first.message.content,
          display: true,
          details: {
            ...(multiple
              ? {
                  batches: collection.batches.map(({ customType, ids }) => ({
                    customType,
                    ids,
                  })),
                }
              : first.message.details),
            completionDeliveryId: collection.token,
          },
        },
        { deliverAs: "steer", triggerTurn: true },
      );
    } catch (error) {
      for (const batch of collection.batches) batch.release();
      console.error(
        `${options.customType}: failed to submit completion`,
        error,
      );
    }
  };

  pi.on("session_start", (_event, ctx) => {
    context = ctx;
    paused = false;
  });
  pi.on("agent_start", () => {
    paused = false;
  });
  pi.on("turn_end", (event, ctx) => {
    if (
      ctx.signal?.aborted ||
      (event.message.role === "assistant" &&
        (event.message.stopReason === "aborted" ||
          event.message.stopReason === "error"))
    ) {
      paused = true;
      return;
    }
    flush();
  });
  pi.on("agent_end", (event, ctx) => {
    const lastAssistant = event.messages.findLast(
      (message) => message.role === "assistant",
    );
    if (
      ctx.signal?.aborted ||
      lastAssistant?.stopReason === "aborted" ||
      lastAssistant?.stopReason === "error"
    ) {
      paused = true;
    }
  });
  pi.on("message_end", (event) => {
    acknowledge(event.message);
  });
  pi.on("agent_settled", () => {
    // Escape can discard queued steering before message_end. Keep the
    // underlying results, but do not wake the agent until work resumes.
    if (paused) submitted = undefined;
    else flush();
  });
  pi.on("session_shutdown", () => {
    context = undefined;
    pending.clear();
    submitted = undefined;
  });

  return {
    defer(result: T) {
      if (!context) return;
      pending.set(result.id, result);
      if (context.isIdle()) flush();
    },
    consume(ids: Iterable<string>) {
      for (const id of ids) pending.delete(id);
    },
    clear() {
      pending.clear();
      submitted = undefined;
    },
  };
}
