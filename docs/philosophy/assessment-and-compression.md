# Optimizing LLM Decision Quality and Computing Cost

## The question

When an agent must decide something — whether to decompose a goal, whether a human should be involved, which deliberation workflow to run, which model to use — how do we get **near-optimal decision quality at minimum computing cost** (time + tokens)?

The naive options bracket the problem: read everything for every decision (maximum quality, maximum cost) or feed a tiny summary (cheap, but the decision degrades). This document answers the question in between. It distills a working discussion that began with "should `01_axon` be decomposed?" into the reasoning that governs it.

## 1. The core tension: compression is cost, and it is decision-specific

**Cost optimization is, at bottom, compression.** A decision's cost is dominated by the context it must consume. The only way to make many decisions over a large source cheap is to build a smaller artifact once and consume it many times. That artifact is a compression of the source.

**But compression risks decision quality, and the optimum is decision-specific.** This is a rate–distortion problem: minimize distortion (impact on decision quality) for a given rate (cost). The decisive property is that *the optimal compression depends on the decision.* A fixed summary is a projection chosen before the decision set is fully known; every decision pays for the projection's mismatch. There is no single best summary — only one that is optimal for a given decision or family of decisions.

Two consequences that shape the whole answer:

- **"Full context" is not actually lossless.** An LLM attending over a large context is itself a compression; long contexts degrade attention (mid-context forgetting, recency bias). Full-context-in-prompt is neither the quality ceiling nor cheap.
- **By reference is decision-aware.** Giving the agent the source by reference and letting it read what it decides to read delegates the compression to the decision-time model, which is decision-aware by construction. This is the "lazy/safe" strategy — and the right default.

## 2. The cost model: where the savings come from

Let `S` = cost of one pass over the full source (goal + all related designs), `F` = cost of a decision pass over a small artifact (`F ≪ S`), and `E ≈ S` = one-time cost to build the artifact.

| Strategy | N decisions | With revisits (k rounds) |
|---|---|---|
| Read full source per decision | `N·S` | `k·N·S` |
| Build artifact once, decide cheap | `E + N·F` | `k′·E + k·N·F` |

Two-pass breaks even at roughly `N > 1` and saves nearly a full source-read per decision after that; revisits amplify it (direct re-pays `S` per decision per round; the artifact approach only rebuilds when facts change). The artifact is a **materialized summary** — computed once, queried cheaply.

This economics is real, but it only materializes if decisions work from the artifact alone. That is exactly where the quality risk lives: the artifact is a fixed projection, and every decision it serves is limited by what the projection captured. So the cost argument and the quality argument pull opposite ways, and the question becomes: *how do we capture the savings without paying for it in decision quality?*

## 3. What actually preserves decision quality

Four mechanisms, in increasing order of how much they can be trusted:

1. **Decision-aware retrieval.** Index the source; pull only the sections relevant to the decision. Compression is query-dependent, so distortion is low and cost tracks what is read.
2. **Scaffold, don't substitute.** A compressed summary guides attention, but the source stays available by reference; when a factor is high-stakes, the decision actor re-reads the underlying source before deciding.
3. **Empirical validation.** Sample decisions, run them with full context and with the compressed artifact, measure divergence; adopt compression only where it does not flip consequential decisions. This is the only real assurance.
4. **Deterministic extraction.** Countable facts (how many open decisions, how many deliverables) can be extracted by code — zero loss, near-zero cost, verifiable by construction. Determinism is the rare case where cost and quality improve together; only the semantic residue (e.g. "is this thing a contract?") needs an LLM pass.

## 4. The optimization strategy

The answer, as a procedure. Each step is adopted only when the previous one is insufficient; the default is the cheapest step that preserves quality for the decision at hand.

**Step 1 — Default: full context by reference.** Each decision actor takes the goal and its related designs by reference, reads what it needs, and renders its own judgment. Prompt guidance supplies *attention* (what to weigh) and an *escalation rule* (re-read the underlying source before deciding when something is high-stakes). No mandatory pre-computed artifact. This is decision-aware, minimum-distortion, and cheaper than full-context-in-prompt because the agent reads selectively.

**Step 2 — Deterministic extraction for countable facts.** For anything expressible as a count or a named list, prefer code over the LLM: counts of open decisions, deliverables, contracts, dependents. Zero loss, near-zero cost, repeatable.

