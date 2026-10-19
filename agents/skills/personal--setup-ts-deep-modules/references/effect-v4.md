# Effect v4 example branch

Read this reference only after active project code or its manifest confirms Effect v4.

## Source priority

1. Read the repository's `AGENTS.md` or `CLAUDE.md` Effect instructions.
2. If `vendor/effect-smol` exists, read its `LLMS.md`, relevant `ai-docs`, and relevant source/tests before writing code.
3. Otherwise inspect installed Effect v4 declarations and nearby project modules.
4. Adapt names, imports, errors, formatting, tests, and self-reexports to the repository's established conventions.

## Package shape

Keep the same package root chosen by the main workflow. Effect changes the contents of the example, not the boundary model:

```text
<packages-root>/example/
  Example.ts              # public Context.Service contract entry point
  Live.ts                 # public production Layer entry point
  lib/impl.ts             # private implementation
  tests/example.test.ts   # imports only root entry points
```

Do not introduce a separate `services/` or `modules/` root. Do not require a barrel `index.ts`.

## `Example.ts`

```ts
import { Context, Effect } from "effect"

export interface Interface {
  readonly greet: (name: string) => Effect.Effect<string>
}

export class Service extends Context.Service<Service, Interface>()(
  "@app/packages/example/Example"
) {}

export * as Example from "./Example.ts"
```

## `lib/impl.ts`

```ts
export const greeting = (name: string): string => `Hello, ${name}!`
```

## `Live.ts`

```ts
import { Effect, Layer } from "effect"
import { Example } from "./Example.ts"
import { greeting } from "./lib/impl.ts"

export const layer = Layer.succeed(
  Example.Service,
  Example.Service.of({
    greet: (name) => Effect.succeed(greeting(name))
  })
)

export * as ExampleLive from "./Live.ts"
```

Use `Layer.effect` when constructing the implementation is effectful and a scoped Layer constructor when acquisition requires release. Keep implementation-specific dependencies on the provider Layer, not on the service contract.

## `tests/example.test.ts`

Adapt this behavior to the installed test runner:

```ts
import { Effect, Layer } from "effect"
import { Example } from "../Example.ts"
import { ExampleLive } from "../Live.ts"

const greet = Effect.gen(function*() {
  const example = yield* Example.Service
  return yield* example.greet("Ada")
})

const TestLayer = Layer.succeed(
  Example.Service,
  Example.Service.of({
    greet: (name) => Effect.succeed(`Test: ${name}`)
  })
)

// Assert that greet provided with ExampleLive.layer returns "Hello, Ada!".
// Assert that greet provided with TestLayer returns "Test: Ada".
```

Use the repository's Effect-aware test helpers when present; otherwise run the provided Effects with its normal runtime boundary. The completed test must compile and execute rather than leaving the assertions as comments.

## What is enforced

- Dependency-cruiser mechanically prevents consumers and tests from importing `lib/impl.ts`.
- The compiled, passing example proves the public capability is a `Context.Service`, the production implementation is a `Layer`, and tests can replace it.
- Ordinary feature code should depend on `Example.Service`; composition roots and tests select Layers.

Do not claim that Effect itself prevents deep imports. Enforcing provider-only imports outside composition roots would require stable repository-specific paths or an additional custom lint rule; it is not part of this generic setup.
