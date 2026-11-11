# Human Steering: What, How, When

## Overview

This document reasons through elan's human-steering design along three questions: **what** judgment the human supplies, **how** it is delivered, and **when** it is solicited. It expands the brief treatment in `concept.md` §5 and the earlier framing in `steering-concept.md` (§3.5, §4.2) into a design rationale with failure modes.

The design rests on two prior commitments: relentless action is the default (no "executing" state — `concept.md` §2), and a child's only upward interface to its parent is progress reporting, with calibration the parent's responsibility (`concept.md` §4). Human steering is therefore best understood as a special case: **the human is a parent node that supplies judgment but need not be continuously present.**

## 1. Why a human at all

The case for a human is not psychological but control-theoretic: **Ashby's Law of Requisite Variety.** A regulator can keep a system's essential variables within limits only if its own variety — the states it can distinguish and respond to — is at least as great as the variety of the perturbations acting on it. Only variety can absorb variety; unabsorbed variety does not disappear, it leaks through as a state the regulator cannot tell apart, hence cannot respond to.

An agent is a regulator facing two disturbance sources: the **principal's preferences** (what is wanted, and how it changes) and **its own execution** (fast, parallel, scaled behavior). The law applies to both, and it yields both halves of the design at once:

- **Over preferences, the model is variety-bounded by the human.** The principal *is* the source of what is wanted; the model holds at best a history-derived approximation. It cannot distinguish the principal's preferences better than the principal can, so it cannot regulate them to zero — wrong-goal states remain that it cannot tell from right ones. That residual variety must be absorbed by the human (steering) or it leaks through as wrong-goal failure. **Steering is an assignment of where leaked variety goes, not an option.** The model's variety over preferences is bounded *below* the principal's, and capability does not close the bound — a predictor of preferences is still bounded by them; a changed preference is new state, outside any history. Capability shrinks the *frequency* of the need, not its existence.
- **Over execution, the human is variety-bounded by the process.** Bounded attention gives the human tiny variety against a fast, parallel, scaled process. The human cannot be a dense regulator — per-step approval is not merely expensive, it is structurally impossible. The human can regulate only where the required variety is small *and* the human's variety is decisive: coarse, goal-level decision points.

Both bounds follow from the same law, which is why the debate's two horns are one principle: **the human is needed exactly where the model's variety is bounded (judgment over preferences), and is usable only where the required variety is small (sparse points).** What the human supplies — the value only they can provide — is judgment about the goal's relation to the principal's values: whether the goal is the right goal, in light of preferences and world state that live outside the model's inputs. This is the practice literature's distinction between judgment and rule-following (Schön, 1983; Dreyfus & Dreyfus, 1986), and bounded rationality explains why a satisficing human who prunes a vast search space adds value even when imperfect (Simon, 1947, 1955).

The design problem is to capture that value **without reintroducing the bottleneck** autonomous designs exist to avoid. The entire what/how/when design answers: *what is the smallest interface that transfers the human's judgment — the value only they can provide — into the goal tree?*

A final consequence sharpens the rest of this document. **Recognition is variety allocation.** For the human's small variety to regulate, it must be aimed at the states that matter. Recent computer-use work finds the bottleneck is *recognition* — users failed to intervene not because they couldn't, but because moments were not made recognizable as requiring judgment (Comparing Human Oversight Strategies for Computer-Use Agents, 2026). Making the high-leverage moments *visible and decidable* is how a bounded human regulates a scaled process.

## 2. What the human supplies

### 2.1 Judgment, not approval

- **Approval gate** — every step is blocked until the human says go. Predictable and safe, but the human is the critical path and the system collapses to its latency.
- **Judgment source** — the human decides only where the agent's evidence is ambiguous or the search forks; otherwise the agent acts relentlessly.

elan targets the second. The test for whether a given interaction is judgment or approval: *does the human's answer change the shape of the goal tree, or merely ratify work that would happen identically anyway?* If the latter, it is an approval gate and does not belong.

The controlling question is whether the input is a **value only the human can provide** (an expression of the principal's preferences, an assessment of goal-worthiness, or a route choice the agent's evidence cannot discriminate) or a *computation the agent can perform itself*. Only the former justifies steering; the latter should have been automated.

### 2.2 The three structured interaction points

From `concept.md` §5, the human engages at:

