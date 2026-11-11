# Phase 7 — Observability + hardening

**Goal:** close the loop on telemetry and resolve the open questions deferred by earlier phases. Platform hardening — no new core features.

## What to build

1. **Telemetry consumer/sink** — a bus subscriber (dedicated consumer) reading `telemetry/*` topics, replacing the old `telemetry.jsonl` / `ashd` relay. Deferred from Phase 1; requires **zero changes** to emitting components (tech-design.md §3).
2. **Resolve open questions** (tech-design.md §open-questions):
   - `agent-adapter` placement refinement (CLI vs embedded vs bus-service) — validate the Phase 2 decision in production shape
   - `axon` availability behavior per component: fail hard, degrade (fallback/buffer), or reduced observability — define one by one per component (plan.md §5)
   - bus auth/security for non-local use (deferred from vision; local-first MVP)
   - shared schema crate for per-topic message schemas
3. **Rollback handling** for redefined sub-goals (concept.md §4, deferred) if not already addressed.

## Source material

- `old_code/ash/telemetry.jsonl`, `old_code/ashd.yml` + ashd relay — legacy sink semantics to reproduce as a subscriber
- Bus spec from Phase 1 (frozen protocol)

## Acceptance criteria

- Sink consumes telemetry from the bus and persists/logs it without touching emitters.
- Every component has a documented, tested `axon`-absence behavior.
- Local-only deployment works without auth; non-local path is designed (not necessarily implemented).

## Watch items

- Protocol/namespace must NOT churn — treat Phase 1 spec as frozen (plan.md §5).
- No new component-crate coupling introduced while resolving placement.
