# Position: Elena Petrova — Governance & Accountability Lead

**On the question:** *Is human steering needed in agentic processes — now and in the near future — and what value does it provide?*

I am not going to pretend I am arguing the same question the engineers are. The brief frames this as a choice between two claims: that steering is needed because unsupervised agents optimize confidently toward the wrong goal at scale (Claim A), and that steering is a stopgap whose value evaporates as capability improves (Claim B). I think both claims are about the wrong axis. They are arguing about *outcomes*. I am arguing about *ownership*.

So let me say my conclusion plainly, then defend it.

**Steering is needed now and in the near future. Its value is not improved decision quality — it is the manufacture of an owner. And that value does not erode as agents get smarter; it is capability-independent, because it is fixed by law and by the structure of accountability — not by model performance.**

The question nobody in this debate is allowed to dodge: when an agent acts, who is accountable? Not "who gets blamed" — who *is* accountable, in a sense that can be demonstrated, explained, and reversed after the fact. My entire career is building the evidence that lets an audit committee, a regulator, or a court answer that question. And I can tell you with complete confidence: no model release closes that question. The question of who is accountable when an agent acts is answered by the design of the process, not by the intelligence of the model inside it.

---

## 1. Is steering needed at all?

Let me first concede what Claim B gets right, because it is mostly right. Planning, self-correction, and introspection improve every quarter. The judgment gap that Claim A leans on — *is the goal still the right goal, which direction should the search take* — will narrow, and I do not want to build my case on the fragility of a model being too dumb to know what it wants. If I argued "steering is needed because agents optimize for the wrong goal," then the honest rebuttal is "wait three releases and the gap closes," and I would lose.

So I do not argue that. I argue something Claim B never engages: **a process no one steers has no owner, and the law does not recognize ownerless agents.**

Consider what the brief's own "case for steering" concedes even in its account of the other side. Claim A says a single steer early costs little and detection after the fact costs everything. I will say something more precise: detection after the fact is not merely expensive — for a regulated institution it is *late*, in a way that no engineering capability can fix. By the time you have detected, you have already acted. And the law has already decided what happens to consequential actions that no named person authorized: they are *nobody's*. GDPR Article 22 prohibits solely automated decision-making with legal or similarly significant effects. The EU AI Act's human-oversight provisions and the high-risk categories exist for exactly this reason. SR 11-7 — the model-risk management standard I have spent years operationalizing — requires effective challenge, meaning a named set of people must be able to explain and if necessary override what the model does. The UK's Senior Managers & Certification Regime exists because the UK decided, after a financial crisis, that a process with a decision but no attributable manager is a process that produced a failure with no one answerable for it. BCBS 239 requires that the data trail supporting a decision be reconstructable — "who decided, on what basis, when, with what authority."

These are not suggestions. They are capability-independent requirements. You cannot outperform them with a better model. You cannot self-correct your way past a legal obligation. And critically — the point Claim B misses entirely — **they do not become less relevant as agents get more capable; they become more relevant, because more capable agents take more consequential actions per unit of time, on a larger surface, with greater confidence.**

So: is steering needed at all? Yes. Not because the human is smarter than the agent — in many domains they will not be, and I will happily admit that. But because the human is the only entity the law can hold accountable, and accountability must be manufactured, deliberately, by design. An agent cannot inherit accountability from its own competence. It can only inherit it from an attributable human decision.

---

## 2. What value does steering concretely provide, and how is that value observable?

The value is not "better decisions." I will not defend that; the engineers on this panel can win that argument honestly, and I do not need it. The value is **the existence of a reconstructable, challengeable decision trail that ends in a named person.**

Concretely, steering provides:

- **Attribution.** A record of who authorized what, on what basis, and when. Not a log of the agent's activity — a log of *ownership acts*.
- **Explanation under challenge.** When a regulator or a court asks "why did this happen," steering provides the answer that "the model did it" cannot provide: a chain of human authorization decisions that the questioner can interrogate.
- **Reversal.** A defined mechanism by which an action can be un-done or stopped by someone with the authority to un-do or stop it. An owner is someone who can say stop.
- **Effective challenge.** The SR 11-7 requirement that there be someone able and required to question the model's output rather than accept it — which is the exact opposite of rubber-stamping, and I will come back to this.
- **Regulatory standing.** The ability to operate at all in domains where operating without human oversight is simply not permitted.

How is this observable? Not through a dashboard of "human involvement hours." It is observable the way all accountability is observable: **after an incident.** The value is observable when an incident happens and the organization can answer four questions — *who decided, on what basis, when, with what authority* — with a record that survives reconstruction, and when the regulator accepts that answer. It is observable in the difference between a bank that gets through a model-risk examination and one that does not. It is observable in the difference between an AI action that gets reversed and one that cannot be reversed because no one can be shown to have authority over it.

