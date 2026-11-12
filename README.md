# Elan

Design material for reorganising the agent-orchestration stack into small, independently evolving components with clean boundaries.

Elan composes existing primitives — `ash` for scripting, `dust` for directory orchestration — behind an agent adapter, so that each concern can be developed, tested, released, and adopted on its own.

## Intended components

- **ash** — scripting language and runtime
- **dust** — directory/actor orchestration
- **agent-adapter** — abstraction over agent drivers (opencode, Claude Code, aider, echo, ...)
- **axon** — telemetry and socket bus
- **elan-vscode** — editor surface

## Documentation

- `docs/vision.md` — goals, current-state problems, target boundaries
- `docs/concept.md` — agentic concept and goal FSM
- `docs/plan.md` — build-out plan and reuse inventory
- `docs/tech-design.md` — technical design

## Status

Planning / design. Code is being reorganised from the archived components referenced in `docs/plan.md`.
