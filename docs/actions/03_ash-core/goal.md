# Phase 3 — Extract `ash` core

**Goal:** turn the `ash` monolith into `ash-core` (library) + a thin CLI binary — pure extraction; the system keeps working throughout.

## What to build

1. **Extract into `ash-core`** from `old_code/ash/ash/src/`:
   - `lang/` — parser, AST
   - `eval/` — evaluator, control flow, `do`/`session`/`evaluate`
   - `runtime/` — scope, pipeline, executor, actor engine
   - Keep the tree walker here **temporarily** (it moves to `dust-core` in Phase 4)
2. **Thin `ash` CLI binary** (`main.rs`, `repl.rs`) over `ash-core` — `ash <script>`, `--version`/`--help` per contract.
3. **Wire telemetry anchor points to `axon` from day one** — protocol already frozen in Phase 1.
4. Agents are invoked **only** via `agent-adapter` (Phase 2) — verify no direct calls remain.

## Source material

- `old_code/ash/ash/src/{lang,eval,runtime}` — the core
- `old_code/ash/ash/src/{main.rs,repl.rs}` — becomes the thin binary
- `old_code/ash/ash-wasm` — optional browser surface, defer unless needed

## Acceptance criteria

- `ash script.ash` behaves identically to the pre-split binary (behavioral consistency, tech-design.md §2).
- `ash-core` is a standalone crate; `ash` binary contains no core logic.
- Telemetry emits over `axon` topics, correlated by run id.

## Watch items

- Tree walker must not become permanent `ash-core` coupling — it's on loan from Phase 4.
