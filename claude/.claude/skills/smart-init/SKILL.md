---
name: smart-init
description: Create CLAUDE.md configuration files following progressive disclosure principles. Use when asked to create/update CLAUDE.md, setup agent configuration, establish agent guidelines, or configure Claude Code. Triggers on: create CLAUDE.md, setup claude config, agent configuration, progressive disclosure, init claude.
version: 1.0.0
user-invocable: true
---

Create CLAUDE.md, or multiple if needed, following the following guide.

Research the codebase for useful patterns with subagents first.

If some already exist, keep them, just clean them down and remove useless stuff, and add useful stuff instead

# A Complete Guide To CLAUDE.md

Have you ever felt concerned about the size of your `CLAUDE.md` file?

Maybe you should be. A bad `CLAUDE.md` file can confuse your agent, become a maintenance nightmare, and cost you tokens on every request.

So you'd better know how to fix it.

## What is CLAUDE.md?

A `CLAUDE.md` file is a markdown file you check into Git that customizes how Claude Code behaves in your repository. It sits at the top of the conversation history, right below the system prompt.

Think of it as a configuration layer between the agent's base instructions and your actual codebase. The file can contain two types of guidance:

- **Personal scope**: Your commit style preferences, coding patterns you prefer
- **Project scope**: What the project does, which package manager you use, your architecture decisions

The `CLAUDE.md` file is Claude Code specific, while `AGENTS.md` is an open standard supported by many tools.

<details>
  <summary>AGENTS.md</summary>

For compatibility with other tools that use `AGENTS.md`, you can symlink between them:

```bash
# Create a symlink from AGENTS.md to CLAUDE.md
ln -s CLAUDE.md AGENTS.md
```

</details>

## Why Massive `CLAUDE.md` Files are a Problem

There's a natural feedback loop that causes `CLAUDE.md` files to grow dangerously large:

1. The agent does something you don't like
2. You add a rule to prevent it
3. Repeat hundreds of times over months
4. File becomes a "ball of mud"

Different developers add conflicting opinions. Nobody does a full style pass. The result? An unmaintainable mess that actually hurts agent performance.

Another culprit: auto-generated `CLAUDE.md` files. Never use initialization scripts to auto-generate your `CLAUDE.md`. They flood the file with things that are "useful for most scenarios" but would be better progressively disclosed. Generated files prioritize comprehensiveness over restraint.

### The Instruction Budget

Kyle from Humanlayer's [article](https://www.humanlayer.dev/blog/writing-a-good-claude-md) mentions the concept of an "instruction budget":

> Frontier thinking LLMs can follow ~ 150-200 instructions with reasonable consistency. Smaller models can attend to fewer instructions than larger models, and non-thinking models can attend to fewer instructions than thinking models.

Every token in your `CLAUDE.md` file gets loaded on **every single request**, regardless of whether it's relevant. This creates a hard budget problem:

| Scenario                   | Impact                                                |
| -------------------------- | ----------------------------------------------------- |
| Small, focused `CLAUDE.md` | More tokens available for task-specific instructions  |
| Large, bloated `CLAUDE.md` | Fewer tokens for the actual work; agent gets confused |
| Irrelevant instructions    | Token waste + agent distraction = worse performance   |

Taken together, this means that **the ideal `CLAUDE.md` file should be as small as possible.**

### Stale Documentation Poisons Context

Another issue for large `CLAUDE.md` files is staleness.

Documentation goes out of date quickly. For human developers, stale docs are annoying, but the human usually has enough built-in memory to be skeptical about bad docs. For AI agents that read documentation on every request, stale information actively _poisons_ the context.

This is especially dangerous when you document file system structure. File paths change constantly. If your `CLAUDE.md` says "authentication logic lives in `src/auth/handlers.ts`" and that file gets renamed or moved, the agent will confidently look in the wrong place.

Instead of documenting structure, describe capabilities. Give hints about where things _might_ be and the overall shape of the project. Let the agent generate its own just-in-time documentation during planning.

Domain concepts (like "organization" vs "group" vs "workspace") are more stable than file paths, so they're safer to document. But even these can drift in fast-moving AI-assisted codebases. Keep a light touch.

## Cutting Down Large `CLAUDE.md` Files

Be ruthless about what goes here. Consider this the absolute minimum:

- **One-sentence project description** (acts like a role-based prompt)
- **Package manager** (if not npm; or use `corepack` for warnings)
- **Build/typecheck commands** (if non-standard)

That's honestly it. Everything else should go elsewhere.

### The One-Liner Project Description

This single sentence gives the agent context about _why_ they're working in this repository. It anchors every decision they make.

Example:

```markdown
This is a React component library for accessible data visualization.
```

That's the foundation. The agent now understands its scope.

### Package Manager Specification

If you're In a JavaScript project and using anything other than npm, tell the agent explicitly:

```markdown
This project uses pnpm workspaces.
```