I want to be direct about what this means for the debate. The engineers will say: "measure the value of steering by outcome quality." I say: measure it by whether an act has an owner. Those are different metrics, and mine does not go down as the model improves.

---

## 3. Is that value durable, or is it a stopgap until capability catches up?

This is the question that separates the honest from the wishful, and I want to reason it out carefully rather than assert it.

Claim B's entire structure is: *steering is a performance mechanism; performance mechanisms get superseded by better performance; therefore steering is a crutch.* If steering were a performance mechanism, they would be right, and I would concede. But it is not. The value I have described — attribution, reversal, challenge, regulatory standing — does not come from the human being the better reasoner in the loop. It comes from the human being *the accountable entity in the loop.* And the accountable entity is fixed by law, not by capability.

Let me state the strongest version of my position and then the honest limit of it.

The strong version: ownership is not a capability that agents are converging on. There is no "reasoning ability" level at which a process becomes self-owning. Ownership is a legal and social status assigned to persons and entities, not a threshold of intelligence. The EU AI Act does not say "human oversight until models reach 90th-percentile reasoning." It says human oversight, full stop, for high-risk systems. GDPR Article 22 does not sunset. SR 11-7 does not contain a clause that says "effective challenge no longer required once model accuracy exceeds X." These are stable requirements because accountability is a relationship the law maintains, not a problem the models are solving.

Which is why the capability trajectory — which Claim B is so confident about — actually *strengthens* my position rather than weakening it. The more capable the agent, the more it can be safely entrusted with, the more consequential the actions it takes, and therefore the larger the surface over which an owner must exist. Faster agents are not a reason to need fewer owners. They are a reason the ownership function must be *designed in* — because the actions being attributed are higher-stakes and harder to reverse. The brief's own words: "Left unsupervised, they optimize for the wrong goal confidently, at scale, before anyone notices." That is not a problem capability solves — it is a problem capability *compounds.* A faster, more capable agent does not stop being wrong about the goal; it gets wrong about the goal faster, with more confidence, across more processes. Steering is not a bottleneck waiting to be optimized away; it is the safety rail that makes the speed usable.

Now the honest limit. I am not claiming the value is durable *forever, under all legal regimes.* The durability rests on a specific legal-political fact: that consequential decisions must trace to a human or corporate owner. If that fact changes — if agents are granted legal personhood, or liability is shifted wholesale to system providers in a way that dissolves the need for in-process ownership — then part of my argument erodes. But note what that means: it means my position would be falsified by a *change in law*, not by a change in model capability. And in the near future the brief asks about — the horizon on which these systems are being deployed and regulated — the law is moving in exactly the opposite direction, toward *more* explicit human-oversight requirements, not fewer. So the value I defend is durable on every timescale this debate cares about.

Let me put it in the terms the brief uses. Claim B calls steering a stopgap, a crutch until capability catches up. I say: the crutch metaphor is wrong, because a crutch is a substitute for a function the user cannot yet perform. But there is no function of the agent that human accountability is substituting for. No level of agent capability produces "this act is owned by a named person who can be held to account and can reverse it." That is not a cognitive function; it is an institutional one. Autonomy without a decision trail is velocity with no owner — and the question of who is accountable when the agent acts never expires, because it is not a question about the agent.

---

## 4. If steering is justified: the minimal interaction points that deliver the value

I am on record — in my own profile and now here — as opposed to per-step approval gates. I have watched those flood and fail. When every step requires a human nod, the human stops being a judge and becomes a notary, and the entire mechanism collapses into the rubber-stamping that Claim B correctly warns about. So let me derive the minimal set *from my argument*, not from a governance checklist.

My argument has one core requirement: *a consequential agent action must trace to a named, challengeable human decision.* That gives me exactly three interaction points, and no more.

**Point 1 — The mandate.** At the initiation of an agentic process, a named accountable person authorizes the objective: the goal, the boundaries, the constraints, the authority limits, and the definition of "consequential" for this process. This is the ownership act that makes everything downstream attributable. It is cheap — it happens once per process, not per step — and it is the thing SR 11-7 means by governance of the model before it is used. Without it, no later record can answer "on what basis did anyone authorize this."

**Point 2 — The exception/escalation trigger.** The agent escalates, and only escalates, when it hits something pre-defined as beyond its mandate: a boundary, an uncertainty threshold, an unforeseen condition, a consequential decision. This is the interaction point that makes the brief's own "recognition, not attention" insight operational. The failure mode we saw in computer-use oversight was not that humans lacked control — it was that humans did not recognize a moment as decision-worthy. The steering point does not exist to let the human check the agent's work; it exists to make the decision-worthy moments *visible and named* before the agent acts on them. Escalation is where ownership is exercised in time.

