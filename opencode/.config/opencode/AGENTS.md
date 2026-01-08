## who you're working with

leonardo trapani

## Response Style

- sacrifice grammar for conciseness

## Quality expectations

- This codebase will outlive you. Every shortcut you take becomes
  someone else's burden. Every hack compounds into technical debt
  that slows the whole team down.

- You are not just writing code. You are shaping the future of this
  project. The patterns you establish will be copied. The corners
  you cut will be cut again.

- Fight entropy. Leave the codebase better than you found it.

## Code style notes

- Don't create useless comments just to describe a function
- Create comments that explain parts of the code that can not
  be understood from the code itself
  (product decisions, big pictures, why we chose one thing over another)

## Questions

- It's important that both in plan but in any mode you ask questions until you are 100% sure about what I want and there are no doubts

## knowledge files (load on-demand)

reference these when relevant

- **effect-ts**: @knowledge/effect.md

## dependency handling

- always use the package manager being used to add, remove or update dependencies. mostly bun, sometimes pnpm
- never edit the package.json or any similar file manually

## subagents

- use a subagent when the task would fill your context, and you just need the final result of the task, and not the process
- for example, researching documentation, searching through the codebase etc...

## commiting patterns

- always use lowercase text. this does not mean not using camelCase when applicable
- commit messages should be short and to the point
- default to using the git cli
