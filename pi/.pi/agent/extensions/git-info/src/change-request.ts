import type { ChangeRequestInfo } from "../../shared/dashboard-state.ts";

export type Forge = "github" | "gitlab";

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function remoteHost(remote: string) {
  const value = remote.trim();
  if (!value) return null;

  try {
    return new URL(value).hostname.toLowerCase();
  } catch {
    const scpHost = value.match(/^(?:[^@]+@)?([^:/]+):/);
    return scpHost?.[1]?.toLowerCase() ?? null;
  }
}

export function forgeForRemote(remote: string): Forge | null {
  const host = remoteHost(remote);
  if (!host) return null;

  if (host.includes("github")) return "github";
  if (host.includes("gitlab")) return "gitlab";
  return null;
}

export function parseGitHubPullRequest(value: unknown) {
  if (!isRecord(value)) return null;
  if (typeof value.number !== "number") return null;
  if (typeof value.url !== "string") return null;
  if (value.state !== "OPEN") return null;

  return {
    kind: "pull-request",
    number: value.number,
    url: value.url,
    isDraft: value.isDraft === true,
  } satisfies ChangeRequestInfo;
}

export function parseGitLabMergeRequest(value: unknown) {
  if (!isRecord(value)) return null;
  if (typeof value.iid !== "number") return null;
  if (typeof value.web_url !== "string") return null;
  if (value.state !== "opened") return null;

  return {
    kind: "merge-request",
    number: value.iid,
    url: value.web_url,
    isDraft: value.draft === true || value.work_in_progress === true,
  } satisfies ChangeRequestInfo;
}

export function parseJson(
  value: string,
  parser: (value: unknown) => ChangeRequestInfo | null,
) {
  try {
    return parser(JSON.parse(value));
  } catch {
    return null;
  }
}
