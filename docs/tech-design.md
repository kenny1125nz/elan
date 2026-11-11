# Technical Design — Platform Foundations

Companion to [`vision.md`](./vision.md) and [`concept.md`](./concept.md). This document records the foundational technical decisions that shape how the components are built and how they interact.

## 1. Rust as the primary implementation language

All platform components — `ash`, `dust`, `elan`, `axon`, and `agent-adapter` — are implemented in **Rust**.

### Rationale

- **Single-language platform.** One toolchain, one dependency ecosystem, one build story across all components.
- **Core-as-library fits Rust.** The core-as-library principle (vision.md) maps naturally onto Rust crates: each component ships a crate exposing a public API, with thin surface binaries on top.
- **Performance.** The components are IO-heavy but also embed scripting engines, tree walkers, and (later) the agentic FSM. Rust gives predictable performance without a runtime.
- **Single static binaries.** Easy distribution and deployment of CLIs and the `axon` daemon.
- **Interop where needed.** `dust`'s current TypeScript/VS Code work can be reached via a small FFI/bridge layer in the `elan-vscode` surface, while the cores stay in Rust.
- **Existing momentum.** `ash` is already a Rust codebase; this decision preserves and extends it.

### Consequence

Every component's core is a crate. Surface shells (CLI binaries, and later the `elan-vscode` all-in-one extension shell) depend on the crates but contain no core logic.

> **Scope of the core/CLI split.** Splitting core logic from the CLI surface exists *purely* to isolate user interfaces from application logic — so that a GUI surface (e.g. `elan-vscode`) can be built on top of the same core as the CLI. It is **not** a mechanism for inter-component composition. Components do **not** depend on each other's crates.

## 2. Inter-component invocation via command calls

Components invoke each other **only** by **command calls** — spawning the target component's CLI binary from the system `PATH`. Components are independent at build time: they share no library dependencies on one another, and expect other components to exist **at runtime** as commands on the system path.

### The rule

| Interaction | Mechanism |
|-------------|-----------|
| Inter-component invocation (any: `elan` → `ash`/`dust`, `dust-vscode` → cores, etc.) | **Command call** to the component's CLI binary |
| Same component, UI vs core | Library call into the component's own crate |

The CLI is the **only** inter-component contract. A component never links another component's crate.

> **Exception: infrastructure client crates.** `axon` and `agent-adapter` publish client libraries (e.g. `axon-client`, the adapter driver interface) that other components *do* import as crates. These are shared infrastructure/protocol clients, not component-to-component coupling — they do not embed another component's orchestration logic or behavior, so the drift concern does not apply. The rule targets embedding one *orchestration component* into another.

### Why not library embedding between components

- **Behavioral consistency.** With a single, canonical CLI per component, there is exactly one behavior to observe: running `ash script.ash` from the shell and running it via `dust`/`elan` hit the same binary on the `PATH`. If components embedded each other's crates, a rebuilt `ash` binary and an older `dust` binary built against a previous `ash` crate could silently disagree on the same script — version drift inside the system.
- **Independent evolution.** No build-time coupling means no forced co-releases; each component version-matches itself against the others only through its CLI contract.
- **Runtime-only dependence.** Components are decoupled processes that find each other on `PATH` at runtime — the elan system runs against whatever versions are installed, with a single source of truth per component.

### Design

- Each component exposes a **stable CLI** as its command interface: `ash <script>`, `dust <dir>`, `elan <goal>`, `axon`. The `axon` binary has a single mode — the daemon — so it takes no subcommand (config via flags/file).
- Command calls are the **inter-component boundary**: they are decoupled (each component is its own process, own lifecycle), debuggable (standard stdout/stderr/exit codes), and testable (each binary is independently runnable).
- A component's CLI is a thin surface over its own core crate — the same code path its GUI surface uses.
- **The CLI is primarily a human interface.** Its output is human-oriented (readable stdout/stderr, exit codes); its main user is the human at the terminal. Machine-readable output on stdout is *not* the inter-component contract — see below.
- **`--version` / `--help` are standardized** so runtime discovery and version matching between components work.
- **The command contract is versioned.** A newer caller and older callee (or vice versa) interoperate predictably, and behavior differences are attributable to version, not to embedded-code drift.

### Component call contracts

Command calls trigger and control work; **structured data flows over the bus**, not over stdout.

| Contract | Carrier | Purpose |
|----------|---------|---------|
| **Invocation / control** | CLI command call (args, exit code) | Start, direct, and signal completion of work |
| **Correlation** | A request/run id returned by the command (or pre-assigned) | Tie a bus exchange to a specific invocation |
| **Structured results / payloads** | `axon` bus (topic + correlation id) | Any machine-consumed data between components |

- The CLI tells the caller *whether* work started/finished (exit code) and *how to find* its results (run id) — nothing more machine-specific.
- All structured payloads — task results, goal transitions, agent outputs, errors — are exchanged as typed messages on the bus, correlated to the originating invocation.
- Human-facing rendering happens where it belongs: the CLI renders human output; a GUI renders bus events. Neither parses the other's stdout.

### Target agent types (driver signalling)

`agent-adapter` drives two kinds of target agents, which differ in how completion is signalled:

| Agent type | Examples | Completion signalling |
|------------|----------|----------------------|
| **CLI-based** | opencode, claude-code, aider | Basic process exit code is usually enough. If we want a *typed return* from an agent call (not just "did it finish"), an **enhanced completion signal** is still needed beyond the raw exit code — e.g. a structured result carried on the bus. |
| **GUI-based** | GitHub Copilot | No reliable process-level completion (no blocking CLI contract to exit on) — requires a **callback-based completion signalling** mechanism. |