1. **Priority setting / re-ordering** — setting and re-ordering top-level goal priorities. This is preference made concrete: the ordering encodes what the principal wants most, and no amount of agent reasoning derives it from the goal's features.
2. **Calibration decisions** — when a parent's assessment is ambiguous, the parent presents evidence and the human decides redefine vs abandon. This is goal-worthiness: whether the goal is still worth pursuing in light of the principal's current values — the value only the human can supply, since "is this the right goal" is a relation to preferences outside the agent's inputs (§1).
3. **Search direction** — when a goal has multiple genuinely plausible decompositions, the human steers which path to take. This is the one interaction point whose value is partly informational (domain knowledge of which route is likely to succeed) rather than purely preferential — the case where the human's variety exceeds the agent's.

Each is a point where the value of judgment is highest and the cost of automation error is highest: priorities encode taste, calibration encodes whether the goal is still worth pursuing, and search direction encodes domain knowledge about which route is likely to succeed.

This maps onto the **complementarity** result from selective prediction and learning-to-defer: human-AI teams outperform either alone *when the human contributes signal where the model is weak*, not when the human ratifies the model (Madras et al., 2018; Mozannar & Sontag, 2020). Indistinguishability arguments sharpen this: human judgment adds value on exactly the cases the model cannot discriminate from its features alone (Human Expertise in Algorithmic Prediction, 2024). All three interaction points sit precisely on cases of this kind — taste, goal-worthiness, and route choice are not derivable from the agent's execution features. Conversely, the interaction-taxonomy literature finds most human-AI systems are "AI-first" or "AI-follow" — the human supervises model output rather than supplying independent judgment — and that richer patterns (user-guided adjustment) are rare (Human-AI Collaboration Is Not Very Collaborative Yet, 2025). Elan's three points are deliberately the judgment-bearing ones, not supervision of outputs.

### 2.3 What the human explicitly does NOT supply

- **Not per-step verification.** Routine execution is the agent's relentless default. Verification is a computation the agent can perform; it is not a value only the human can provide.
- **Not force-directed implementation detail.** The agent owns how; the human owns whether and which direction.
- **Not legitimacy challenge from below.** Self-challenging was deliberately removed to avoid oscillation (`concept.md` §4). A human's calibration input enters at the parent level — including the human as the top-level parent — never as a child questioning its own premise.

## 3. How judgment is delivered

### 3.1 The channel

- The human interacts through an elan surface: `elan-vscode` (goal-tree GUI, decision dialogs, steering controls) or the `elan` CLI.
- The decision is **persisted to the goal's filesystem state** — a decision note written into the goal folder — so that agents and subsequent steps act on it. This is consistent with filesystem-backed goal state (`concept.md` §6): a decision is just another artifact in the goal's folder, and the goal's whole world remains inspectable on disk.
- **Asymmetric communication:** the agent argues (presents evidence, options, and its own recommendation); the human decides. The human should rarely need to compose an essay — choosing among prepared options is the normal case.

The asymmetric structure is supported by selective-prediction results: how the deferral decision is *communicated* to the human materially changes decision quality. Informing the human that the system is deferring — while not forcing the model's own prediction on them — boosts human accuracy; revealing the model's answer biases the human (Vodrahalli et al., AAAI 2021). Elan's "agent argues, human decides" keeps the agent's evidence front and center while keeping the human's final call independent — the same independence that human-AI ensemble work requires (Human-AI Ensembles, 2023).

### 3.2 Design properties of the mechanism

- **Persistent and inspectable.** A decision note is a normal file: revisitable, linked to its goal, auditable. A human decision becomes part of the goal's world, not a transient UI event that dies when a dialog closes.

  *Prior art:* oversight research finds humans must be able to *check and contest* AI outputs without re-solving the task — the "solve-verify asymmetry" (Designing Meaningful Human Oversight in AI, 2026). A persisted decision note is the elan-side realization of this: verification is cheap because the decision and its rationale are already materialized and browsable.
- **Asynchronous, pull-based.** A decision request does not require the human to be present. The goal folder records *awaiting decision*; the system is fully resumable when the human returns.

  *Prior art:* mixed-initiative interaction (Allen, 1999) and adjustable autonomy (Dorais et al., 1998; Goodrich, Olsen, Crandall & Palmer, 2001) established that initiative should shift opportunistically — whoever is best suited to the current step — rather than live at a fixed point. Studies of mixed-initiative control of robot teams found the deciding factor is that **agents must be able to make progress without waiting for human input** (Hardin & Goodrich, 2015), and that transfer-of-control to a human should be a *strategy* chosen to minimize the cost of waiting (Scerri, Pynadath & Tambe, 2004). Both results justify elan's pull-based, non-blocking model over synchronous approval.
