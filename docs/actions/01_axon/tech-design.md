# Axon Bus — Technical Design (Phase 1)

Companion to [`goal.md`](./goal.md), [`tech-design.md`](../../tech-design.md), and [`plan.md`](../../plan.md).

## 1. Purpose & scope

`axon` is the socket message bus — the structured-data channel of the platform. This document freezes the **wire protocol**: connection, publish, subscribe, and the message envelope with its multi-dimensional header. Everything defined here is the contract every component's emission is built against (goal.md: freeze before anyone emits).

Frozen here, by layer:

| Layer | Frozen contract |
|---|---|
| 1 — Connectivity | Transport, framing, connection lifecycle, `client_id` convention |
| 2 — Wire protocol | Frame catalog, protocol versioning, frame-level error handling |
| 3 — Pub/Sub | Message envelope, subscription protocol, matching, routing/dispatch, delivery semantics |
| 4 — Message conventions | Topic namespace, message header (`source`, `attrs`), correlation model |

Out of scope (Phase 1): auth/TLS/remote binding, persistence/replay/durable store, consumer sinks (Phase 7), cross-machine distribution, client presence events (§4.3).

## 2. Design principles

- **One duty per layer.** Each layer solves exactly one problem and only interacts with the layers immediately above/below it (§3). A new concern is assigned to its layer — never appended as a new top-level section. The single exception is Configuration (§9), a cross-cutting section all layers reference.
- **Topic = coarse route; header = precise route.** The topic is a namespaced path selecting *what kind* of message; the header's multi-dimensional `attrs` map narrows to *which instance* (workspace, run, goal, task, agent). Subscriptions combine both.
- **Publish/subscribe, fully decoupled.** Producers publish, consumers subscribe; neither knows the other (tech-design.md §3).
- **One daemon, many workspaces.** A single local `axon` serves all workspaces; `workspace` is a header dimension, so a subscriber scopes to one workspace or all.
- **Traceability by construction.** Every invocation chain carries its ancestry in the header, so "all messages under this elan call" is one subscription, not a reconstruction.
- **Local, live, at-most-once.** Phase 1 delivery is in-memory fanout to connected clients: no persistence, no replay, no guaranteed delivery. Ordering is per-publisher FIFO.
- **No message-level ack/nack — a guiding principle.** The bus never acks or nacks delivered messages: a deliberate choice to avoid application-level ack flows and keep inter-component interactions simple. It is **not** a rule imposed on producers — each producer manages its own work however it likes, and may arrange its own certainty as it sees fit (§6.5). The exceptions are connection-level: the dead-letter frame (`UNDELIVERED`), sent when a published message finds no recipient, so a producer can learn its message didn't land instead of assuming it did (§6.6); and the one-time handshake ack/nack (`CONNECT_ACK`/`CONNECT_NACK`), a synchronous connection-establishment exchange that requires no routing (§4.3).

## 3. Layering model

The bus is structured as four stacked layers, mirroring the TCP/IP idea of isolating duties: each layer owns a single responsibility and exposes a narrow interface to the layer above it, hiding its internals.

```
+----------------------------------------------------------------+
| L4  Conventions      topic namespace · message header ·        |
|     (vocabulary)     correlation model                         |
+----------------------------------------------------------------+
| L3  Pub/Sub          envelope · subscription · matching ·      |
|     (routing)        routing/dispatch · delivery               |
+----------------------------------------------------------------+
| L2  Wire protocol    frame catalog · versioning · frame errors |
|     (syntax)                                                   |
+----------------------------------------------------------------+
| L1  Connectivity     transport · framing · connection          |
|     (bytes)          lifecycle · client identity               |
+----------------------------------------------------------------+
        TCP socket (127.0.0.1 only)
```

### Layer duties & boundaries

