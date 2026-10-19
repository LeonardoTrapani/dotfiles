---
name: update-matt-pocock-skills
description: >-
  Compare my vault copies of Matt Pocock's skills against
  github.com/mattpocock/skills and bring missed upstream updates into the vault,
  keeping my own edits.
disable-model-invocation: true
---
Find the upstream changes your vault copies of Matt Pocock's skills are missing, report them, then merge the ones the user approves into the better-skills vault. A **local edit** is a change the user made on purpose; it survives every merge.

## 1. Gather both sides

1. In a disposable folder in cwd, clone the upstream repo with full history: `git clone https://github.com/mattpocock/skills ./.tmp-mp-skills`. The history is how you tell an upstream update apart from a local edit.
2. Run `better-skills list --all` and keep the vault skills whose slug matches an upstream folder `skills/*/<slug>/`. Note each one's `updated` date and uuid.
3. Clone each match: `better-skills clone <slug> --to ./.tmp-mp-vault/<slug>`.

Done when every overlapping skill has a clone.

## 2. Diff

Run `scripts/compare.py`:

```bash
python3 scripts/compare.py ./.tmp-mp-skills ./.tmp-mp-vault --show <every slug that differs>
```

It normalizes away vault noise (mention tokens, folded frontmatter, metadata lines), so every remaining hunk is a real content difference. Lines marked `-` are upstream, `+` are vault.

## 3. Classify every hunk

Give each hunk one label:

- **Upstream update**: upstream changed the line after the vault copy was taken. Check with `git log -S'<upstream text>' --format='%h %ad %s' --date=short` and with `git log --since=<vault updated date> -- ':(glob)skills/**/<slug>/**'`. Look at the merge date, not the author date: a commit written in August can land on main in September. `CHANGELOG.md` explains the intent of each release.
- **Local edit**: the vault text never existed upstream (`git log -S` on the vault text finds nothing), or upstream had the line well before the vault copy and the vault drops or rewrites it.
- **Leftover noise**: a formatting difference the script missed.

Also list upstream skills that aren't in the vault at all. Flag any that an upstream update calls (for example, `implement-spec` calls `tdd`), because merging that update without the skill leaves a dangling reference.

Done when every hunk has a label backed by git evidence.

## 4. Report and stop

Report the upstream version (latest `CHANGELOG.md` heading) and these sections:

1. **Missing updates**: each skill, what changed upstream, and the release it shipped in.
2. **Up to date**.
3. **Local edits**: kept as they are.
4. **Upstream skills not in the vault**: dependencies of the missing updates first.

Ask which updates to apply. Make no vault changes before the user answers.

## 5. Apply the approved updates

For each approved skill, follow the better-skills edit flow on its `./.tmp-mp-vault/<slug>` clone:

1. Bring in the upstream text and re-apply every local edit on top of it.
2. Write references to other vault skills as `[[skill:<uuid>]]` mentions, matching the rest of the vault copy (upstream uses `/name`, `` `name` ``, or `"name"`).
3. When upstream renames a resource file, rename it locally, point its mention at `[[resource:new:<new path>]]`, and remove the old path from `.resource-ids.json`.
4. Copy upstream `agents/openai.yaml` changes too.
5. Run `better-skills validate`, then `better-skills update <slug> --from <dir>`.

Import any approved missing dependency with the better-skills import flow before updating the skills that reference it, so its uuid exists.

## 6. Verify and clean up

1. Clone the updated skills again and re-run `scripts/compare.py`. Each one must show `identical` or only the local edits from the report.
2. Run `better-skills sync`.
3. Delete `./.tmp-mp-skills` and `./.tmp-mp-vault`.
4. Tell the user what changed and which local edits were kept, and remind them to start a new session so the updated skills load.