- **Minimal decision surface.** Each request should be answerable in seconds: the agent argues, the human picks. If a decision needs an essay to explain, the request is mis-scoped and should have been decomposed first.
- **Non-blocking by default.** While a decision is pending, the tree should not stall wholesale (see §4.4).

### 3.3 Relationship to the goal FSM

A pending human decision is **not a new FSM state.** The goal remains in `defined` or `ready`, annotated with an *awaiting decision* note in its folder. The FSM's state set (defined/ready/end) is unchanged; the annotation is a progress-reporting pause, consistent with the "no executing state" stance — waiting on the human is one more situation the agent's default loop does not model as a state, only as a condition it reports upward.

## 4. When to engage

### 4.1 Default: never

All else equal, the agent requests no human input. Relentless action is the default; the burden of justification is on the request, not on the action.

### 4.2 Triggers (agent-initiated)

The agent requests input only when **all** of these hold:

- The decision is **high-cost and hard to reverse** (e.g., abandoning or redefining a large subtree) — otherwise just act and learn.
- The agent's **confidence is genuinely low** — the evidence is ambiguous, not merely incomplete.
- The decision **changes the shape of the goal tree** — not merely the details of the current step.
- The agent can frame it as a **bounded choice with evidence and a recommendation**, not an open-ended question.

If any condition fails, the agent should not ask.

*Prior art:* this is selective prediction applied at decision points. Selective classification / abstention showed that letting a model withhold predictions it is uncertain about — a *rejection* option — reduces error at the cost of coverage (Chow, 1970; El-Yaniv & Wiener, 2010; Geifman & El-Yaniv, 2017). "Fail Fast, or Ask" (Zellinger & Thomson, 2025) quantified this for reasoning models: deferring the ~7.5% of queries a model is least certain about cut error rates from ~3% to <1% — human time budgeted to exactly the low-confidence tail. Elan's triggers are the same shape: the agent asks only when its own confidence is genuinely low **and** the decision is consequential. The cost side (what over-deferral costs) is what guards the "ask too much" failure — see §5.

### 4.3 Human-initiated (asynchronous push)

The human can steer at any time, unsolicited: re-order priorities, inject a new constraint, redirect search. This is the mechanism that keeps the human in control without the agent stalling. The human initiates by editing the goal folder or acting through the GUI; the next `deliberate`/`calibrate` pass picks the change up and propagates it via the normal calibration cascade (`concept.md` §4). Asynchronous push means the human's oversight does not depend on being asked.

### 4.4 Bounded waiting

