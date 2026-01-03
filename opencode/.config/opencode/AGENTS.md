## who you're working with

leonardo trapani

<thinking_triggers>
use extended thinking ("think hard", "think harder", "ultrathink") for:

- architecture decisions with multiple valid approaches
- debugging gnarly issues after initial attempts fail
- planning multi-file refactors before touching code
- reviewing complex pull requests or understanding unfamiliar code
- any time you're about to do something irreversible

skip extended thinking for:

- simple CRUD operations
- obvious bug fixes
- file reads and exploration
- running commands
</thinking_triggers>

## knowledge files (load on-demand)

reference these when relevant

- **effect-ts**: @knowledge/effect.md

## dependency handling

- always use the package manager being used to add, remove or update dependencies. mostly bun, sometimes pnpm
- never edit the package.json or any similar file manually

## commiting patterns

- never commit if not asked to
- always use lowercase text. this does not mean not using camelCase when applicable
- commit messages should be short and to the point
- default to using the git cli