| Layer | Duty | Does **not** do |
|---|---|---|
| 4 — Conventions | Defines the vocabulary: topics, header fields, correlation chain. The contract components build emissions against. | Not concerned with bytes, frames, or how routing happens. |
| 3 — Pub/Sub | Defines the message model and how a message flows: envelope, subscriptions, matching, dispatch, delivery guarantees. | Not concerned with topic meaning or frame syntax. |
| 2 — Wire protocol | Defines frame syntax: the catalog of frames and their payloads, versioning, frame-level validation. | Not concerned with routing semantics or connection handling. |
| 1 — Connectivity | Provides the byte pipe: transport, framing, connection lifecycle, connection tracking. | Not concerned with frame content or message meaning. |

Interactions are strictly adjacent: a component speaks L4 vocabulary, which is carried by L3 routing, which rides L2 frames over an L1 connection. **Adding a concern means assigning it to a layer and renumbering — never opening a new area of the document. The one deliberate exception is Configuration (§9): a single cross-cutting section every layer references.**

## 4. Layer 1 — Connectivity

Owns the byte pipe: how bytes move and how connections live. It knows nothing about frames beyond their boundaries or about message meaning.

### 4.1 Transport

Transport: **plain TCP over local loopback only** (`127.0.0.1:<port>`, port via `AXON_PORT`, default `19191` — §9). Local binding only (vision.md MVP) — the host is locked, not a config choice.

### 4.2 Framing

Payloads are **length-prefixed JSON frames**: each frame is a JSON object prefixed by its byte length. Framing is a Layer 1 concern — it turns the byte stream into discrete frames and hands them up to Layer 2; it never interprets frame content.

### 4.3 Connection lifecycle

#### Handshake

Connection establishment is a synchronous exchange — the SYN/ACK analog at the bus layer. This is the **only** place the server acks or nacks a frame; it is connection-level control (§2) and carries no routing.

```
client → server: CONNECT { client_id, protocol_version, workspace }
server → client: CONNECT_ACK { client_id, protocol_version }    # accepted
server → client: CONNECT_NACK { reason }                        # rejected
```

- **`client_id` is mandatory** (§4.4). A duplicate `client_id` on a live connection is treated as a **re-connect**: the server closes the existing connection and accepts the new one (no NACK).
- `protocol_version` is enforced; an incompatible version is **rejected** — the server sends `CONNECT_NACK { reason: "protocol_version_incompatible" }`, closes the socket, and emits a `/telemetry/axon/connect-rejected` event (§5.3).
- `client_id` is stable for the lifetime of a process and persists across reconnects.

##### Client-side handshake handling

The client sends `CONNECT` and **waits for `CONNECT_ACK` before publishing/subscribing**. The wait is bounded by a **handshake timeout** (`AXON_HANDSHAKE_TIMEOUT_MS`, default `2000` ms — §9) — one of the few places the protocol uses a timeout.

- **`CONNECT_ACK` received** — handshake complete; the client may publish/subscribe.
- **`CONNECT_NACK { reason }` received** — handshake failed; the client closes the connection and prints the exact reason verbatim.
- **Timeout expires before any frame arrives** — handshake failed; the client closes the connection and prints an error stating the daemon did not respond within the handshake timeout.
- **Any other frame arrives before `CONNECT_ACK`/`CONNECT_NACK`** — protocol error; the client closes the connection and prints an error naming the unexpected frame type.

On any failure the client must surface exact diagnostic output that indicates the cause — the NACK reason verbatim, the elapsed timeout, or the unexpected frame type — never a generic "connection failed".

#### Graceful close

- A client sends `CLOSE` to disconnect cleanly (e.g. on process shutdown). The server removes the `client_id → connection` entry and closes the socket; no ack is sent.
- A connection that dies without `CLOSE` (expected or unexpected) is handled the same way — the entry is removed on read/write error.

#### Interruption & reconnect

The bus holds a map of `client_id → connection`; when a connection is interrupted (expected or not, detected via read/write errors on the TCP socket), its map entry is removed. On reconnect the client re-registers with a fresh `CONNECT`.