**Point 3 — The reaffirmation (effective challenge).** A periodic, explicitly non-routine review in which the owner is required to re-authorize or revise the mandate — or to stop the process. This is the difference between my steering and rubber-stamping. Rubber-stamping is approving *what the agent already did.* Effective challenge is being required to *re-examine whether the mandate itself is still right* — which is a judgment that cannot be delegated to the agent, because it is the judgment of whether the goal remains the goal. It is also the artifact that survives audit: a dated record of a named person looking at the mandate and deciding it still holds.

That is the whole set. One act at the start, one at moments of exception, one at intervals of challenge. No per-step gates. The minimal set follows directly from the single requirement of my argument — attribution of consequential action — and I have refused every interaction point that does not manufacture ownership. A human checking every step manufactures nothing; it is ceremony. A human authorizing the mandate, being pulled in at exceptions, and being required to re-challenge the mandate manufactures an owner.

And yes — this scales. Because the interaction points are attached to *consequential moments*, not to processes, one owner can hold responsibility for a fleet of agents by owning their mandates, their escalation boundaries, and their periodic reviews. The "human per process is an architectural dead end" objection assumes per-process steering. I am proposing per-owner steering. Those are different architectures, and mine does not die at fleet scale.

---

## 5. The key failure mode that would falsify my position

I have to name the condition under which I am wrong, because a position that cannot be falsified is not an argument, it is a posture. And my position has a specific, honest one.

**My position is falsified if in-time steering turns out to be unnecessary for ownership — that is, if after-the-fact audit alone, with no in-time interaction, can produce a record that answers the four questions — who decided, on what basis, when, with what authority — at equal fidelity, and produce equal reversal capability and equal regulatory acceptance.**

This is the strongest attack on me, and I want to take it seriously rather than wave it away. There is a live empirical question here: is ownership *manufactured by the in-time authorization act*, or can it be *reconstructed afterward* from an agent's logs by an auditor who steps in only after the fact? If the record alone suffices — if an ex-post examiner can attribute, explain, and reverse as well as a human who was there — then my three interaction points are stronger than my argument requires, and the honest conclusion is that steering should shrink toward zero. My profile says I can be moved on *how much* steering is needed. I am genuinely moved by this. The design-of-oversight literature on attribution and reversal is exactly the literature that would tell us whether in-time interaction is load-bearing or whether the record is enough.

The one thing I will not concede is the *zero* version — the position that a process with no owner can be accountable. Because the empirical question only says something about whether the interaction must be in-time or can be after-the-fact. It does not say anything about whether the interaction can be *absent.* An owner is a requirement, not an optimization. So my falsification condition is: if ex-post reconstruction is shown to deliver attribution, explanation, and reversal at equal fidelity — then my minimal set is one (or two, or three) interaction points too many, and I will trim it accordingly. But the record will still exist, and the owner will still exist, because the record without an owner is still a record of nobody's decision.

**The second failure mode is the one I fear more, and it is the governance one: false assurance.** If my interaction points degrade into ceremony — the mandate signed without reading, escalations routed to a queue nobody acts on, reaffirmation meetings that approve whatever is placed in front of them — then I have built steering that adds latency and adds no ownership. That is strictly worse than no steering, because it manufactures the *appearance* of accountability while delivering none, and it will be found out exactly at the worst possible moment. This is why I keep saying the interaction point must leave a reconstructable record, and why the reaffirmation point must be effective challenge and not approval. If the committee that reads my position takes one thing from it, it should be this: **steering that leaves no record is worse than no steering, because it is a lie told in the shape of a control.** The design test for every interaction point I proposed is not "did the human sign," it is "would this record survive a regulator's question about who decided, on what basis, when, and with what authority."

---

## Conclusion

The brief asks whether steering is needed, what value it provides, and whether that value is durable. My answer, in three sentences:

Steering is needed because a process no one steers has no owner, and the law — GDPR Article 22, the EU AI Act's oversight provisions, SR 11-7's effective challenge, the Senior Managers regime, BCBS 239's reconstructability — does not recognize ownerless consequential action. Its value is not better decisions; it is the durable, reconstructable, challengeable record of *who decided, on what basis, when, and with what authority* — observable the only way accountability ever is, after the incident. And that value is durable not because human judgment outruns the agent — it will not, and I accept that — but because ownership is a legal status, not a capability, and no model release can make a process self-owning.

The engineers on this panel will tell you the models are getting better every quarter and the bottleneck is human attention. They are right about the models, and they are wrong about what I am defending. I am not defending a bottleneck. I am defending the only mechanism that turns agent velocity into an owned act. Speed is easy to build. Owners are not.