- **Callback messages ride the `axon` bus.** For GUI-based agents (and any callback-style driver), completion is delivered as a bus message correlated to the original invocation via run id — the same correlation mechanism used for structured results (topic + run id).
- **Drivers hide the difference.** The two signalling styles are a property of each *driver*, not of callers: `ash`/`dust`/`elan` invoke agents through the adapter interface uniformly, whether the underlying agent is CLI- or GUI-based.

### Example

```
elan "implement oauth"                 # elan CLI drives a goal
  └─ elan core ──command──> ash script.ash   (run-id: r-123)
  └─ elan core ──command──> dust tasks/      (run-id: r-124)
  └─ elan core ──subscribes──> axon/task/result{r-123}
  └─ elan core ──subscribes──> axon/goal/transition{r-124}
```

*(The `axon/...` topic names here are illustrative only at this stage — exact naming is refined during the axon implementation phase.)*

## 3. Event / telemetry / progress over the axon bus

Alongside command calls, components publish to and consume from **`axon`**, the socket-based message bus. `axon` is the **structured-data channel** of the platform: it carries the async dimension (events, telemetry, progress) and the machine-readable payloads exchanged between components.

### What flows over the bus

- **Events** — orchestration lifecycle events: task started/finished/failed, actor steps, goal FSM transitions (`defined`/`ready`/`end`), decomposition events.
- **Telemetry** — metrics and diagnostics emitted by every component (replace the current per-component `telemetry.jsonl` and `ashd` pipe channel).
- **Progress** — incremental progress of long-running work (a `dust` tree walk, an `elan` goal pursuit, agent streaming), so surfaces like `elan-vscode` can render live status without polling the CLI.
- **Structured results / payloads** — typed, machine-consumed data correlated to command invocations (task results, agent outputs, errors), replacing stdout-JSON as the inter-component data contract.

### Design

- `axon` is a **socket server** (local binding first; see vision.md MVP scope — no auth/security yet). The `axon` binary has a single mode — the daemon — so it takes no subcommand; configuration is via flags/file.
- **Publish/subscribe is provided by the `axon` client library.** The client is a crate (`axon-client`) that other components import; it speaks the bus protocol (connect, publish, subscribe, correlation) and is how components act as clients.
- Components are **clients**: they publish on topics and subscribe to topics via the client crate, decoupled from each other (publish/subscribe).
- **Request/response correlation.** An invocation carries a run id (from the command call); result messages on the bus carry the same id so the caller can correlate responses without connection state.
- Topic naming follows component and domain, e.g. `dust/task/started`, `elan/goal/transition`, `telemetry/ash`, `progress/agent/stream`, `dust/task/result`. **These topic names are illustrative only at this stage — the exact naming scheme, envelope, and namespace will be refined during the axon implementation phase.**
- Command calls stay synchronous and direct (trigger/control); the bus is asynchronous, broadcast, and the single structured-data channel — the two dimensions from vision.md (direct invoke vs event/bus) remain cleanly separated.

### Telemetry: emit from day one, sink later

- **Emission is built-in from the start.** Every component emits telemetry at its anchor points as part of the initial build — one well-defined code path that publishes structured telemetry to the `telemetry/*` topics.
- **Consuming and sinking is deferred.** No component builds a telemetry consumer/store in the initial build. The sink is added later as a subscriber to the `axon` bus (a dedicated consumer), reading the `telemetry/*` topics — without touching the emitting components.
- **Why.** It makes telemetry availability a property of the platform (bus + subscriber) rather than of each component, and keeps initial builds small. Components only need the emit side; the collect side arrives as future work by adding one more bus subscription.

### Interaction summary

| Dimension | Mechanism | Used for |
|-----------|-----------|----------|
| Synchronous control | CLI command call (args, exit code, run id) | Trigger and direct work, ordered control flow |
| Structured data | `axon` bus (publish/subscribe + correlation) | Results, payloads, events, telemetry, progress, live UI state |

## Open questions / future work

- **`agent-adapter` placement.** It sits at the bottom of every invocation path (every `act`, every `do`) and is the hottest path. Three candidates: (a) a CLI command like any other component — consistent but adds a spawn per agent call; (b) an embedded crate everywhere — violates the no-cross-component-crates rule and re-introduces driver drift; (c) an `axon`-hosted service — one persistent connection, no spawn cost, but adds a daemon dependency. Agent calls dominate latency, so even (a) is fine; this is the one place worth a deliberate decision. Whatever the placement, the **driver signalling split (CLI exit-code vs GUI callback-on-bus)** above applies.
- Whether a request/response correlation over a pub/sub bus needs a dedicated reply semantic in `axon`, or plain topic + run id is sufficient (start simple: topic + run id). GUI-agent callbacks (above) are one consumer of this correlation.
- Whether command calls should return run ids synchronously or accept a pre-assigned run id from the caller.
- Whether the structured message schemas (per topic) should live in a shared schema crate — this is a *schema* dependency, not a code dependency, and must not become component-to-component crate coupling.
- **`axon` availability.** What happens when the `axon` process is not running? Components differ in how hard they depend on the bus — `ash`/`dust`/`elan`/`elan-vscode`/`agent-adapter` each rely on it to a different degree (telemetry-only vs. results-as-sole-channel vs. agent-service). Behavior on bus absence must be defined per component, one by one: fail hard, degrade (e.g. fall back to local/blocking behavior, buffer events), or continue with reduced observability.
- `axon` auth/security for non-local operation (deferred by vision).