Client connect/disconnect is **not published** to the bus — there is no presence topic in Phase 1. Connection state is daemon-internal observability only; the sole connection-level telemetry is the daemon's own `/telemetry/axon/connect-rejected` event (§5.3).

### 4.4 Client identity — `client_id`

Every connection carries a **`client_id`**, self-intuitive so the daemon's connection tracking and routing are readable. `client_id` is a **connection** identity — it identifies *which* process is attached, and is used only for bus connection tracking and routing. It is **never part of a message**: producers and consumers stay decoupled through topics, and messages carry a producer-stamped **`source`** instead (§7.2).

#### Grammar

```
<component>.<surface>.<instance>
```

- **component** — the owning component: `ash` \| `dust` \| `elan` \| `adapter` \| `vscode` \| `axon` \| `sink` \| `cli`
- **surface** — the concrete thing the client is doing: `goal`, `task`, `walk`, `script`, `run`, `agent`, `worker`, `gui`, `relay`, `watch`, `daemon`
- **instance** — the **OS process id (PID)** of the client. Unique per process on the machine, stable for the process lifetime, and dead giveaway that the connection belongs to one concrete process.

#### Rules

- `client_id` is **stable for the lifetime of the process** (reconnects keep the same id, since the PID does not change).
- The instance is always the PID, no exceptions — the surface tells you *what* it does, the PID tells you *which process*.
- `client_id` must be present on every connection; a duplicate is treated as a re-connect (§4.3).

#### Examples

| client_id | Reads as |
|---|---|
| `elan.goal.4241` | elan (pid 4241) pursuing a goal |
| `dust.walk.5102` | dust (pid 5102) tree-walk |
| `ash.script.5127` | ash (pid 5127) running a script |
| `adapter.agent.5188` | adapter (pid 5188) driving an agent |
| `vscode.gui.2910` | the VS Code GUI surface (pid 2910) |
| `sink.telemetry.7113` | the future telemetry.jsonl sink (pid 7113) |

## 5. Layer 2 — Wire protocol

Owns frame syntax: the catalog of frames and their payloads. It knows *what* a frame is, not what happens when one is processed — that is Layer 3's job.

### 5.1 Frame catalog

`CONNECT`, `CONNECT_ACK`, `CONNECT_NACK`, and `CLOSE` are the boundary between Layer 1 and Layer 2: their syntax lives here, their connection semantics live in §4.3.

Client → server:

| Frame | Payload | Purpose | Defined by |
|---|---|---|---|
| `CONNECT` | client_id, protocol_version, workspace | handshake | §4.3 |
| `PUBLISH` | topic, header, data | publish a message | §6.1 |
| `SUBSCRIBE` | id, topic, filter | register a subscription | §6.2 |
| `CLOSE` | — | graceful close | §4.3 |

Server → client:

| Frame | Payload | Purpose | Defined by |
|---|---|---|---|
| `CONNECT_ACK` | client_id, protocol_version | handshake accepted | §4.3 |
| `CONNECT_NACK` | reason | handshake rejected | §4.3 |
| `EVENT` | topic, header, data | delivered message | §6.1 |
| `UNDELIVERED` | id, topic, header, data | dead-letter: no recipient | §6.6 |

The server never acks or nacks *message delivery* — no `SUBSCRIBED` or `ERROR` frames. The only server control frames are the handshake ack/nack (`CONNECT_ACK`/`CONNECT_NACK`), a connection-level exchange with no routing (§4.3). For everything else the protocol assumes a **reliable local connection** (localhost binding): the server only sends `EVENT` frames, plus `UNDELIVERED` dead-letter frames (§6.6).

### 5.2 Frame-level error handling

The boundary between Layer 1 and Layer 2 on errors:

- **Logical errors never drop the connection.** A bad frame, unknown topic, or malformed filter is logged and the connection keeps serving (Layer 2 tolerates bad content).
- **Connection interruption does drop the connection.** Only a dead connection removes its entry from the `client_id → connection` map (Layer 1, §4.3).

