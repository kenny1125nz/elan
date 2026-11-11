# Position: Human Steering Is a Stopgap — Build It to Die

**Panelist:** Kai Tan — Autonomy Advocate, Staff Engineer (Agentic Infrastructure), Horizon Robotics

---

## The Position, Straight

Steering is needed today the way training wheels are needed on a six-year-old's bike: you bolt them on because the fall is expensive, you know they're coming off, and you're stupid if you design the bike around them. It is needed in the *short term*, it is needed *barely*, and its value is *real but shrinking every release*. Any position that treats human-in-the-loop as a durable architectural principle is building a legacy mechanism in live traffic.

I spent five years at FreightOS building and then retiring three separate human-approval systems for agent pipelines that ran thousands of unattended overnight jobs. Every gate was the bottleneck. Every gate was overridden on retry — the operators learned to approve whatever had already succeeded on its second pass. Every gate woke people up. I don't argue from theory; I argue from the corpse of three approval workflows that all died of the same disease: **waiting is where value dies.**

Let me be precise about the terms so we don't talk past each other. "Steering" is not telemetry. It is not auditing. It is not a dashboard. Steering is an *interaction point where the process halts and waits for a human decision before it may proceed.* Every interaction point is a place where the system sits idle burning the exact thing the automation was built to buy: speed. That's the definitional fact the other side keeps eliding.

---

## Is Steering Needed? Only as a Bridge, and Only Where the Agent Cannot Decide

Here is the honest accounting. Current agents do three things badly that a human genuinely can settle:

1. **Set the goal and its priority.** Whose objective is it, really, and what wins when two objectives collide? That is a values question. No amount of model capability "produces" the decision that the goal is the right goal — that's a judgment about the world outside the model, made by the person who owns the world.
2. **Call off a wrong goal.** When execution is confidently optimizing the wrong thing, someone has to have the authority to say "stop." That authority has to be assigned to someone before the moment, and it has to be cheap to invoke.
3. **Absorb the unbudgeted consequence.** There are failures that cost money or trust in amounts no model was trained to price. A human is the only sensor we have for "this went sideways in a way the spec didn't anticipate."

That's the whole list. Notice what's *not* on it: approving each step, adjudicating each sub-result, validating each intermediate output, clearing each checkpoint. Those are the tasks I'll call **derived decisions** — they follow from the goal by reasoning, and reasoning is exactly the thing getting better every quarter. When I read Claim A's framing — "human who supplies judgment: priorities, whether a goal is still worth pursuing, which direction the search should take" — the middle item is the only one that survives contact with the operational record. "Which direction the search should take" is what beam search is *for.* That's not a human task; that's the agent's core competency, and handing it to a human reintroduces the latency we automated away.

So: needed? Yes — at the *front door* and the *exit ramp*, and almost nowhere in between. Now, and for maybe the next two to three years. After that the question stops being "should the human steer" and becomes "should the human own the objective."

---

## The Value Steering Actually Provides — and How You'd Observe It

The value of steering is **sparse, real, and shrinking.** It concentrates in exactly two spots, and it is observable in exactly two ways:

**Value 1 — Error avoidance by precommitment (front door).** The human decides, at t=0, that this goal is worth pursuing and that its priority beats the alternatives. This is cheap, it happens when the human is already paying attention, and it's the highest-leverage decision in the entire run. Observable: the *fraction of runs that were not worth starting* — you can't measure counterfactuals directly, but you can measure it as: goal-initiation incidents where post-hoc review finds the goal was mis-specified. If the number stays nonzero and is caught at the front door, steering earned its keep there. It doesn't take many — catching one multi-thousand-dollar wrong-goal run at the door pays for a year of attention.

**Value 2 — Catastrophe truncation (exit ramp).** When something goes wrong, the human can pull the plug faster than the agent can reason itself out. Observable: **cost-at-failure — dollars and damage per incident**, not incident count. The argument for steering lives or dies on this metric. If a human gate truncates a runaway spend from $50,000 to $500, that's a real, observable, attributable return. I want that number on the board, because I've watched the other side claim value they can't show me a number for.

That's it. Those two. Everything else the "human judgment" framing tries to claim — better quality outputs, moral calibration, taste — is either (a) already covered by the goal the human set at the front door, or (b) noise that steals autonomy's speed advantage while producing ritual approval.

And let me pre-empt the Counterargument from Recognition — the brief's claim that "humans failed to intervene not from lack of control but from not recognizing the moment as decision-worthy." I read that evidence the opposite way. It says humans are *demonstrably bad monitors* — which is the entire empirical core of my position. The answer to "humans don't recognize decision-worthy moments" is not "put more recognition burden on humans." It is *stop using humans as monitors.* It is telemetry, exception escalation, and agent-side anomaly detection — which is literally the self-correction trajectory I'm pointing at. The computer-use oversight studies are not an argument for more steering; they're an argument that human monitoring is the weakest link, which is Bainbridge's 1983 "Ironies of Automation" replayed forty years later: automation leaves the human the exact tasks — passive monitoring, alert triage — that humans are worst at and most bored by. Claim A cites this as evidence for steering; I cite it as the reason steering is fragile.

---

## Durable or Temporary? Temporary. There Is No Serious Case for Durability.

The durability claim has to survive three structural facts, and it doesn't survive any of them.

