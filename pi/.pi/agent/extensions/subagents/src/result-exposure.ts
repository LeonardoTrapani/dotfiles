import {
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  formatSize,
  truncateHead,
} from "@earendil-works/pi-coding-agent";
import { latestText, type SubagentSnapshot } from "./domain.ts";

export interface ResultExposure {
  readonly text: string;
  readonly consumedIds: string[];
}

export function formatSubagentOutput(snap: SubagentSnapshot, maxBytes: number) {
  const truncation = truncateHead(snap.finalText || "(no output)", {
    maxBytes: Math.min(maxBytes, DEFAULT_MAX_BYTES),
    maxLines: Math.min(600, DEFAULT_MAX_LINES),
  });
  let text = truncation.content;
  if (truncation.truncated) {
    text += `\n\n[Output truncated: ${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)} shown. Full transcript in session file: ${snap.meta.sessionFilePath ?? "?"}]`;
  }
  return { text, truncated: truncation.truncated };
}

export function formatWaitResult(
  results: ReadonlyArray<{
    readonly id: string;
    readonly snapshot?: SubagentSnapshot;
  }>,
  limits: { readonly maxBytes: number; readonly perAgentMaxBytes: number },
): ResultExposure {
  const separator = "\n\n---\n\n";
  const sections: string[] = [];
  const exposed: Array<{ id: string; end: number }> = [];
  let combinedLength = 0;
  let remainingBytes = limits.maxBytes;
  for (const { id, snapshot: snap } of results) {
    if (!snap) {
      const section = `## ${id}\n\n(no longer tracked)`;
      combinedLength +=
        (sections.length > 0 ? separator.length : 0) + section.length;
      sections.push(section);
      continue;
    }
    const verb = snap.status === "error" ? "failed" : "finished";
    let section = `## ${snap.id} "${snap.title}" ${verb}`;
    if (snap.errorText) section += `\nError: ${snap.errorText}`;
    const headerBytes = Buffer.byteLength(section, "utf8") + 2;
    const outputBudget = Math.max(
      512,
      Math.min(limits.perAgentMaxBytes, remainingBytes - headerBytes),
    );
    const output = formatSubagentOutput(snap, outputBudget);
    section += `\n\n${output.text}`;
    const sectionBytes = Buffer.byteLength(section, "utf8");
    if (sectionBytes > remainingBytes) {
      sections.push(
        `## ${snap.id} "${snap.title}"\n\n[omitted: total wait output limit reached]`,
      );
      break;
    }
    combinedLength +=
      (sections.length > 0 ? separator.length : 0) + section.length;
    sections.push(section);
    remainingBytes -= sectionBytes;
    if (snap.status !== "running" && !output.truncated) {
      exposed.push({ id, end: combinedLength });
    }
  }

  const bounded = truncateHead(sections.join(separator), {
    maxBytes: limits.maxBytes - 128,
    maxLines: DEFAULT_MAX_LINES,
  });
  const text = bounded.truncated
    ? `${bounded.content}\n\n[wait output truncated at the total output limit]`
    : bounded.content;
  return {
    text,
    // Offsets refer to the actual joined text, including missing-result sections
    // and separators. A complete per-agent preview can still be cut globally.
    consumedIds: exposed
      .filter(({ end }) => end <= bounded.content.length)
      .map(({ id }) => id),
  };
}

export function formatCheckResult(
  snap: SubagentSnapshot,
  description: string,
): ResultExposure {
  let text = `${description}\nTurns: ${snap.turns}`;
  if (snap.errorText) text += `\nError: ${snap.errorText}`;

  const output = snap.status === "running" ? latestText(snap) : snap.finalText;
  const preview = truncateHead(output, { maxBytes: 2048, maxLines: 20 });
  if (output) {
    text += `\n\nLatest output:\n${preview.content}`;
    if (preview.truncated) text += "\n[...]";
  } else if (snap.status === "running") {
    text += "\n\n(no text output yet)";
  }

  return {
    text,
    consumedIds:
      snap.status !== "running" && !preview.truncated ? [snap.id] : [],
  };
}