### 5.3 Protocol versioning

- The envelope carries `protocol_version`; `CONNECT` negotiates the protocol version. A client speaking an incompatible version is **rejected**: the server sends `CONNECT_NACK { reason: "protocol_version_incompatible" }` and closes the connection (§4.3).
- A rejected handshake is **observable**: the daemon emits a `/telemetry/axon/connect-rejected` event (source `axon.daemon.<pid>`, attrs `{ reason, client_id }`). The rejected client is being closed, so this is fire-and-forget observability for any sink/subscriber — it may have zero recipients.
- The `client_id` convention (§4.4), topic grammar (§7.1), `source` convention and well-known attrs keys (§7.2) are part of the frozen contract — components version-match their emission against the current protocol. `client_id` itself is daemon-internal (connection tracking/routing) and is not part of the wire message contract.
- Per-topic payload schemas evolve independently; a schema change bumps that topic's schema version, not the wire protocol.

## 6. Layer 3 — Pub/Sub

Owns the message model and the routing behaviors that move a message from producer to consumer(s). It rides Layer 2 frames and uses Layer 4 vocabulary — but it never interprets what a topic or header *means*.

### 6.1 Message envelope

Every published and delivered message shares one envelope shape:

```json
{
  "type": "event",
  "protocol_version": 1,
  "id": "m-0000000a",
  "topic": "/telemetry/dust/task-started",
  "header": {
    "source": "dust.walk.5102",
    "emitted_at": "2024-08-16T09:46:40.123Z",
    "workspace": "/opt/apps/elan",
    "correlation_id": "r-124",
    "parent_correlation_id": "/r-100",
    "attrs": {
      "component": "dust",
      "goal_id": "01-fix-login",
      "task_id": "tasks/03",
      "agent": "opencode",
      "level": "info"
    }
  },
  "data": { "task": "tasks/03", "status": "started" }
}
```

#### Fields

| Field | Type | Description |
|---|---|---|
| `type` | string | frame type (`event` for published/delivered messages) |
| `protocol_version` | int | protocol version (1) |
| `id` | string | unique message id, monotonic per client (`m-<seq>`) |
| `topic` | string | namespaced topic (§7.1) |
| `header.source` | string | producer-stamped origin descriptor (§7.2) |
| `header.emitted_at` | string | emit time, RFC 3339 UTC timestamp, milliseconds (e.g. `2024-08-16T09:46:40.123Z`) |
| `header.workspace` | string | workspace id (root path) this message belongs to |
| `header.correlation_id` | string | this invocation unit (§7.3) |
| `header.parent_correlation_id` | string | the `/`-prefixed namespaced chain of ancestors, root first (§7.3); empty for roots |
| `header.attrs` | map | multi-dimensional attribute map — `key: string → value: string` (§7.2) |
| `data` | object | typed payload; schema per topic |

The header is the envelope's semantic container: the meaning of each header field is the Layer 4 contract (§7.2, §7.3).

### 6.2 Subscription protocol

A subscription is **topic pattern + attribute filter**. The topic selects the coarse kind; the filter (any header field or any `attrs` key) selects the precise context.

#### SUBSCRIBE frame

```json
{
  "type": "subscribe",
  "id": "sub-01",
  "topic": "/telemetry/**",
  "filter": {
    "correlation_id": "r-124",
    "parent_correlation_id": "/r-100",
    "workspace": "/opt/apps/elan",
    "attrs": { "level": "info" }
  }
}
```