**Fact one: the judgment gap narrows on a release cadence.** Self-correction, introspection, planning, calibration — these improve measurably and steadily, and unlike a human they improve without coffee breaks and without variance across operators. Reflexion, self-refine, self-consistency, verifier-based selection: these are not research curiosities, they're the current release notes. A position that designs interaction points around today's gap is optimizing for a moving target and will be re-architecting the moment the target moves — which it does, quarterly.

**Fact two: the bottleneck is physical, not fixable.** A human response costs tens of seconds to tens of minutes per interruption, plus context-switching overhead that Mullainathan & Shafir's work on scarcity documents as the real tax on attention. Fleet-scale, this compounds into *queuing* — the gates don't just add latency, they add serialization. I've run the numbers at fleet scale: when you have a thousand agents and forty operators, the interaction points don't filter, they *flood*. You end up with what healthcare calls alarm fatigue and what I call "my approvals dashboard looks like a slot machine." A mechanism where people stop discriminating because they're asked too often. That's not a feature of bad design; it's a feature of the constraint that attention is bounded and scarce.

**Fact three: scale is the architecture.** If the future is fleets — and it is — a human per process is a dead end by definition. But note the subtle part: even a human per *ten* processes is a dead end, because the human becomes the single point of failure, the thing the whole pipeline waits on. Every autonomy transition we actually have on record — aviation cockpit crews going from three to two, drone teleoperation giving way to onboard autonomy, safety drivers leaving robotaxis — moved in one direction: *fewer humans per process, and the remaining humans moved from operator to exception-handler.* Not because humans got better, but because the systems did. The trajectory is not speculation; it's the history of every deployed autonomy stack I know of.

So the value is temporary. Every steering point kept beyond its usefulness is a tax on scale. I am not saying "steering is useless." I am saying the honest engineering posture is: **assume the need flattens, build the points so they are trivially removable, and schedule their retirement.** If you assume durability you will be wrong in a specific, expensive way — you'll have a compliance regime, a training program, and a human budget built around a capability floor that has already risen past your assumption.

---

## The Minimal Interaction Points — a Consequence of the Argument, Not an Assumption

Because I argue steering has *short-term, sparse* value, I am obligated to specify what delivers it. Two points. Not three. Not per-action. Two:

**Point 1 — Goal/priority ratification at initialization.** Before a run begins, the responsible human confirms the goal, its priority relative to alternatives, the spend/latency envelope, and the pre-committed abort criteria. This is the front-door judgment. It is cheap because the human is already engaged, and it is the only moment where the values decision genuinely cannot be derived by reasoning. It is also the moment that manufactures accountability — the owner is *named at the door,* which is what accountability actually requires, and this is where I concede the most ground to the other side: **accountability is real, and it is satisfied by goal ownership and audit of telemetry — not re-purchased by an approval click at every step.** Ownership is established at the top. A signature per step is theater, not accountability.

**Point 2 — The off-ramp: a low-friction abort, and an escalation path to it.** One channel, always armed, that lets a human truncate a run the moment cost, trust, or world-state exceeds the pre-committed envelope. It must be a *pull,* never a *push* — the agent does not spam the human; the human pulls when the telemetry says "wrong goal, spending, unbudgeted." The abort criteria were written at Point 1, so the human at the ramp is making a call they were already authorized and prepped to make — recognition cost drops because the decision-worthy envelope was defined in advance. This is the exit-ramp judgment.

Everything else — checkpoint approvals, per-step sign-offs, mid-run "which direction should the search take" — is derived from the goal and must be derived *by the agent,* or it's a rubber stamp. And I want these two points built with a kill switch on *themselves:* the moment run data shows the off-ramp has never been pulled in N thousand runs, retire the ramp and keep the telemetry. The gate should be the first thing to go when the metric says it earned nothing.

---

## The Fatal Failure Mode, and the Condition That Falsifies Me

**The rubber stamp is the fatal failure of my own side's concession.** When a gate exists, people approve what the machine already decided. Skitka, Mosier, and Burdick documented automation bias a quarter century ago — humans over-rely on automation and stop verifying — and every approval system I've built since has confirmed it on real fleets. A steering mechanism that produces ritual approval adds latency without adding quality, which is *worse than none:* it manufactures the *appearance* of oversight while spending the last scarce resource in the system — operator attention — on nothing. Attention is not free. Every ask spends it. Spend it on the front door and the ramp, and spend nothing anywhere else.

**The condition that falsifies my position:** real operational data showing that interaction points, at fleet scale, *reliably* prevent wrong-goal catastrophes that the agent's own self-correction fails to catch — and that the prevention cost (latency + attention + serialization) is lower than the averted loss. If the numbers come back that gates catch failures the agents wouldn't have caught themselves, at a net positive ROI, over a sustained period — I'm wrong, and I'll say so in public. I'm not afraid of the data. What I'm afraid of is the other side's position surviving *without* data, on vibes about "judgment" and "taste" that can't be measured and therefore can't be falsified. Give me the cost-at-failure numbers. Give me the wrong-goal catch rate attributable to the gate. Give me the wait time. Then we're having an engineering conversation, and I'll take whichever side the numbers take.

Until then: steering is a crutch for today's capability. Build it so it is easy to remove when the agent stops needing it — because it will.

> "Every human gate you add is a place where the system waits, and waiting is where value dies. Steering is a crutch for today's capability — build it so it is easy to remove when the agent stops needing it."
