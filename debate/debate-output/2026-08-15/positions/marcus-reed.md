# Human Steering in Agentic Processes — Position of Marcus Reed

**Position in one line: Claim A, properly scoped. Human steering is needed now and stays needed in the near future — but only as direction-setting, and only if it stays rare and early. Everything else we call steering is a stopgap that capability will absorb, and should be absorbed, because the leftover version of it decays into ritual and burns the one resource the real thing depends on: a busy engineer's attention and trust.**

Before anything else, my test. Every claim in this document is judged against it, because it's the only one that survives contact with a real shop:

> Does the steering make the *work* better, and will a busy engineer actually show up when the agent asks?

I have run both extremes. Overnight fleets running fully autonomous, waking up to whatever they produced. Afternoon sessions where a senior engineer sat on every pull request the agent generated. I've watched steering save hours, and I've watched it decay into ritual — and both happened with the same well-meaning team and the same well-built tooling. The difference was never the tooling. It was whether the interaction was steering or theater.

## 1. The fault line this debate keeps missing

Both claims in the brief treat "steering" as a single thing. Claim A argues for it wholesale. Claim B argues against it wholesale. Both are wrong, and the reason is that steering is not one mechanism — it's two, with opposite economics.

My own runbooks draw a line I have never seen contradicted:

- **Direction decisions** set the goal: what we're trying to do, whether it's still worth doing, who it's for, what "done" means, which constraints bind and which don't. These are cheap to answer and expensive to get wrong.
- **Derived decisions** are everything downstream: which plan, which library, which retry strategy, which fix. These are *ratifiable* — you can check them against the goal mechanically, with review, or with a better model. They are expensive to answer and cheap to get wrong.

Steering is worth something exactly where it operates on the first class and stops touching the second. A steer that changes direction early is worth hours. A steer that ratifies a derived decision is worth nothing — and it isn't merely worthless, it's corrosive, because it trains the human to rubber-stamp. Automation bias is real. I've measured it in my own teams: the second an engineer is asked to approve what a machine already decided, the approval rate climbs toward 100% and the attention climbs toward zero, and within weeks the agent's messages go unread.

So the real question of this debate is not "is steering needed." It's "which of the two things we call steering is needed." My answer commits to Claim A but only for the direction class, and concedes Claim B completely for the derived class.

## 2. Is it needed? Yes — but only where it changes direction

Now, today: yes. Direction-setting steering is required, and it is required for a reason that has nothing to do with model quality and therefore won't be fixed by model quality.

Read Claim A's strongest sentence again: *no amount of model capability produces the decision that the goal is the right goal — that is a human value judgment.* I agree with it entirely, and I'll go further than the brief does, from the operator's seat. The gap at the goal-setting moment is not a reasoning gap. A model does not fail to decide "is this goal worth pursuing" because it isn't smart enough. It fails because *it isn't the one who owns the consequences.* The decision that this feature is worth a quarter of the team's capacity, that this migration is worth the risk, that this ticket is worth killing on a Tuesday — that is an authority decision, not an inference. Capability can't close an authority gap. A better planner doesn't make the plan yours.

And the wrong-goal failure is the expensive failure, exactly as the brief says. I've seen the near-misses: an agent that confidently did the right thing against the wrong target, for eight hours, overnight. The fix was never in the retry logic. It was a five-second answer to a question nobody had asked it early enough. The cost asymmetry is brutal — a single steer early costs minutes; detection after the fact costs days of rework, customer trust, and whatever confidence the team had in delegation at all.

Now the near future: the need doesn't vanish, but the *form* shifts. Better agents will propose goals, propose what's worth pursuing, draft the definition of done. That's fine, and it's progress. But proposing is not owning. The human's interaction migrates from authoring the goal to ratifying it — and I want to be sharp here about why ratifying a *goal* is not the same as ratifying a *plan*. A goal-ratify is still a direction decision, because "yes, this is worth pursuing" encodes values and transfers accountability onto a person. It stays decision-worthy. It stays rare. It stays early. That is why it survives my test while plan-ratification doesn't.