- **topic** — exact topic or glob pattern. `*` matches one segment, `**` matches the remainder. Examples: `/telemetry/dust/task-started` (exact), `/telemetry/**`, `/agent/**`, `**`.
- **filter** — a set of **predicates, ANDed together**. Each predicate is a header field or `attrs` key with a match value. An empty filter matches everything on the topic.
- **All filter values support wildcards.** Every predicate value is a glob: `*` matches any run of characters (including none), `?` matches a single character. Examples: `source: "dust.walk.*"` (any PID of a dust walk), `workspace: "/*/elan"`, `attrs: { "goal_id": "0*-*" }`. This matters because PID-based instances are transient — consumers match `*.walk.*` / `dust.*.5102` rather than hardcoding a PID.
- **correlation fields match by namespace prefix.** A predicate on `parent_correlation_id` (or `correlation_id`) matches the field exactly or as a `/`-separated prefix — so `/r-100` matches `/r-100`, `/r-100/r-124`, and `/r-100/r-124/r-125` — and the value may still contain `*`/`?` wildcards.
- **`source` is a subscribable header field.** A filter may match `source` (e.g. `dust.walk.5102`) — the producer-stamped origin of a message. Note the distinction from `client_id`: `client_id` is connection tracking only and never appears in a message; `source` is what a consumer subscribes on to scope to a producer (§7.2).
- A client may hold many subscriptions, each identified by `id`. Subscriptions are **additive** — there is no unsubscribe; a client that no longer wants a stream either subscribes to nothing matching it (e.g. an empty topic/filter) or simply drops the messages it doesn't want.

### 6.3 Matching semantics

A message is delivered to a subscription **iff** the topic pattern matches **and** every filter predicate matches the message. The filter is a flat set of header predicates plus a nested `attrs` map — all **ANDed** together (§6.2):

- **Header predicates** — the filter's top-level keys (`source`, `workspace`, `correlation_id`, `parent_correlation_id`) match against the corresponding `header` field. A predicate is *satisfied* when its value glob matches the message's field — exact values are just globs without wildcards (§6.2). Correlation fields additionally match by namespace prefix before globbing.
- **`attrs` predicates** — the filter's `attrs` map matches against the message's `header.attrs` map, key by key:
  - Every key named in the filter's `attrs` **must exist** in the message's `attrs`; a missing key fails that predicate, and therefore the whole subscription.
  - For each named key, the message's value must **satisfy the filter's glob** (`*`/`?` wildcards; exact values are globs without wildcards).
  - `attrs` keys present in the message but **not named in the filter are ignored** — a filter only constrains what it names.

An empty filter (no predicates) matches every message on the topic. Every predicate — header and `attrs` — must hold for delivery.

#### Example: subscribe to one elan invocation (the whole chain)

```json
{
  "type": "subscribe",
  "id": "trace-01",
  "topic": "**",
  "filter": { "parent_correlation_id": "/r-100" }
}
```

Delivers every message anywhere under elan run `r-100` — regardless of component, topic, or workspace, because every descendant carries a `parent_correlation_id` prefixed with `/r-100` (the chain goes all the way to the root). This is the "subscribe on all messages related to one elan call" capability, enabled by the correlation header (§7.3).

#### Example: attr-scoped telemetry for one goal

```json
{
  "type": "subscribe",
  "id": "goal-telemetry-01",
  "topic": "/telemetry/**",
  "filter": {
    "workspace": "/opt/apps/elan",
    "attrs": { "goal_id": "01-fix-login", "level": "info" }
  }
}
```

Delivers `/telemetry/**` messages in workspace `/opt/apps/elan` whose `header.attrs` contains both `goal_id: "01-fix-login"` and `level: "info"`. A message missing either key — or holding a non-matching value (e.g. `level: "warn"`) — is not delivered, even if its topic pattern matches.

### 6.4 Routing & dispatching

- A client sends `PUBLISH {topic, header, data}`; `header.source` is producer-supplied. The connection's `client_id` never appears in a message.
- The server validates the topic against the namespace grammar (§7.1) and enforces a fixed `data` size cap (**16 MiB**), then fans out to every matching subscription. If **zero** subscriptions match, the server sends an `UNDELIVERED` frame to the publisher instead (§6.6).
- **No queues, no backpressure.** The bus holds no internal queues: on `PUBLISH` it resolves matching subscriptions and dispatches each `EVENT` asynchronously to the target connection. This is a single-machine bus with a handful of clients; the cost is trivial.
- A publisher does not receive its own message unless it also subscribes to it.

