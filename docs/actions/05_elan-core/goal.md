# Phase 5 — Introduce `elan` core

**Goal:** the agentic layer — a goal-pursuing agent that composes `ash`/`dust` through command calls and drives agents only via `agent-adapter`. First vertical slice through the whole stack.

## What to build

1. **Goal FSM** (`elan-core`, per concept.md §2):
   - States: `defined`, `ready`, `end` (outcomes `succeed`/`abandon`; no `failed`, no `executing`)
   - Actions: `deliberate`, `act`, `calibrate`, `abandon`
2. **Filesystem-backed goal state** (concept.md §6–7):
   - `goal.md` (mandatory) + `state` file per goal folder
   - Sub-folders are sub-goals; dot-prefixed folders excluded
3. **Rolling decomposition** (concept.md §8) — one layer at a time, `deliberate` on the active goal only, siblings wait.
4. **Progress reporting up / calibration down** (concept.md §4) — children report, parents steer (redefine/abandon), no self-challenging.
5. **Composition discipline:**
   - `elan-core` drives `ash-core`/`dust-core` **by command call**
   - agents **only** via `agent-adapter`
   - goal transitions emitted to `axon` (frozen protocol)
6. **Vertical slice** — `elan <goal>` CLI pursues a goal end-to-end through `ash`/`dust`.

## Source material

- `old_code/steering-poc/` — recursive goal decomposition concept seed (adapt: remove upward legitimacy feedback per concept.md §4)
- `ash-core` (Phase 3), `dust-core` (Phase 4), `agent-adapter` (Phase 2), `axon` (Phase 1)

## Acceptance criteria

- `elan <goal>` drives a goal folder through the FSM to `end` via `ash`/`dust`, emitting transitions on the bus.
- Human steering points (priority, calibration, search direction — concept.md §5) write to goal-folder state.
- No direct agent calls anywhere in the path.

## Decisions to lock

- Exact FSM state/action set (concept.md §2 notes "rough initial model — to be refined").
- Steering injection mechanism for the human layer.
