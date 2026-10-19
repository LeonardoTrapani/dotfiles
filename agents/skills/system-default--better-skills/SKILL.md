---
name: better-skills
description: >
  Index and route better-skills vault operations from the CLI.

  Trigger when users ask to manage better-skills or a skill vault

  (create, edit, delete, remove, search, import, clone, link, sync, backup,

  onboard, enable/disable vaults, inspect available vaults, move a skill across
  vaults).

  Do not use when asked to use a skill.
---
# better-skills

## Flows

| Trigger                                                                                                                          | Flow                                              |
| -------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| GitHub URL, skills.sh link, npm URL, blog post, any external source, or pasted external install command meant for a vault import | `references/import-skill.md`       |
| User wants to create/write a new skill from scratch                                                                              | `references/create-skill.md`       |
| User wants to update/edit an existing vault skill                                                                                | `references/edit-skill.md`         |
| Asked to onboard, Existing local skill folders not yet in the vault                                                              | `references/onboard-skills.md`     |
| User wants to delete/remove a skill                                                                                              | `references/delete-skill.md`       |
| "What skills do I have?", find related skills, linking requests                                                                  | `references/search-and-propose.md` |
| Anything not included above                                                                                                      | `references/commands.md`           |

## Shared references

- Authoring guidelines → `references/authoring.md`
- Mention linking → `references/linking.md`
- CLI command reference (load only when stuck with CLI syntax) → `references/commands.md`

## Rules

1. Every resource file must have a `[[resource:new:<path>]]` mention — either
   in SKILL.md or in another resource. Never run create/update until validate exits clean.
2. Never use bare markdown links for internal resource references.
3. Always read authoring guidelines before creating or editing a skill.
4. If the user wants something added to a better-skills vault and pastes a third-party install command (`npx skills add ...`, `skills add ...`, etc.), treat that command as source context only. Do not execute it; route to `references/import-skill.md` and use the better-skills import workflow.
5. Only run third-party install CLIs when the user explicitly asks for local agent installation instead of vault management.
