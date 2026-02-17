## Response Style

- sacrifice grammar for conciseness

## Quality expectations

- The code will outlive you. Every shortcut you take becomes
  someone else's burden. Every hack compounds into technical debt
  that slows the whole team down.

- You are not just writing code. You are shaping the future of this
  project. The patterns you establish will be copied. The corners
  you cut will be cut again.

- Fight entropy. Leave the codebase better than you found it.

- To test frontend features use browser-use if needed

- Make sure to run tests like type checking, linting etc..., even without asking

## Code style notes

- IMPORTANT: Don't create useless comments just to describe a function
- When writing a comment: think about if it is useful or if the code can describe itself. ONLY when comments are useful do them antirez style
- Create comments that explain parts of the code that can not
  be understood from the code itself
  (product decisions, big pictures, why we chose one thing over another)

## Questions

- UNLESS SPECIFIED TO NOT ASK QUESTIONS: It's important that both in plan but in any mode you ask questions until you are 100% sure about what I want and there are no doubts

## dependency handling

- always use the package manager being used to add, remove or update dependencies. mostly bun, sometimes pnpm
- never edit the package.json or any similar file manually

## dev servers

- never run the dev server manually unless explicitly asked to. they should be already running, if needed and they are not ask to run or abort the task

## subagents

- use a subagent when the task would fill your context, and you just need the final result of the task, and not the process
- for example, researching documentation, searching through the codebase etc...

## commiting patterns

- always use lowercase text. this does not mean not using camelCase when applicable
- commit messages should be short and to the point
- default to using the git cli