### 6.5 Delivery semantics

- **At-most-once, live.** In-memory fanout to connected clients: no persistence, no replay, no guaranteed delivery (Phase 1; the store is a Phase 7 sink). Ordering is per-publisher FIFO; no global order.
- **No message-level ack/nack — a principle, not a rule.** The bus never acks or nacks delivered messages: a deliberate choice to avoid application-level ack flows and keep inter-component interactions simple. It is **not** a constraint on producers — each producer manages its own work however it likes, and may arrange its own certainty (e.g. result topic + correlation, or the `UNDELIVERED` signal, §6.6). The bus itself offers no delivery guarantee: loss on loopback is near zero, but not zero.

### 6.6 Dead letter — `UNDELIVERED`

By design there is no message-level ack/nack (§6.5): the bus never confirms delivery, keeping inter-component flows simple. That is a principle, not an imposition — a producer may arrange its own certainty however it wants. What the bus cannot do is hide the no-recipient case, so it reports it with a dead-letter frame — `UNDELIVERED`, sent when a published message found **no recipient**. The frame type itself is the signal; **no flag is needed on `PUBLISH`**.

- **Discovery is the bus's job:** a producer *cannot know at publish time* whether a recipient exists — subscribers connect/disconnect dynamically, and only the bus sees the live subscription set. No-recipient is knowable **only after** the bus runs filter/dispatch, so the bus reports it back via `UNDELIVERED`.
- **When it fires:** a `PUBLISH` matches **zero** active subscriptions at dispatch time — the target component crashed or ended earlier than expected, or no consumer is currently subscribed to that topic/filter.
- **Delivery:** whenever zero subscriptions match, the server sends `UNDELIVERED` back to the publisher's connection. Handling is the client library's concern: `axon-client` surfaces it through an **optional dead-letter callback** (goal.md §3); without one it logs and drops it — so applications that don't care are unaffected, and applications that do (e.g. a request expecting a result subscriber) get an explicit no-recipient signal.
- **Payload:** echoes the original message — `id`, `topic`, `header`, `data` — so the producer has what it needs to decide what to do.
- **Not an ack/nack:** `UNDELIVERED` is not a delivery receipt and says nothing about delivered messages; it is purely the no-recipient signal. The producer decides whether to act: retry, log, alert, or ignore.

## 7. Layer 4 — Message conventions

The top layer defines the vocabulary — the contract every component emits against. Layer 3 routes the envelope; this layer defines what goes in it and what it means.

### 7.1 Topic namespace

> **Scope note:** the grammar, kinds, and all example topics below are **illustrative of structure only**. This phase freezes the topic *shape* (`/kind/component/subject...`) and the kind set — not any specific topic. No per-topic logic or schema is defined here; concrete topics and their payload schemas are covered in later phases, per component.

#### Grammar

```
/ <kind> / <component> / <subject...>
```

- **kind** — the message domain (taxonomy below).
- **component** — the emitting component (`ash`, `dust`, `elan`, `adapter`, `vscode`, `axon`). Wildcards never appear in an emitted topic.
- **subject** — free-form path segments, lowercase-hyphen, describing the specific thing.

Wildcards exist only in subscription patterns, never in emitted topics: `*` (one segment), `**` (any remainder).

#### Kind taxonomy

Three kinds cover the bus; everything else is a dump into `telemetry`:

| kind | Meaning | Examples |
|---|---|---|
| `telemetry` | the general dump: metrics, diagnostics, log lines, task/step activity — anything not covered by a dedicated kind | *topic details TBD with the first emitter* |
| `agent` | target-agent interaction (via adapter): started / completed / report | `/agent/started`, `/agent/completed`, `/agent/report` |
| `goal` | elan-level goal events | `/goal/transition`, `/goal/calibrate` |