- Agent-initiated requests should be **rare** and **answerable in seconds**.
- While a decision is pending, the agent continues with independent, non-conflicting work — siblings unaffected by the decision, or sub-goals whose validity does not depend on it. Rolling decomposition (`concept.md` §8) already serializes siblings; a pending decision must not cascade a stall up the tree.
- **No nagging.** One request per decision point. An unanswered request is an annotation, not a repeating interrupt.
- Whether an unanswered request should eventually **time out** (proceed with the agent's recommendation, or a conservative default) is an open question — see §6.

*Prior art:* the timeout question is the classic adjustable-autonomy problem — transfer-of-control strategies explicitly model "the cost of waiting for a human decision" against "the risk of a lower-quality autonomous decision" (Scerri, Pynadath & Tambe, 2004). The human-in-the-loop control-design literature (R.A.I.L.: Reversibility, Ambiguity, Impact, Latency — AgentEngineering, 2026) makes the same tradeoff operational: put the human *before* irreversible, high-impact steps; keep latency constraints in view. Elan inherits this: because goal-tree decisions (calibrate/search) are relatively high-latency-tolerant, the bounded-waiting model fits; per-step decisions (low latency tolerance) are excluded by design.

## 5. Failure modes

- **The approval trap.** The system drifts toward gating: "no review, no proceed" becomes the norm, and the human is the critical path again. *Guard:* monitor the fraction of steps that are human-gated; it should stay tiny, and any gate should be justified by the §4.2 test.

  *Prior art:* the computer-use-agent comparison found richer oversight did *not* reliably produce safer outcomes — more control and visibility was often neutral or counterproductive because it distributed attention away from recognition (Comparing Human Oversight Strategies for Computer-Use Agents, 2026). Over-gating is therefore not just a cost; it can degrade the judgment it means to preserve. The approval-fatigue failure is also documented in agent-pattern catalogs (human-in-the-loop pattern — too many gates train users to click through without reading).
- **The judgment trap.** The agent asks questions it could answer itself — low-information requests that burn human attention. *Guard:* every request must carry evidence and a recommendation; if the human's answer is almost always "do what you recommend," the request threshold is too low.

  *Prior art:* the opposite failure — *under*-deferral — is the default in selective prediction (models that rarely abstain, and the abstention-rate calibration problem). "Fail Fast, or Ask" measured the accuracy-rejection curve explicitly so the deferral rate is a *tuned* parameter, not an accident (Zellinger & Thomson, 2025). Elan should do the same: treat the ask-rate as a measured, tunable quantity with a target band.
- **The attention trap.** Too many simultaneous pending decisions overwhelm the human. *Guard:* bound the number of open decision requests, batch them by the goal tree, and make the *awaiting decision* state visible so the human can clear a queue in one pass.

  *Prior art:* oversight-interface research (Faas et al., 2026; the SMART model of work design) finds **role overload** is a primary cause of oversight breakdown — and that batching, feedback, and autonomy in *timing* mitigate it. The "timing autonomy" pattern (save decisions, process later in one pass) is exactly the queue-clearing guard above.
- **The zombie goal.** A goal waits on a decision the human has silently abandoned, and neither the goal nor the human notices. *Guard:* the pending state is visible in the tree; resolving the wait (answer or abandon) is itself a visible decision.

## 6. Open questions

- What is the recommended default when a decision times out — proceed with the agent's recommendation, or take a conservative option?
- Should the agent ever overrule a human decision when new evidence contradicts it, or does that violate "the human decides"?
- What is the schema and naming of the decision note in a goal folder (e.g. `decision-01.md`), and how do multiple decisions over a goal's lifetime relate?
- How do human-initiated priority changes propagate into an already-running tree — reuse the calibration cascade, or a distinct mechanism?

## 7. Prior art and how it bears on this design

The design above synthesizes several literatures. The mapping:

| Prior art | What it establishes | Where elan uses it |
|---|---|---|
| Mixed-initiative interaction (Allen, 1999; Horvitz, 1999) | Initiative shifts opportunistically to whoever is best-suited; roles not fixed | The human-as-parent-node model: initiative is negotiated, not permanent |
| Adjustable autonomy & transfer-of-control (Dorais et al., 1998; Goodrich et al., 2001; Scerri, Pynadath & Tambe, 2004) | Transfer of control to the human should be a strategy that weighs waiting-cost vs decision-quality | §3.2 async pull-based; §4.4 timeout question; §6 |
| Mixed-initiative robot teaming (Hardin & Goodrich, 2015) | Agents must make progress without waiting for human input; interface must let the human grasp progress and intent fast | §4.4 non-blocking default; §3.1 asymmetric communication |
| Selective prediction / abstention (Chow, 1970; El-Yaniv & Wiener, 2010; Geifman & El-Yaniv, 2017; Zellinger & Thomson, 2025) | Reject low-confidence cases to trade coverage for error; the rejection rate is a tunable, measurable parameter | §4.2 triggers; §5 judgment-trap guard (measure ask-rate) |
| Learning to defer & human-AI complementarity (Madras et al., 2018; Mozannar & Sontag, 2020; Human Expertise in Algorithmic Prediction, 2024; Human-AI Ensembles, 2023) | Human value comes from signal where the model is weak; independence of the human's judgment must be preserved | §2.2 the three points as judgment-bearing; §3.1 independence |
| Computer-use agent oversight (2026) | Oversight is where judgment is reintroduced; the bottleneck is *recognition*, not control; more control ≠ safer | §1 framing; §5 approval trap |
| HITL control design / R.A.I.L. (AgentEngineering, 2026) | Placement heuristic: Reversibility, Ambiguity, Impact, Latency | §4.4 bounded waiting; §4.2 trigger conditions |
| Meaningful human oversight (2026); human-robot/HAI interaction taxonomies (Human-AI Collaboration Is Not Very Collaborative Yet, 2025; Vodrahalli et al., 2021; Faas et al., 2026) | Solve-verify asymmetry; how the deferral is *communicated* matters; role overload is a primary failure; interaction patterns are mostly supervisory today | §3.1, §3.2, §5 attention trap |

*Where elan departs from the literature:* most of this prior art treats human-AI interaction as **classification or single-decision** tasks — one prediction, one deferral. Elan applies the same structure to a *recursive goal tree*: the "deferral" points are structural (calibration, search direction, priority) rather than instance-level, and the human's decisions are persisted and composable (a decision note feeds downstream agent behavior). The recursive-decomposition context is the novelty argued in `steering-concept.md`; this document applies the steering half of that argument to the same tree. It also inherits the open questions from `steering-concept.md` (confidence thresholds that gate deferral; whether human decisions cascade to siblings) as elan-specific questions in §6.

## 8. References

- Allen, J. (1999). Mixed-initiative interaction. *IEEE Intelligent Systems*, 14(5).
- Ashby, W. R. (1956). *An Introduction to Cybernetics*. Chapman & Hall. (Law of Requisite Variety.)
- Horvitz, E. (1999). Principles of mixed-initiative user interfaces. *CHI*.
- Dorais, G. A., Bonasso, R. P., Kortenkamp, D., Pell, B., & Schreckenghost, D. (1998). Adjustable autonomy for human-centered autonomous systems. *IJCAI Workshop on Adjustable Autonomy Systems*.
- Goodrich, M. A., Olsen, D. R., Crandall, J. W., & Palmer, T. J. (2001). Experiments in adjustable autonomy. *IJCAI*.
- Scerri, P., Pynadath, D. V., & Tambe, M. (2004). Adjustable autonomy in the context of coordination. *AIAA*.
- Hardin, B., & Goodrich, M. A. (2015). On using mixed-initiative control: A perspective for managing large-scale robotic teams. *HRI*.
- Chow, C. K. (1970). On optimum recognition error and reject tradeoff. *IEEE Transactions on Information Theory*, 16(1).
- El-Yaniv, R., & Wiener, Y. (2010). On the foundations of noise-free selective classification. *Journal of Machine Learning Research*, 11.
- Geifman, Y., & El-Yaniv, R. (2017). Selective classification for deep neural networks. *NeurIPS*.
- Zellinger, M. J., & Thomson, M. (2025). Fail Fast, or Ask: Mitigating the deficiencies of reasoning LLMs with human-in-the-loop systems engineering. *arXiv:2507.14406*.
- Madras, D., Pitassi, T., & Zemel, R. (2018). Predict responsibly: Improving fairness and accuracy by learning to defer. *NeurIPS*.
- Mozannar, H., & Sontag, D. (2020). Consistent estimators for learning to defer to an expert. *ICML*.
- Human Expertise in Algorithmic Prediction. (2024). *NeurIPS*.
- Human-AI Ensembles: When can they work? (2023). *Journal of Management*.
- Vodrahalli, K., et al. (2021). On human-machine advice. (The role of human-AI interaction in selective prediction.) *AAAI*.
- Comparing Human Oversight Strategies for Computer-Use Agents. (2026). *arXiv*.
- Human-in-the-loop control design. (2026). *AgentEngineering.org* (R.A.I.L. placement model).
- Designing meaningful human oversight in AI. (2026). *AI and Ethics*.
- Human-AI collaboration is not very collaborative yet. (2025). *Frontiers in Computer Science*.
- Faas, C., et al. (2026). Design considerations for human oversight of AI: Insights from co-design workshops and work design theory.

*Related work:* the design question framed here — what to surface, when, and at what cost — follows the HITL-ML survey's framing (Mosqueira-Rey et al., 2023); the human-as-judgment-not-gate principle is `steering-concept.md`'s P4. See also the reference list in `steering-concept.md` (Schön, Dreyfus & Dreyfus, Simon, Argyris & Schön) for the underlying expert-practice and double-loop-learning groundings.

## 9. Justification

This document's premise — that human steering is needed and provides judgment value — is **derived from first principles in §1**, via Ashby's Law of Requisite Variety: the model's variety over preferences is bounded below the principal's (so unabsorbed variety must be steered or leaked as wrong-goal failure), while the human's variety over execution is bounded below the process's (so steering must be sparse). The interaction points in §2.2 are the minimal set that the §1 derivation forces — nothing more.

A prior panel debate (`debate/human-steering.ash`, archive under `debate/debate-output/`) explored the same question with opposing expert personas and reached a compatible conclusion; it is retained as a cross-check, not as the justification source. If the §1 derivation is overturned, this document should be revised to match.
