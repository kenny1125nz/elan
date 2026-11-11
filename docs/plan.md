# High-Level Plan — Elan Platform Build-Out

Companion to [`vision.md`](./vision.md), [`concept.md`](./concept.md), and [`tech-design.md`](./tech-design.md).

## 1. Reuse inventory (what we already have)

Everything lives under `old_code/`. The strategy is **reuse-first**: extract and reshape the existing `ash` codebase rather than rewrite from scratch. The **target workspace root is `.`** (this repo) — the components land here, reusing code extracted from `old_code/`.

| Existing asset | Location | What it gives us | Target component |
|----------------|----------|------------------|------------------|
| Ash script language (`lang/`, `eval/`) | `ash/ash/src/lang`, `eval` | Parser, AST, evaluator, control flow, `do`/`session`/`evaluate`, REPL | **ash** core |
| Runtime (`runtime/`) | `ash/ash/src/runtime` | Scope, pipeline, executor, actor, tree walker (`tree.rs`), discovery | split — engine/runtime → **ash**, tree walker → **dust** |
| Agent engine (`engine/`) | `ash/ash/src/engine` | `Adapter`/`LocalCliDriver` abstraction, agent catalog, discovery, drivers (opencode/claude-code/aider/echo) | **agent-adapter** (the JDBC layer's seed) |
| Telemetry (`telemetry/`) | `ash/ash/src/telemetry` | Event model, pipeline, store, WsClient, filters | **axon** (telemetry topics) |
| Daemon (`ashd/`) | `ash/ashd` | Folder sources, workflow spawning, WS server, relay/router, sinks (kafka/splunk) | **axon** (socket bus seed) + dust folder sources |
| WASM build | `ash/ash-wasm` | Browser-usable engine | **ash** (surface, optional) |
| VS Code extension | `ash/ash-vscode` | Language server / syntax highlighting for `.ash` | **elan-vscode** (ash part) |
| Dust actor engine (`engine/`, `actors/`) | `dust/packages/extension/src` | Actor model, step files, apply/compose | **dust** core (actor orchestration) |
| Dust shared (`packages/shared`) | `dust/packages` | Endpoint/types shared between callback + extension | **dust** / **elan-vscode** |
| Dust webview + adapters | `dust/packages/extension` | GUI, chat gateways (cline), completion, surface | **elan-vscode** |
| Steering PoC | `steering-poc` | Concept for recursive goal decomposition + legitimacy feedback | **elan** (concept seed) |

> **Key reuse decision:** `ash` is the primary asset. Its language + eval + runtime engine become the `ash` core; its `engine` (adapter/driver abstraction) becomes the seed of `agent-adapter`; its `ashd` + `telemetry` become the seed of `axon`; its `ash-vscode` and `dust`'s extension become `elan-vscode`.

## 2. Target component map

```
ash            .ash scripting language          (lang + eval + runtime engine)
dust           directory/actor orchestration    (tree walker + actor engine)
elan           agentic behavior                 (goal FSM, filesystem-backed goals)
axon           socket message bus               (daemon + axon-client crate)
agent-adapter  JDBC-like driver layer           (Adapter/LocalCliDriver)
elan-vscode    all-in-one VS Code surface       (ash-vscode + dust extension GUI)
```

## 3. Phased plan

### Phase 0 — Workspace + contract foundations
- Set up the workspace at `.` (current root) as the target Rust workspace with crates: `ash-core`, `dust-core`, `elan-core`, `axon`, `axon-client`, `agent-adapter`.
- Define the **command-line contract** (tech-design.md §2): CLI is human-first, `--version`/`--help` standardized, run-id handoff.
- Do **not** build consumers/sinks yet — emit-side only for telemetry (tech-design.md §3).

### Phase 1 — Stand up `axon` (protocol + namespace first)
- **Finalize the axon protocol and topic namespace before anything emits.** Topic naming (`dust/task/started`, `elan/goal/transition`, `telemetry/*`, `progress/*`, `*/result` — **illustrative examples only, exact scheme refined in this phase**), the message envelope, and run-id correlation are the contract every component's telemetry/event emission is built against — they must be settled here so telemetry is done properly from the initial build of every component.
- Port `ashd`'s socket/WS server into the `axon` daemon (single mode, no subcommands) plus the `axon-client` crate (connect, publish, subscribe, correlation).
- Replace the pipe/WS channel + per-component telemetry plumbing with `axon` + `axon-client`.
- No consumers/sinks yet — existing `telemetry.jsonl` / `ashd` relay become an optional sink later.

### Phase 2 — Stand up `agent-adapter`
- Move `engine/adapter.rs` + `driver.rs` + `catalog.rs` + `discovery.rs` out of ash into the `agent-adapter` crate — the first realization of the JDBC layer.
- Define the stable **adapter protocol/interface**: submit prompt, stream response, session continuity, abort, structured results (tech-design.md §open-questions).
- Support **two target agent types** (tech-design.md §target-agent-types): **CLI-based** agents, where basic process exit code suffices (or an enhanced typed-result signal via the bus if typed returns are wanted); and **GUI-based** agents (e.g. GitHub Copilot), which need **callback-based completion signalling delivered as a bus message** correlated by run id.
- Make `agent-adapter` a real CLI command (`agent-adapter <agent> <prompt>`) per the command-call design, with the driver interface available as an imported crate for surfaces.
- `ash` switches to calling agents **only** through `agent-adapter` — this proves the invariant before any other component depends on it.
- *Reuse:* the tree walker stays in `ash-core` for now (see Phase 3) so ash keeps working end-to-end during the split.

### Phase 3 — Extract `ash` core
- Extract `lang` + `eval` + runtime engine (scope/pipeline/executor) into `ash-core`. CLI (`main.rs`, `repl.rs`) becomes a thin binary over it.
- Wire the `ash-core` telemetry anchor points to `axon` from day one (protocol already finalized in Phase 1).

### Phase 4 — Extract `dust` core
- Move the tree walker (`runtime/tree.rs`) and dust's actor engine (`dust/packages/extension/src/engine`, `actors/`) into `dust-core`.
- `dust` gains `.ash` actor steps (executed via `ash-core`), per concept.md.
- `ash` scripts invoke `dust-core` directory orchestration natively (vision.md).
- CLI surface: `dust <dir>` binary; run-id output. Telemetry/progress anchored to `axon`.

### Phase 5 — Introduce `elan` core
- Implement goal FSM (defined/ready/end), `act`/`deliberate`/`calibrate`/`abandon`, filesystem-backed goal folders, rolling decomposition (per concept.md).
- `elan-core` drives `ash-core`/`dust-core` by command call; agents only via `agent-adapter`.
- First vertical slice: `elan <goal>` CLI pursues a goal end-to-end through `ash`/`dust`, emitting goal transitions to `axon`.

### Phase 6 — Build `elan-vscode`
- Combine `ash-vscode` (`.ash` highlighting/execution) + `dust` extension GUI (webview, chat gateways, completion) into one all-in-one extension.
- Add `elan` GUI (goal tree, steering, FSM status).
- Renders live status from bus progress topics; invokes cores via CLI command calls.

### Phase 7 — Observability + hardening
- Add the telemetry **consumer/sink** as a bus subscriber (deferred from Phase 1).
- Resolve open questions: `agent-adapter` placement refinement (CLI vs embedded vs bus-service), `axon` availability behavior per component, bus auth/security for non-local use.

## 4. Key sequencing rationale

- **`axon` right after foundations** because telemetry must be built into every component from the initial build, and that requires a finalized protocol and topic namespace first — nothing can emit correctly until this is settled.
- **`agent-adapter` next** because it's the invariant foundation everything calls agents through — every component switches to it before they're extracted, so the "no direct agent interaction" rule holds from the start.
- **Phases 3–4 (ash/dust extraction) follow** because they're pure extraction — the system keeps working throughout, and both emit to the already-fixed `axon` protocol.
- **`elan` after the cores** so it can compose `ash`/`dust` on stable command contracts and the settled bus.
- **`elan-vscode` last** because it's the surface that composes everything; it's the most UI-coupled and benefits from stable cores/bus first.

## 5. Risks / watch items

- **`agent-adapter` placement** is the hottest-path open question — decide early (Phase 2) before deep `elan` integration.
- **`axon` protocol churn** after Phase 1 would ripple through every component's telemetry/event emission — the namespace/envelope must be treated as frozen once components emit.
- **`axon` availability semantics** must be defined per component before `elan` depends on bus-delivered results.
- The **tree walker home** during Phase 3-4 (temporarily in `ash-core`) must not become permanent coupling.
- **`dust` is currently TypeScript** — its actor engine and GUI are not Rust. Porting order matters: the actor *model/semantics* port to `dust-core` (Rust); the GUI stays TS in `elan-vscode`.
