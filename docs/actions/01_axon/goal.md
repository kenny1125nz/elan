# Phase 1 — Stand up `axon` (protocol + namespace first)

**Goal:** establish the socket message bus and, critically, **freeze the protocol and topic namespace before any component emits**. This is the contract every component's telemetry/event emission is built against.

## What to build

1. **Protocol + namespace (do this first):**
   - Message envelope (wire format, metadata fields, correlation/run-id field)
   - Topic naming scheme + namespace (component/domain prefixes)
   - The exact scheme is defined and frozen in [tech-design.md](./tech-design.md) §5–§7 — no refinement after this phase (plan.md §5: churn after this ripples everywhere)
2. **`axon` daemon** — implement the socket bus per [`tech-design.md`](./tech-design.md): TCP over loopback, length-prefixed JSON frames, `CONNECT`/`PUBLISH`/`SUBSCRIBE`/`CLOSE`. Single mode, no subcommands; configuration via `AXON_`-prefixed env vars (tech-design.md §9); local binding only. `old_code/ash/ashd/` is a reference where applicable, not a template to port.
3. **`axon-client` crate** — connect, publish, subscribe, correlation, plus an optional dead-letter callback to process `UNDELIVERED` frames (tech-design.md §6.6). This is the shared infrastructure client every component imports.
4. **No consumers/sinks yet** — existing `telemetry.jsonl` / `ashd` relay become an optional sink in Phase 7.

## Source material

- `old_code/ash/ashd/` — folder sources, workflow spawning, WS server, relay/router, sinks (kafka/splunk) — the socket bus seed
- `old_code/ash/ash/src/telemetry/` — event model, pipeline, store, WsClient, filters — the telemetry topic seed
- Topic examples (frozen grammar in tech-design.md §7.1): `/goal/transition`, `/agent/started` — `telemetry` topic details are TBD with the first emitter.

## Acceptance criteria

- A client can connect, publish, subscribe, and correlate messages by run id.
- At least one elan component emits telemetry over `axon` (proving the adoption path).
- Protocol + namespace documented and frozen in this phase.

## Decisions to lock

- Reply semantics: **plain topic + correlation id** — no dedicated reply topic; a requester subscribes to the result topic filtered by its correlation id.
- Envelope/schema home: **shared `axon-schema` crate** — envelope types, topic constants, well-known attrs keys, validation.
- Handshake: `CONNECT_ACK`/`CONNECT_NACK` (connection-level, no routing); NACK closes + emits rejection telemetry; client waits under a timeout and reports the exact failure cause.

## Companion design doc

- [`tech-design.md`](./tech-design.md) — freezes the wire protocol: connection, publish/subscribe, envelope + multi-dimensional header (`attrs`), topic namespace, and the correlation model (`correlation_id` + `/`-prefixed namespaced `parent_correlation_id` chain to the root).