**Step 3 — Add a factor table only for the repeated, cheap decision path.** When the same goal is re-decided many times or revisited as facts change, materialize a summary — the primitive factor set (§5) — so each cheap decision skips the source read. This step is **validation-gated**: sample decisions run with and without the table; if the table flips consequential decisions, it is not admitted for that goal.

**Step 4 — Escalate: the adopted strategy for reconciling cost and quality.** The cheap path and the faithful path are not a binary — they are two rungs of a **cascade** borrowed from FrugalGPT / cascade inference (§6.6). A cheap decision pass produces its answer **plus a confidence signal**, and escalates to a more expensive, higher-fidelity path (full context, deeper reasoning) when that signal is weak. Two escalation triggers, used together:

- **Confidence-based** (the borrowed mechanism): the cheap pass emits a confidence score (native generation probability where available, else a calibrated self-reported score); escalate when `confidence < threshold`. The threshold is **calibrated against measured divergence** (§3.3), not hand-picked — set it where cheap decisions stop flipping consequential outcomes.
- **Factor-based**: escalate when the decision hinges on a high-stakes factor (many dependents, high coupling, unresolved decisions) regardless of confidence — stakes gate confidence.

The contract is fixed: **every cheap decision path returns `(answer, confidence)`**, and escalation is a decision rule over that pair. This keeps cheap decisions cheap (they only pay for the cheap pass) while bounding quality impact by the escalation trigger.

**Step 5 — Measure.** The only durable assurance is empirical: track divergence between artifact-based and full-context decisions, and revisit any compression that shows a quality gap.

The single organizing principle: **push as much cost as possible into deterministic, one-time work; keep LLM compression only where judgment is genuinely required; and never let a fixed summary silently stand in for context the decision actually needs.**

## 5. The primitive factor set (the candidate artifact)

If a materialized summary is warranted, it should be a set of **primitive, measurable, orthogonal** dimensions — counts, not judgments — so it is cheap to produce and comparable across goals:

| # | Factor | Dimension | Metric |
|---|---|---|---|
| 1 | Deliverables | size | count of distinct artifacts the goal produces |
| 2 | Open decisions | uncertainty | count of unresolved choices (TBD, "decide", open questions) |
| 3 | Contracts | external surface | count of cross-boundary interfaces the goal defines |
| 4 | Dependents | significance / cost impact | count of external units that consume those contracts |
| 5 | Coupling | internal structure | count of precedence/interdependence edges among deliverables |
| 6 | Reference size | input volume | amount of existing material to absorb or rewrite |
| 7 | Verification scenarios | behavior surface | count of distinct behaviors / failure paths to verify |

Orthogonality keeps the projection shallow and its loss bounded: each axis is independent of the others, and situational concerns dissolve into primitives (e.g. "freeze-before-emit" and "late-change cost" are significance — measured as Dependents + Contracts; the freeze is a *policy response* a decision actor triggers when those are high, not a target property).

For the **decompose** decision specifically, the controlling question is model-relative: **can a coding agent handle this goal in a single oneshot request?** Each factor maps to a budget in that fit — Open decisions are a hard gate (nonzero → deliberate first), Reference size is the context budget, Deliverables + Verification scenarios are the work/loop budget, Contracts/Dependents are precision cost and risk, Coupling is the seam constraint (decompose along low-coupling cuts until each sub-goal is oneshot-feasible).

## 6. Prior art

The question — how to get near-optimal LLM decisions at minimum computing cost — has a substantial literature. Each work below is introduced briefly and tied to where it informs this document.

### 6.1 Rate–distortion theory — Shannon (1948); Berger (1971)

Shannon's *A Mathematical Theory of Communication* and Berger's *Rate Distortion Theory: A Mathematical Basis for Data Compression* formalize the tradeoff at the heart of this document: the minimum rate (bits) needed to reproduce a source under a given distortion, and — critically — that the optimal code is *source- and distortion-function-specific*. This is the formal basis for the claim in §1 that "the optimum is decision-specific": there is no single best compression, only one optimal for a given decision's distortion measure.

### 6.2 Information bottleneck — Tishby, Pereira & Bialek (1999)

