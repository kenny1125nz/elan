# Phase 4 — Extract `dust` core

**Goal:** turn `dust`'s directory orchestration into `dust-core` (Rust), separating it from the VS Code GUI, and connect the two cores.

## What to build

1. **Port into `dust-core`** (Rust):
   - The **tree walker** from `ash`'s runtime (`runtime/tree.rs`) — moves home here from `ash-core`
   - `dust`'s actor engine: `old_code/dust/packages/extension/src/engine`, `actors/` — port the **actor model/semantics** (the GUI stays TS, concept.md note)
   - `old_code/dust/packages/shared` — endpoint/types shared between callback + extension
2. **`.ash` actor steps** — `dust` executes `.ash` steps via `ash-core` (per concept.md; `dust` → `ash` command call).
3. **Native directory orchestration in `ash`** — `ash` scripts invoke `dust-core` directory orchestration (vision.md; `ash` → `dust` command call).
4. **CLI binary** `dust <dir>`; run-id output; telemetry/progress anchored to `axon`.

## Source material

- `old_code/ash/ash/src/runtime/tree.rs` — tree walker
- `old_code/dust/packages/extension/src/engine`, `actors/` — actor engine (TS → Rust port)
- `old_code/dust/packages/shared` — shared endpoint/types

## Acceptance criteria

- `dust <dir>` walks a directory tree with actors end-to-end in Rust.
- A `.ash` actor step executes through the `ash` CLI (command call, no crate coupling).
- `ash` natively triggers directory orchestration via `dust` CLI.

## Watch items

- **TS → Rust porting order** (plan.md §5): actor *model/semantics* → `dust-core`; GUI stays TS for `elan-vscode`.
- Command-call boundary holds — no crate imports across `ash`/`dust`.
