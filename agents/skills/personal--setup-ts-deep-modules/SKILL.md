---
name: setup-ts-deep-modules
description: >-
  Wires dependency-cruiser into a TypeScript repo so each package is a deep
  module—implementation hidden in subfolders and reachable only through root
  entry-point files. Detects Effect v4 and then scaffolds the same boundary with
  Context.Service contracts and Layer implementations. Use only when the user
  explicitly asks to set up deep modules or enforce TypeScript package
  boundaries. Do not use for ordinary feature work or non-TypeScript projects.
disable-model-invocation: true
---
# Setup TS Deep Modules

Make every package in this repo a **deep module**: a lot of behaviour behind a small interface. A package's public surface is its **entry points**—the files at the package root—and everything in its subfolders is hidden. This skill installs dependency-cruiser and the rules that make the entry points the only way in, then proves the rules bite.

For the vocabulary (deep module, interface, seam, depth), call the Skill tool with `codebase-design` and use its language throughout.

## The shape this enforces

```text
src/packages/
  <name>/
    index.ts        ← an entry point (public). Import this from outside.
    client.ts       ← another entry point. Packages may expose SEVERAL.
    lib/            ← implementation: hidden from outside, free to import each other.
    tests/          ← co-located tests + fixtures (a subfolder, so private).
```

The public surface is the package's **root files**—not one designated `index.ts`. By convention implementation lives in `lib/` and tests in `tests/`, giving every package the same two-folder shape. The rule itself is general: anything in any subfolder is private, so the config never needs extending for another internal folder.

Four concerns are enforced at `error` severity:

1. **Entry-point boundary**—code outside a package may import only that package's root entry points, never its subfolders.
2. **Intra-package freedom**—a package's own implementation files may import each other freely.
3. **Tests through entry points**—tests may import package entry points and their own fixtures, never package internals.
4. **No cycles**—dependency cycles are forbidden.

**Entry points, not a barrel.** A package may expose several small entry points (`index.ts`, `client.ts`, `server.ts`) instead of funnelling everything through one giant `index.ts`. Discourage barrels that re-export a whole subtree.

Layering—which packages may depend on which—is a different concern and remains a commented, repository-specific stub in the config.

## Steps

### 1. Detect the environment

1. Detect the package manager: `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lockb` or `bun.lock` → bun, otherwise npm. Prefer explicit repository instructions.
2. Choose the packages root: if `src/` exists, use `src/packages`; otherwise use `packages`. Confirm when the repository already has a different obvious convention. Do not reinterpret an existing monorepo's workspace directory without confirmation.
3. Check for `.dependency-cruiser.*`. Merge into an existing config; never overwrite it.
4. Detect Effect v4 from the active package manifest or active source imports such as `Context.Service`. Ignore `vendor/`, archives, generated output, and `node_modules/`.
5. When Effect v4 is detected, read `references/effect-v4.md` and use its example branch automatically. Do not ask whether Effect is in use.

**Done when:** package manager, packages root, existing-config status, and Effect v4 status are known.

### 2. Install dependency-cruiser

Install `dependency-cruiser` as a development dependency with the detected package manager.

**Done when:** `dependency-cruiser` is in `devDependencies`.

### 3. Write the config

Copy `dependency-cruiser.config.cjs` to the repository root as `.dependency-cruiser.cjs`. Set `PACKAGES_ROOT` to the root detected in step 1. The rules are path-depth based and extension-agnostic, so nothing else needs adapting.

**Done when:** `.dependency-cruiser.cjs` contains the correct `PACKAGES_ROOT` and all forbidden rules.

### 4. Wire it into the checks

1. Add `lint:boundaries`: `depcruise <packages-root>` or the narrowest parent that includes it.
2. Fold it into the umbrella `check`, `ci`, or `validate` command that already runs typechecking.
3. Do not change `tsconfig` or add path aliases for this setup.
4. If no umbrella script exists, add `lint:boundaries` and tell the user to include it in CI.

**Done when:** `lint:boundaries` runs alongside typechecking.

### 5. Scaffold the example package

If Effect v4 was not detected, create:

```text
<packages-root>/example/
  index.ts
  lib/impl.ts
  tests/example.test.ts
```

Make `index.ts` delegate to `lib/impl.ts`; make the test import only `../index`.

If Effect v4 was detected, create the package from `references/effect-v4.md`. Its root entry points expose a `Context.Service` contract and a production `Layer`; `lib/` remains private; tests access the service through Effect and prove a replacement Layer can be supplied.

Follow the repository's existing formatting, Effect imports, tagged-error, test-runner, and self-reexport conventions. Tell the user the example is a copy-or-delete template.

**Done when:** the package exposes behaviour through root entry points, hides implementation in `lib/`, and—under Effect—demonstrates Layer substitution.

### 6. Prove the rules bite

1. Run `lint:boundaries`; it must pass on the clean example.
2. Temporarily add a deep import to `tests/example.test.ts`, such as `import { thing } from "../lib/impl"`.
3. Run `lint:boundaries`; it must fail with `tests-through-entrypoints`.
4. Remove the deep import and run the check again; it must pass.
5. Under Effect v4, also run the example tests and typecheck. Confirm the consumer gets the capability through `Example.Service`, the production implementation is a `Layer`, and the test can replace that Layer without importing `lib/`.

Do not finish when the deliberate violation passes or the Effect substitution example fails.

**Done when:** pass, expected boundary failure, final pass, and—under Effect—successful Layer substitution have all been observed.

### 7. Document the convention

Write `<packages-root>/README.md` next to the governed packages. Include the package shape, root-entry-point rule, private `lib/` and `tests/` folders, and `lint:boundaries` command. Explicitly discourage broad barrels.

Under Effect v4, also document that service contracts and provider Layers are root entry points, ordinary consumers access the service capability, composition roots choose production Layers, and tests may supply replacement Layers. Dependency-cruiser enforces file visibility; Effect models capability provision.

Add a one-line pointer from `CLAUDE.md`, otherwise `AGENTS.md`, creating `AGENTS.md` only when neither exists.

**Done when:** the packages README exists and the agent-instructions file points to it.

## Notes

- Preserve the config's `$1` back-references; they let a package reach its own internals while blocking outsiders.
- Public versus private is decided by depth: root files are entry points and every subfolder is private.
- Packages are flat: one tier of immediate children under the packages root. Internals may nest freely.
- Use `.cjs` so `module.exports` works in repositories with `"type": "module"`.
- Effect services do not make files private. Dependency-cruiser enforces the import boundary; `Context.Service` and `Layer` define what passes through it and how it is supplied.

Agent metadata: `agents/openai.yaml`