*The Information Bottleneck Method* asks for the *minimal sufficient statistic* — the coarsest representation that preserves as much information as possible about a *target* variable while discarding everything else. This is exactly the shape of "compression that least impacts the decision": the factor vector is an information bottleneck chosen for a downstream decision set. The method also makes concrete why a fixed projection is lossy: it preserves information relevant to one target at the expense of another.

### 6.3 Bounded rationality and satisficing — Simon (1955)

*A Behavioral Model of Rational Choice* argues that decision makers do not optimize; they *satisfice* — search until an acceptable option is found, trading deliberation cost against outcome quality. This is the human analogue of the rate–distortion tension, and it licenses the pragmatic stance of §4: the goal is not "the optimum decision" but the best decision affordable at the cost budget, with escalation reserved for high-stakes cases.

### 6.4 Lost in the Middle — Liu et al. (2023)

*Lost in the Middle: How Language Models Use Long Contexts* shows empirically that LLM performance degrades when the relevant information sits in the middle of a long context — attention dilutes, and both ends of the context dominate. This grounds the claim in §1 that "full context is not lossless": feeding everything is not a free quality ceiling, and selective context can outperform exhaustive context.

### 6.5 Retrieval-Augmented Generation (RAG) — Lewis et al. (2020)

*Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks* splits a task into retrieval over an external corpus plus generation over the retrieved slice. This is the canonical implementation of **decision-aware retrieval** (§3.1): instead of compressing everything up front, index the source and pull only what the current query needs, so cost tracks the fraction actually read.

### 6.6 FrugalGPT — Chen, Zaharia & Zou (2023)

*FrugalGPT: How to Use Large Language Models While Reducing Cost and Improving Performance* (arXiv:2305.05176) introduces an **LLM cascade**: run the cheapest model first and escalate to costlier models only when needed, learning which combinations of LLMs to use for different queries to maximize accuracy under a cost budget. This is the model-level analogue of the escalation policy (§4, §7 open question).

Its answer to "how do you tell easy from hard" is directly relevant: it does **not** pre-classify queries. Instead, it uses a **cheap, model-output-based signal** — the current model's confidence in its own answer (the response's probability), compared against a **learned threshold** — to decide whether to stop (the query was "easy enough" for the cheap model) or escalate. The stop/escalate policy and thresholds are learned from data, not hand-coded. This is the pattern our escalation policy should follow: the cheap decision pass emits its own confidence/evidence signal, and the escalation threshold is calibrated against real divergence measurements rather than guessed.

### 6.7 Prompt compression — Jiang et al. (2023)

*LLMLingua: Compressing Prompts for Accelerated Inference of Large Language Models* compresses prompt tokens before inference, keeping task performance largely intact. It is a direct, token-level implementation of the context-compression idea — with the same risk this document warns about: compression that preserves average performance can still flip a consequential decision, which is why the fidelity check in §3.3 must be decision-level, not average.

### 6.8 Least-to-Most prompting — Zhou et al. (2022)

*Least-to-Most Prompting Enables Complex Reasoning in Large Language Models* decomposes a hard problem into easier subproblems solved in order, each step consuming the previous result. This is the prior art for the decompose decision in §5: decomposition is a way of converting a task that exceeds one-shot capacity into a sequence of one-shot-capable sub-tasks — the same "decompose until each sub-goal is oneshot-feasible" principle, expressed as a prompting technique.

### 6.9 Chain-of-thought — Wei et al. (2022)

*Chain-of-Thought Prompting Elicits Reasoning in Large Language Models* shows that letting a model spend more intermediate tokens on reasoning improves quality on multi-step tasks. It frames reasoning effort as a cost knob: the same model can trade tokens for decision quality. This motivates treating compute budget as an explicit decision input (§2), and explains why a cheap decision pass (short reasoning) is expected to be less reliable than an escalated one.

## 7. Open questions

- **Escalation policy — adopted (§4 Step 4).** Decision paths return `(answer, confidence)` and escalate when confidence falls below a divergence-calibrated threshold, or when a high-stakes factor is involved. Open remainder: how the confidence signal is produced (native log-probability vs. calibrated self-report) and how often the threshold is recalibrated.
- **Validation cadence.** Is divergence checking a step in the actor workflow, or a manual practice run when divergence is suspected?
- **Determinism boundary.** How much of the extraction spec should be written as rules now (so it is code-able later) versus LLM-judged today?
