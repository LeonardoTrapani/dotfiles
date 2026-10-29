---
name: game-bench
description: Design and build a benchmark where LLMs play a game against each other, in the family of monopoly-bench and pokerbench.
disable-model-invocation: true
---

A **game bench** is a public site where LLMs play one game against each other under its official rules: a pure rules engine, LLM seats on Pi and OpenRouter, Cloudflare Durable Objects deployed with Alchemy, a Foldkit web app with a leaderboard, live games and replays. Every new bench is a **sibling** of the ones before it: it copies their stack and runtime and redesigns only what its game needs.

The siblings, newest first, are the **references**:

- pokerbench: https://github.com/LeonardoTrapani/pokerbench (`SPEC.md`: sequential turns, hidden cards, per-hand memory, tournament and cash formats).
- monopoly-bench: https://github.com/LeonardoTrapani/monopoly-bench (`SPEC.md`, `apps/worker/README.md`, `packages/agent`; simultaneous rounds, trades, whole-game memory). Live at https://monopolybench.leotrapani.com.

The user names the game when invoking the skill. Work in that game's repository (`<game>bench`, deployed at `<game>bench.leotrapani.com`); if it does not exist yet, ask the user to create the project first.

## Steps

1. **Read the siblings.** Clone each reference read-only into its own scratch directory and read its `SPEC.md`, the worker README, the agent's system prompt and the wake-message snapshot. Then read the T3 threads of every sibling project, the user's messages first: in `~/.t3/userdata/statev2.sqlite` (read-only) they are the rows of `orchestration_v2_projection_messages` whose `json_extract(payload_json, '$.createdBy') = 'user'`. Collect the preferences stated there (UI, review, naming, cost), where the OpenRouter key for test games lives, how run costs were estimated and recalibrated, and how deploy credentials were set up. Done when you can state, for each sibling, its stack, its turn model, its memory policy and what the user praised or asked to change.

2. **Find the rules authority and an oracle.** The authority is the official rulebook of the game (a publisher's rulebook, a federation's rules); download it into its own empty directory and read it. The oracle is an independent implementation or a corpus of real games whose outcomes the engine must reproduce (pokerbench uses PokerKit and PHH hand histories). Done when you have the rulebook text with rule numbers and either an oracle or a stated reason there is none.

3. **Design.** Work the design tree below in the order given, deciding each branch from the rules and the siblings. Put to the user only the branches the siblings do not settle, each with your recommendation. Then show the design as an `html_render` page: the state machine of a game (highlight the states that wake a model), a keep / drop / new comparison against the closest sibling, the runtime, and one rendered wake message. Iterate until the user agrees.

4. **Write `SPEC.md`** with the section skeleton below. It is the single source of truth and the handoff: a new thread on another machine starts from its implementation-method section. Run the review loop of the `orchestrator` skill on it with at most two rounds unless the user asks for more, then open the PR with the `pr` skill.

5. **Implement by phases**, one branch and one PR per phase, each with the `orchestrator` skill: scaffold (toolchain copied from the closest sibling, or from scratch with the same choices: the implementer decides and says which in the PR) → engine → bots, sim and CLI with calibration → agent → worker → web → deploy. Update the spec's status table at the end of every phase.

## Design tree

- **Rules**: the authority, every rule the engine applies mapped to its rule number, and a short list of **declared variants** (only where an API or a paused clock forces a difference). Test every rule; check against the oracle where it can.
- **Turn model**: _sequential_ (one seat can act at a time; a single waiting state, as in pokerbench) or _simultaneous_ ("any time" actions; frames, rounds, drafts applied in fixed order and wake rules, as in monopoly-bench). Pick the simplest model the rules allow.
- **Information**: what each seat may see. Hidden state goes into events with per-seat visibility; spectators see everything.
- **Randomness and variance**: counter-based RNG from a seed, so every game replays exactly. Whether games are fully random or use seat rotation or duplicate dealing is the user's call; show the variance in the leaderboard either way.
- **Configuration**: one schema for the table (format, number of players within the official range, every rule option the rulebook offers), with defaults; only default-config games enter the main ratings.
- **Identity**: seats are named by their model's catalog name, and each model knows its own name.
- **Memory**: the smallest unit of play that carries its own context (a hand, a turn, a whole game). Every wake is a **delta**: nothing the conversation already holds is sent again. State what crosses units (notes written by the model, statistics computed by the engine) and bound each conversation by a share of the context window.
- **Thinking**: every player's reasoning streams live to spectators and is kept in replays.
- **Results and ratings**: what ranks a game (places, scores, chips), OpenSkill per format and table size, and the style statistics worth showing on a model's page.
- **Defaults and calibration**: limits per wake and defaults on timeout as in the siblings; game-length caps calibrated with bot games.

## SPEC skeleton

1. Goals and non-goals · 2. Stack and repository layout · 3. Rules (source, the game, conformance table, declared variants, configuration) · 4. Engine (decider, modules, state, commands, events, views) · 5. Turn flow · 6. Agents (identity and prompt, memory, tools, limits, defaults, seat kinds, catalog) · 7. Runtime (Durable Objects, API, storage) · 8. Runs and ratings · 9. Web app · 10. CLI · 11. Testing (own tests, oracle) · 12. Deploy · 13. Defaults · 14. Implementation method (working rules, starting on a new machine, phases, status, reference material).

Mark what is unchanged from a sibling as "as in <sibling>" and describe only the differences, so the sibling stays the single source of truth for shared parts.