## 3. Where Claim B is right — and the stopgap is real

I'm not going to defend the periphery, and the anti-steering case earns its keep there.

- **Capability trajectory.** Every release narrows the gap on planning, self-correction, introspection. The derived class is a moving target, and designing interaction points around it is building a mechanism for a problem that's being solved elsewhere, faster. Let it go.
- **The bottleneck returns.** Every ratifying gate is a place where the process waits on a human who has better things to do. Context-switching isn't free. Wall-clock delay isn't free. These costs compound exactly as Claim B says — for gates that produce nothing.
- **Rubber-stamping.** I've seen it kill more steering than any other cause. A mechanism whose answer distribution converges on "approved, unread" is worse than absent, because it trains everyone to ignore the agent and it trains the agent's output to drift without a check.
- **Scale.** A human per process is an architectural dead end — agreed, and that's precisely the design I'm *not* defending. I'll return to this, because the direction-versus-derived line dissolves it.

Here's the operator's version of the honest position: the derived-class steering you keep in production today is not a crutch you'll discard someday — it's already dead weight. The capability argument isn't a reason to delay steering; it's a reason to cut the steering you have down to the part that earns its keep. Most gates in real agent systems right now are ratification wearing a costume.

## 4. The value, and how you'd see it

I refuse to argue value I can't observe, so here is exactly what I'd put on a dashboard — the four numbers that separate a steer from theater:

1. **Redirected-before-execution rate.** The fraction of runs where the human's input changed the goal or direction *before* meaningful work was done. This is the direct measurement of the "value inversely proportional to distance traveled" principle. A steer that lands after eight hours of execution doesn't count as value; it counts as an autopsy.
2. **Human-disagrees-with-agent rate.** For every steer, does the human answer differently than the agent's own recommendation? If this number is ~0%, the mechanism is carrying no information and is costing attention — kill it. If it's meaningfully above zero, steering is adding something the agent genuinely didn't have: the human's values, context, or taste. This is the number that proves whether steering is judgment or rubber-stamp.
3. **Response rate over time.** Will the busy engineer actually show up when the agent asks — and keep showing up in week six, not just week one? Monotone decay here is the ritual signature. It tells me the mechanism has already failed my test.
4. **Rework avoided, net of wait cost.** Hours of execution not spent against the wrong goal, attributable to the steer, *minus* the wall-clock and attention the steer cost. If the net is not positive, the mechanism is noise, and I don't care which side of the debate it serves.

Note what this dashboard *doesn't* include: audit-trail counts, approval throughput, governance coverage. I'm the panelist who weighs evidence he can see today over the incident he hasn't had yet — my colleagues who push accountability will rightly call this my blind spot. Fine. I'll answer it directly: accountability is not a reason to *create* steering points. It's a reason that the few steering points which already carry real decisions must be *owned* by a named human. Governance follows the decisions; it doesn't manufacture them. A process with no real decision points shouldn't get fake ones so the audit log looks full — that's how you get a compliance artifact and a dead mechanism at the same time.

## 5. Durable, not a stopgap — for the narrow class only

Claim B's core prediction — capability closes the gap, steering becomes a crutch — is true for the derived class and false for the direction class, and the distinction is the whole argument.

The direction decision is durable because it isn't a capability problem. As long as the organization assigns goals to a person, that person remains structurally required at the goal-set. The only way steering's durable core disappears is if the organization decides the agent *may hold its own goals* — and that is not a capability decision, it's a governance decision that no model's release notes can make for you. Bet on capability all you want; the goal still has an owner.

But I'll add the honest wrinkle, because "durable" can be a dodge. The durable part is the *class* of interaction — direction-setting — not the current form of it. Ten years from now the human will ratify a proposed goal rather than author one from scratch. Five years from now the drift-interrupt below may be handled by the agent catching its own goal-drift. The interaction survives; its surface area shrinks. That's not stopgap logic — that's the value *concentrating* where it actually lives. A stopgap is something you keep because capability hasn't caught up. This is something you keep because capability can't catch up to it.

