# Phase 0 — Workspace + contract foundations

**Goal:** stand up the target Rust workspace at `.` (repo root) with the full crate skeleton, so every later phase lands into place. No feature work yet — just structure and the contracts everything builds against.

## What to build

1. **Rust workspace** (`Cargo.toml`) with member crates:
   - `ash-core` — .ash language + eval + runtime engine
   - `dust-core` — directory/actor orchestration
   - `elan-core` — goal FSM + filesystem-backed goals
   - `axon` — socket message bus daemon
   - `axon-client` — bus client library crate
   - `agent-adapter` — JDBC-like driver layer
2. **Thin surface binaries** per component (`ash`, `dust`, `elan`, `axon`, `agent-adapter`) as placeholders — CLI is the inter-component contract, so the binary shapes must exist early (tech-design.md §2).
3. **Standardized CLI contract**:
   - `--version` / `--help` on every binary (runtime discovery + version matching)
   - component CLI shapes: `ash <script>`, `dust <dir>`, `elan <goal>`, `axon` (daemon, no subcommand), `agent-adapter <agent> <prompt>`
   - run-id handoff semantics agreed (returned vs pre-assigned) — tech-design.md §open-questions
4. **Do NOT build** consumers/sinks yet — telemetry emit-side only (tech-design.md §3).

## Source material

- `old_code/ash/ash/` — existing Rust codebase to be extracted in Phases 3–4
- Nothing is moved in this phase; only scaffolding.

## Acceptance criteria

- `cargo build` succeeds for the whole workspace.
- Every placeholder binary prints `--version` and `--help` consistently.
- No component links another component's crate (except `axon-client`/`agent-adapter` as infrastructure client crates).

## Decisions to lock

- Run-id: synchronous return vs pre-assigned by caller (tech-design.md §open-questions).
- Telemetry emit-point plumbing pattern that every component will reuse (Phase 1 makes it concrete).