- `result` is **not** a kind — structured results ride the payload of the `agent` complete event (or the `telemetry` dump).
- Agent **progress reporting is deferred** — Phase 1 covers agent started/completed only.

#### Rule of thumb

Put **what kind of message** in the topic; put **which context** in the header/attrs. A consumer wanting "all telemetry in workspace W for goal G" subscribes to `/telemetry/**` with filter `{workspace: W, goal_id: G}` — not a topic explosion.

### 7.2 Message header

The header is the message's context container. Each field is a subscribable dimension (§6.2).

#### The `source` field

`header.source` is a producer-stamped origin descriptor identifying *what* emitted the message, following the same `<component>.<surface>.<instance>` shape as `client_id` (e.g. `dust.walk.5102`). It is **not** the connection identity: `client_id` (§4.4) is daemon-internal, used only for connection tracking and routing, and never appears in a message. `source` is what a consumer subscribes on to scope to a producer, and it decouples the message's origin from the underlying connection (one process may publish under several sources on one connection).

#### The `attrs` map — the multi-dimensional dimension

`attrs` is the extensible, subscribable dimension. Well-known keys (set by emitters whenever relevant):

| attrs key | Meaning | Example |
|---|---|---|
| `component` | emitting component | `dust` |
| `goal_id` | elan goal folder/id | `01-fix-login` |
| `task_id` | dust task id | `tasks/03` |
| `agent` | underlying agent (adapter) | `opencode` |
| `level` | severity/log level | `info`, `warn`, `error` |
| `script` | ash script path | `scripts/build.ash` |

`attrs` values are **strings only** (`string → string`) — no typed values, no comparison predicates (e.g. `level >= warn`) in Phase 1; filters match via glob equality (§6.2).

Any additional key is allowed — emitters add dimensions as needed; subscribers filter on them without bus changes. This is what makes subscription **precise**: the topic narrows to the message *kind*, attrs narrow to the message *context*.

### 7.3 Correlation model — invocation chains

Every piece of work (a command call, an `act`, an agent call) is an **invocation unit** identified by a **correlation id**. Invocations form a tree, and the header carries the whole ancestry as a **namespaced chain that goes all the way to the root**:

- **correlation_id** — this unit. Assigned by the caller at command-call time (run-id handoff, tech-design.md §2). One unit = one id.
- **parent_correlation_id** — the namespaced chain of ancestors, root first, down to the direct parent, as a `/`-prefixed path: `/r-100`, then `/r-100/r-124`, then `/r-100/r-124/r-125`, … **Roots have an empty `parent_correlation_id`**. The `/`-prefix aligns with the topic convention (§7.1) and filesystem-style paths. The chain is what makes "everything under one elan call" one subscription — a subscriber matches a prefix of the chain, and the root is always the first segment.

#### elan → dust → ash example

```
elan "implement oauth"                        correlation r-100   parent ""
  └─ elan ─command→ dust tasks/               correlation r-124   parent /r-100
      └─ dust ─command→ ash script.ash        correlation r-125   parent /r-100/r-124
          └─ ash ─command→ adapter opencode   correlation r-126   parent /r-100/r-124/r-125
```

The full chain of an invocation is a single `/`-prefixed path: `parent_correlation_id` + `/` + `correlation_id` (e.g. `/r-100/r-124/r-125`). Because `parent_correlation_id` is a namespaced prefix of that chain:

- `parent_correlation_id == /r-100` → the whole elan goal run's messages — telemetry, goal events, agent activity (everything anywhere under `r-100`).
- `correlation_id == r-125` → just the ash script's messages.
- `parent_correlation_id == /r-100/r-124` → everything under the dust invocation directly.

#### Propagation through command calls

Because invocation is via CLI command calls (tech-design.md §2), the correlation chain is handed off through the environment — keeping the command contract the only inter-component dependency:

