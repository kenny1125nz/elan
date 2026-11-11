# Phase 6 — Build `elan-vscode`

**Goal:** the all-in-one VS Code surface that composes everything — `.ash` editing/execution, `dust` directory GUI, and `elan` goal steering. The most UI-coupled component, built last on stable cores and bus.

## What to build

1. **Combine** `ash-vscode` (`.ash` highlighting + execution) and `dust`'s extension GUI (webview, chat gateways e.g. cline, completion) into one extension.
2. **Add `elan` GUI** — goal tree, steering, FSM status display.
3. **Render live status** from bus progress topics — subscribe to `axon`; no CLI stdout parsing (tech-design.md §2).
4. **Invoke cores via CLI command calls** — same binaries/paths as the CLI surfaces; GUI is a thin shell with no core logic.

## Source material

- `old_code/ash/ash-vscode/` — language server / syntax highlighting for `.ash`
- `old_code/dust/packages/extension` + `webview/` — GUI, chat gateways (cline), completion (TS — stays in the surface)
- `old_code/dust/packages/shared` — endpoint/types shared between callback + extension

## Acceptance criteria

- One extension provides ash editing + dust directory orchestration GUI + elan goal tree.
- Goal/FSM status and task progress update live from bus events.
- Every action shells out to a component CLI — no reimplementation of core logic in TS.

## Watch items

- TS↔Rust FFI/bridge layer only where needed (tech-design.md §1); cores stay Rust.
- Depends on stable cores (Phases 3–5) and settled bus availability semantics.
