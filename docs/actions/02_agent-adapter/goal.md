# Phase 2 — Stand up `agent-adapter`

**Goal:** make `agent-adapter` the **only** way any component talks to underlying agents. This is the invariant foundation — everything else switches to it before being extracted, so "no direct agent interaction" holds from the start.

## What to build

1. **Move the engine adapter layer out of `ash`** into the `agent-adapter` crate:
   - `engine/adapter.rs` + `driver.rs` + `catalog.rs` + `discovery.rs` from `old_code/ash/ash/src/engine/`
2. **Stable adapter protocol/interface** (tech-design.md §open-questions):
   - submit prompt, stream response, session continuity, abort, structured results
3. **Support both target agent types** (tech-design.md §target-agent-types):
   - **CLI-based** agents (opencode, claude-code, aider) — process exit code suffices; enhanced typed-result signal via the bus if typed returns wanted
   - **GUI-based** agents (GitHub Copilot) — callback-based completion delivered as a bus message correlated by run id
   - Drivers hide the difference — callers always use the same uniform interface
4. **CLI binary** `agent-adapter <agent> <prompt>` per the command-call design, with the driver interface also importable as a crate for surfaces.
5. **Switch `ash` to call agents only through `agent-adapter`** — proves the invariant end-to-end.

## Source material

- `old_code/ash/ash/src/engine/` — `Adapter`/`LocalCliDriver` abstraction, agent catalog, discovery, drivers (opencode/claude-code/aider/echo)
- `axon` (Phase 1) for callback/correlation delivery

## Acceptance criteria

- `ash` runs its agent flows with zero direct agent invocation — all through `agent-adapter`.
- CLI-based driver works on exit code alone; a typed-result path works over the bus.
- One GUI-based driver's callback path demonstrated via bus + run id.

## Decisions to lock

- **Placement** (the hottest open question, plan.md §5): CLI command vs embedded crate vs `axon`-hosted service. Decide here before deep `elan` integration.
