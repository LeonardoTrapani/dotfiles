#!/usr/bin/env python3
"""Compare DOS tickets in delivery states with their GitLab MRs and the last release.

Run from the Dual repo root. Needs authenticated `acli` and `glab`.
Prints JSON: {release, versionPackagesMr, tickets: [{key, status, suggested, reason, mrs, ...}]}.
"""
from datetime import datetime
import json
import re
import subprocess
import sys

PROJECT = "dual%2Fdual"
STATUSES = ["Doing", "PR Review", "To deploy"]


def run(*cmd, check=True):
    return subprocess.run(cmd, capture_output=True, text=True, check=check).stdout


def glab_pages(path, max_pages):
    items = []
    for page in range(1, max_pages + 1):
        batch = json.loads(run("glab", "api", f"{path}&per_page=100&page={page}"))
        items += batch
        if len(batch) < 100:
            break
    return items


def keys_of(mr):
    text = " ".join([mr["title"], mr["source_branch"], mr.get("description") or ""])
    return {f"DOS-{n}" for n in re.findall(r"(?i)\bdos[-_ ](\d+)", text)}


def main():
    run("git", "fetch", "origin", "--tags", "--quiet")
    tags = [t for t in run("git", "tag", "-l", "dual-release-*").split() if t]
    release = max(tags, key=lambda t: int(t.rsplit(".", 1)[1])) if tags else None
    release_sha = run("git", "rev-list", "-n1", release).strip() if release else None
    release_time = run("git", "log", "-1", "--format=%cI", release_sha).strip() if release_sha else None

    def released(sha, merged_at):
        if not release_sha:
            return False
        if sha and subprocess.run(["git", "merge-base", "--is-ancestor", sha, release_sha],
                                  capture_output=True).returncode == 0:
            return True
        # Older MRs may lack a reachable merge commit; master is linear in merges, so time decides.
        return datetime.fromisoformat(merged_at) <= datetime.fromisoformat(release_time)

    jql = "project = DOS AND status in (%s)" % ",".join(f'"{s}"' for s in STATUSES)
    tickets = json.loads(run("acli", "jira", "workitem", "search", "--jql", jql,
                             "--fields", "key,status,summary,assignee", "--paginate", "--json"))

    opened = glab_pages(f"projects/{PROJECT}/merge_requests?state=opened", 3)
    merged = glab_pages(f"projects/{PROJECT}/merge_requests?state=merged&target_branch=master&order_by=updated_at", 4)
    version_mr = next((m["iid"] for m in opened if m["source_branch"] == "changeset-release/master"), None)

    mrs = []
    for m in opened + merged:
        sha = m.get("merge_commit_sha") or m.get("squash_commit_sha")
        mrs.append({
            "iid": m["iid"], "title": m["title"], "branch": m["source_branch"],
            "state": m["state"], "draft": bool(m.get("draft")),
            "mergedAt": m.get("merged_at"),
            "released": released(sha, m["merged_at"]) if m["state"] == "merged" else None,
            "keys": keys_of(m),
        })

    out = []
    for t in tickets:
        key, f = t["key"], t["fields"]
        linked = [m for m in mrs if key in m["keys"]]
        ready = [m for m in linked if m["state"] == "opened" and not m["draft"]]
        drafts = [m for m in linked if m["state"] == "opened" and m["draft"]]
        unreleased = [m for m in linked if m["state"] == "merged" and not m["released"]]
        shipped = [m for m in linked if m["state"] == "merged" and m["released"]]
        if ready:
            suggested, reason = "PR Review", "open MR " + " ".join(f"!{m['iid']}" for m in ready)
        elif unreleased:
            suggested, reason = "To deploy", "merged after " + str(release) + ": " + " ".join(f"!{m['iid']}" for m in unreleased)
        elif drafts:
            suggested, reason = "Doing", "only draft MR " + " ".join(f"!{m['iid']}" for m in drafts)
        elif shipped:
            suggested, reason = "Done", "released: " + " ".join(f"!{m['iid']}" for m in shipped)
        elif f["status"]["name"] == "Doing":
            suggested, reason = "Doing", "no MR yet"
        else:
            suggested, reason = None, "no MR references this key; match by title or ask"
        out.append({
            "key": key, "status": f["status"]["name"], "suggested": suggested, "reason": reason,
            "summary": f["summary"], "assignee": (f.get("assignee") or {}).get("displayName"),
            "mrs": [{k: v for k, v in m.items() if k != "keys"} for m in linked],
        })

    # Open or not-yet-released MRs that name no ticket: candidates for unmatched tickets.
    orphans = [{"iid": m["iid"], "title": m["title"], "state": m["state"], "draft": m["draft"]}
               for m in mrs if not m["keys"] and m["branch"] != "changeset-release/master"
               and not m["released"]]
    json.dump({"release": release, "versionPackagesMr": version_mr, "tickets": out,
               "mrsWithoutKey": orphans}, sys.stdout, indent=1, default=list)


if __name__ == "__main__":
    main()