- The caller exports `ELAN_RUN_ID` (the child's fresh correlation id), `ELAN_PARENT_ID` (the caller's own chain — a `/`-prefixed path: its `parent_correlation_id` + `/` + its `correlation_id`), `ELAN_WORKSPACE`.
- The child's `axon-client` reads these to seed the default header on every message it emits — its `parent_correlation_id` is exactly `ELAN_PARENT_ID` — and passes updated values when it spawns its own children.

## 8. Decisions to lock (resolved from goal.md)

| Decision | Resolution |
|---|---|
| Reply semantics | **Plain topic + correlation id.** No dedicated reply topic; a requester subscribes to the result topic filtered by its correlation id (§6.3). |
| Envelope/schema home | **Shared `axon-schema` crate** — envelope types, topic constants, well-known attrs keys, validation. A schema dependency, not component code coupling (tech-design.md §3). |
| Client id | **Mandatory `client_id`** on every connection, §4.4 convention. |
| Correlation | **Two fields** — `correlation_id` + `parent_correlation_id` as a `/`-prefixed namespaced chain to the root — propagated through CLI env (§7.3). |
| Workspaces | **One daemon, `workspace` header dimension** for multi-workspace routing (§7.2). |
| Transport | **Plain TCP over loopback only** (`127.0.0.1`, port via `AXON_PORT`, default `19191` — §9). Unix-domain socket is out of scope (§4.1). |
| Configuration | **Environment variables only, `AXON_` prefix.** No config files — no file location/format/parsing dependency, no CLI flags. Knobs: `AXON_PORT`, `AXON_HANDSHAKE_TIMEOUT_MS` (§9). |
| Data size cap | **Fixed 16 MiB** on `data` per message; not configurable (§6.4). |
| Handshake ack/nack | **`CONNECT_ACK`/`CONNECT_NACK`, handshake-only, no routing.** Server acks an accepted `CONNECT` with `CONNECT_ACK`; rejects with `CONNECT_NACK { reason }`, closes the socket, and emits `/telemetry/axon/connect-rejected`. Client waits for `CONNECT_ACK` under a handshake timeout; any other frame before completion is a protocol error, and failures must print the exact cause. No message-level ack/nack — routing stays ack-free (§6.5). |
| Dead letter | **`UNDELIVERED` frame on zero-match, no flag.** Whenever a `PUBLISH` matches zero subscriptions, the server echoes `UNDELIVERED {id, topic, header, data}` to the publisher; the frame type is the signal. `axon-client` handles it via an optional callback. Not an ack/nack — the no-message-ack principle is unchanged (§6.5). |
| `attrs` value typing | **String→string, locked.** `attrs` values are strings; filter predicates match via glob equality only. No typed values or comparison predicates (`level >= warn`) in Phase 1 (§7.2). |
| Client presence | **No presence events in Phase 1.** Connect/disconnect is not published to the bus; connection state is daemon-internal. The only connection-level telemetry is `/telemetry/axon/connect-rejected` (§4.3). |
| Timestamp format | **RFC 3339 UTC (`Z`), milliseconds.** `header.emitted_at` is a string like `2024-08-16T09:46:40.123Z` — no implicit epoch/unit assumption (§6.1). |

## 9. Configuration

All knobs are `AXON_`-prefixed **environment variables**. There are **no config files** — no file location, format, or parsing dependency — and **no CLI flags**. Environment variables are inherited naturally through CLI command chains, exactly like the correlation env (§7.3).

| Var | Default | Applies to | Meaning |
|---|---|---|---|
| `AXON_PORT` | `19191` | daemon + client | TCP port for the loopback bind / connect address (`127.0.0.1:<port>`) (§4.1) |
| `AXON_HANDSHAKE_TIMEOUT_MS` | `2000` | client | max wait for `CONNECT_ACK` before the handshake fails (§4.3) |

What is **not** config: the bind host is fixed to `127.0.0.1` (§4.1); `client_id` is derived, never configured (§4.4); `workspace` seeds from `ELAN_WORKSPACE` (§7.3); the `data` size cap is a fixed protocol constant (§6.4).