Without this, the agent might default to `npm` and generate incorrect commands.

<details>
  <summary>Corepack is also great</summary>
You could also use [`corepack`](https://github.com/nodejs/corepack) to let the system handle warnings automatically, saving you precious instruction budget.
</details>

### Use Progressive Disclosure

Instead of cramming everything into `CLAUDE.md`, use **progressive disclosure**: give the agent only what it needs right now, and point it to other resources when needed.

Agents are fast at navigating documentation hierarchies. They understand context well enough to find what they need.

#### Move Language-Specific Rules to Separate Files

If your `CLAUDE.md` currently says:

```markdown
Always use const instead of let.
Never use var.
Use interface instead of type when possible.
Use strict null checks.
...
```

Move that to a separate file instead. In your root `CLAUDE.md`:

```markdown
For TypeScript conventions, see docs/TYPESCRIPT.md
```

Notice the light touch, no "always," no all-caps forcing. Just a conversational reference.

The benefits:

- TypeScript rules only load when the agent writes TypeScript
- Other tasks (CSS debugging, dependency management) don't waste tokens
- File stays focused and portable across model changes

#### Nest Progressive Disclosure

You can go even deeper. Your `docs/TYPESCRIPT.md` can reference `docs/TESTING.md`. Create a discoverable resource tree:

```
docs/
├── TYPESCRIPT.md
│   └── references TESTING.md
├── TESTING.md
│   └── references specific test runners
└── BUILD.md
    └── references esbuild configuration
```

You can even link to external resources, Prisma docs, Next.js docs, etc. The agent will navigate these hierarchies efficiently.

#### Use Agent Skills

Many tools support "agent skills" - commands or workflows the agent can invoke to learn how to do something specific. These are another form of progressive disclosure: the agent pulls in knowledge only when needed.

We'll cover agent skills in-depth in a separate article.

## `CLAUDE.md` in Monorepos

You're not limited to a single `CLAUDE.md` at the root. You can place `CLAUDE.md` files in subdirectories, and they **merge with the root level**.

This is powerful for monorepos:

### What Goes Where

| Level       | Content                                                                    |
| ----------- | -------------------------------------------------------------------------- |
| **Root**    | Monorepo purpose, how to navigate packages, shared tools (pnpm workspaces) |
| **Package** | Package purpose, specific tech stack, package-specific conventions         |

Root `CLAUDE.md`:

```markdown
This is a monorepo containing web services and CLI tools.
Use pnpm workspaces to manage dependencies.
See each package's CLAUDE.md for specific guidelines.
```

Package-level `CLAUDE.md` (in `packages/api/CLAUDE.md`):

```markdown
This package is a Node.js GraphQL API using Prisma.
Follow docs/API_CONVENTIONS.md for API design patterns.
```

**Don't overload any level.** The agent sees all merged `CLAUDE.md` files in its context. Keep each level focused on what's relevant at that scope.

## Fix A Broken `CLAUDE.md` With This Prompt

If you're starting to get nervous about the `CLAUDE.md` file in your repo, and you want to refactor it to use progressive disclosure, try copy-pasting this prompt into Claude Code:

```txt
I want you to refactor my CLAUDE.md file to follow progressive disclosure principles.

Follow these steps:

1. **Find contradictions**: Identify any instructions that conflict with each other. For each contradiction, ask me which version I want to keep.

2. **Identify the essentials**: Extract only what belongs in the root CLAUDE.md:
   - One-sentence project description
   - Package manager (if not npm)
   - Non-standard build/typecheck commands
   - Anything truly relevant to every single task

3. **Group the rest**: Organize remaining instructions into logical categories (e.g., TypeScript conventions, testing patterns, API design, Git workflow). For each group, create a separate markdown file.

4. **Create the file structure**: Output:
   - A minimal root CLAUDE.md with markdown links to the separate files
   - Each separate file with its relevant instructions
   - A suggested docs/ folder structure

5. **Flag for deletion**: Identify any instructions that are:
   - Redundant (the agent already knows this)
   - Too vague to be actionable
   - Overly obvious (like "write clean code")
```

## Don't Build A Ball Of Mud

When you're about to add something to your `CLAUDE.md`, ask yourself where it belongs:

| Location                  | When to use                                        |
| ------------------------- | -------------------------------------------------- |
| Root `CLAUDE.md`          | Relevant to every single task in the repo          |
| Separate file             | Relevant to one domain (TypeScript, testing, etc.) |
| Nested documentation tree | Can be organized hierarchically                    |

The ideal `CLAUDE.md` is small, focused, and points elsewhere. It gives the agent just enough context to start working, with breadcrumbs to more detailed guidance.

Everything else lives in progressive disclosure: separate files, nested `CLAUDE.md` files, or skills.

This keeps your instruction budget efficient, your agent focused, and your setup future-proof as tools and best practices evolve.