And on scale, Claim B's strongest architectural point: you don't steer a fleet of agents. You steer the *goal* a fleet executes against. One goal, one direction decision, however many agents run under it. "A human per process" is only a dead end if you've designed steering as per-process ratification — which is the design I've already told you to delete. Direction-steering scales to a human per goal, and that's a number that stays human-shaped no matter how the fleet grows.

## 6. The minimal interaction points — derived, not assumed

These follow directly from the argument, so I'm not free to add or subtract them by taste. Steering pays exactly where it changes direction before wasted execution (section 1), direction is fixed at the goal and decays as distance traveled grows (section 2), and anything routine decays to rubber-stamp (sections 3–4). From those three premises, the only interaction points that can clear my cost test are two:

1. **The goal set-and-confirm.** At delegation — or the moment the goal changes — the agent proposes what it will do, for whom, what "done" means, and which constraints bind, and the human confirms it or redirects. This is the direction steer. It is folded into the moment of delegation, so the human is already present and wall-clock cost is near zero; and it is once per goal, not once per step, so it stays rare. This is the one steer I'd call required.

2. **The drift interrupt — event-triggered, never routine.** Mid-run, the agent may *only* pull a human in when it detects something the goal didn't cover: the goal looks unsatisfiable, the run is about to blow a stated bound, or the problem has drifted off the agreed target. The human doesn't approve the routine path; they get called only at the moment the brief calls decision-worthy. I endorse the brief's recognition point from my own runbooks — the failures were almost never lack of control, they were the agent never surfacing the moment as decision-worthy. This interrupt is what makes that visible. It stays rare by design; if it's firing often, the goal-set in point 1 was sloppy, and you fix the goal, not the mechanism.

Everything else — step approval, plan ratification, per-change review gates — is ratifiable, and per my own argument it must be automated, not gated. Keeping it as a gate is how steering dies. I want to be explicit that this is a *consequence* of the position, not a wish: if steering's value is direction-changing and early, then every interaction that can't change direction is cost without value, and leaving it installed is actively worse than removing it, because it trains the human to stop showing up for the two that matter.

## 7. What would falsify me

My position has one honest failure condition, and it's the same condition that would prove Claim B wholesale:

**Direction-setting is itself ratifiable — the goal decision reduces to a checkable spec, and a better agent, un-steered, produces the same or better outcomes on the same fleet.**

Concretely, I'd consider myself wrong if, on a fleet where I run my two interaction points, the wrong-goal rework number stays flat *and* the human's disagreement rate collapses to zero *and* an equivalent fleet with no human gate at all — just a substantially better planner and a written verification spec — matches or beats us on the same metrics. If the goal decision can be encoded as a mechanical check against a higher-order utility or an invariant a human writes once, then the direction class collapses into the derived class, my two points become ritual, and Claim B wins. That's the test. Run it, and I'll update.

The weaker falsifier, the one I watch for week to week: engineers rubber-stamping even the goal-set. A goal-confirm whose answers are always "yes, proceed" means the goal was never actually decision-worthy at that moment — the process didn't need that interaction, and I've let my own mechanism lie to me. A steer that stops changing direction is a stopgap by definition. The moment I see it, I cut it.

## 8. Close

I came into this genuinely split, and I'll leave you with the split resolved on evidence, not affiliation. The anti-steering case is right about the periphery and wrong about the core. The pro-steering case is right about the core and wrong to defend the periphery. Both sides lost sight of the actual economics because both insisted on treating steering as one thing.

Steering is worth something exactly where it pays — a steer that changes direction early is worth hours, a steer that ratifies is worth nothing. So build the two points, show me the numbers, and show me the engineer who actually answers. If the engineer stops answering, or the numbers stop moving, tear it out — the stopgap was right about that part. But don't tear out the one interaction that puts the person's hand on the direction before the machine spends the next eight hours going somewhere they didn't choose. That's not a crutch. That's the whole point of having an agent at all — someone to tell it which way the wind is blowing before it sails.
