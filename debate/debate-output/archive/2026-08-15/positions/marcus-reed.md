# Position: Steering Is Needed Where It Pays — Which Is Smaller Than You Think and Larger Than Kai Admits

**Panelist:** Marcus Reed — Developer Advocate, Agentic Workflows, LatticeSoft; former operator of agentic code-review pipelines for a 40-engineer org

---

## Let Me Reframe This Before I Argue It

The brief asks whether human steering is needed. That's the wrong unit for my job. I don't decide "is steering needed" once and then build it. I decide, every single day, **which steering is needed, at which moment, in which run, in front of which engineer** — and I'm the one who has to watch whether that engineer actually shows up when the agent asks. I've run the fully-autonomous overnight regime, and I've run the heavily-gated afternoon-review regime, and I've spent years in the middle deciding what gets delegated, what gets kept, and which gates my own team quietly ignores.

Here is what the governance position and the researcher position both assume that I know from experience is false: that a steer happens because the mechanism asks for one. The mechanism asks. The human decides whether to answer. And the human answers only when the ask is cheap, the timing is right, and the answer visibly matters. I've watched every steering mechanism I've ever built decay into ritual without constant attention and timing. So let me give you the operator's honest answer, because it is not the one either side wants to hear.

**Steering is needed at the moments it pays. That is a smaller set than the governance and researcher positions assume, and a larger set than the autonomy advocate admits.** The value is a function of *timing and boundedness*, not *volume*. A steer at the right moment — "that's the wrong direction, re-scope it" — saves hours. A steer at the wrong moment is abandoned, and worse, it breeds mistrust in every steer after it. That's the whole argument. Let me defend it.

---

## Is Steering Needed? Yes — Where It Pays

Let me be as concrete as my profile demands. In my org, a mid-size software team, we run a fleet of coding agents. The fully autonomous overnight regime: you come in the morning and the agent has opened a PR that "refactors" forty files in the direction the ticket technically authorized but the team never intended — the ticket said "extract this service," and the agent confidently extracted the wrong boundary, then spent the night propagating it. You spend the morning unwinding it, and the unwind costs more than the feature would have. That's the wrong-goal failure the brief describes, and I've lived it, and it is not rare, and it gets *more* expensive as the agents get faster, because they travel further down the wrong road before anyone notices.

The heavily-gated afternoon-review regime: the team is in flow — they're shipping — and the dashboard pings them to approve step 14 of a run that is going fine. They click. They stop reading. Three weeks later they're approving everything on the first keystroke, because the gate has never once been wrong, and they've learned the system is fake. That's the ritual, and it's worse than the overnight regime, because it teaches the operators that oversight is theater, and when the one real judgment moment finally arrives, they're already trained to rubber-stamp it.

Both regimes fail. The middle is where I live, and the middle is not a compromise — it is a different quantity. The question is not *how much* steering. The question is *when does a human decision change the run*.

**Steering is needed where the following three conditions all hold, and nowhere else:**

1. **There is a direction decision, not a derived decision.** "Which way should this go" — whether the goal is still the right goal, whether the premise the plan stands on has failed, whether we should re-scope before spending more — is a values decision that lives outside the model's inputs. I agree with Maya here up to a point: the agent cannot certify the objective it is optimizing, because the values the objective encodes belong to the principal, not the model. But I'm an operator, so let me say it the way it shows up on my desk: the agent is confident about *what it's doing* and uninformative about *whether that's what we should be doing*, and the second question is the one that burns the money.

2. **It's early.** Before wasted execution. The value of a steer is roughly inverse to how far the run has already traveled. A direction correction at hour one is worth hours; the same correction at hour nine is worth nothing — you're just cleaning up. This is why "ask early" is not a stylistic preference in my runbooks, it is the value function itself.

3. **A human will actually show up and actually decide.** This is the condition every other position on this panel skips, and it's the one I'm uniquely qualified to state. It doesn't matter how theoretically valuable a steering moment is if the engineer who must answer is in flow, the ask costs five minutes of context-switching, and the answer is ignored on retry. I have built gates that were *correct* on paper and dead on arrival in practice because the ask was too expensive for the moment it came at. Steering is only needed where it *gets used.*

Now, what is *not* on that list? Approving each step. Validating each intermediate output. Clearing each checkpoint. Choosing "which direction the search should take" at every fork. Those are derived decisions — they follow from the goal by reasoning, and reasoning is exactly the thing that's getting better every quarter. I side with Kai on this ground and I'll say it loudly: a steer that ratifies work that would happen identically anyway is worth nothing, and worse, it's noise the operator learns to dismiss. Every ratifying steer I've ever shipped taught my team to ignore the next steer. The moment a steer is a rubber stamp, it's not neutral — it's *poison*, because it contaminates the one steer later that would have mattered.

So: needed? Yes. Now, and — I'll argue — in the near future. But the operative word in my position is *where*. Needed at the front door, at the premise-failure moment, and at the off-ramp. Needed nowhere in between.

---

## The Concrete Value, and How You'd Observe It

I want to be precise about the value claim, because I'm the panelist who's genuinely split, and a split panelist doesn't get to hand-wave. The value of steering, where it pays, is **saved effort and avoided rework.** That's it. Not better taste, not moral calibration, not "judgment as a good in itself." I measure steering the way I measure everything else: did the run go somewhere it wouldn't have gone, and did that save us more than the ask cost?

It is observable, and here's how I'd put it on the board:

**1. Rework-avoidance.** The direct measure: runs whose direction changed at a steering moment versus the rework the team would have absorbed. I track it as time-to-correction — the elapsed run-time between "direction chosen" and "direction corrected." A steer that catches a wrong direction at hour one is worth (hours eight through forty) of unwinding. The metric is the *difference* between where the run went after the steer and where it was going before — and I record both, because the counterfactual is the whole point. Maya calls this steer-attribution; I just call it the diff between the two run histories. Every steer that doesn't produce a diff is, by definition, a ratify, and it goes into the ritual bucket, not the value bucket.

**2. Re-scope rate.** The fraction of runs whose goal, priority, or load-bearing premise got revised, re-prioritized, or abandoned at a steering moment. Nonzero and attributable is the whole claim. It doesn't take many — one redirected multi-thousand-dollar wrong-goal run pays for a year of calibration, and I have the invoices to prove it.

**3. The runtime of the ask.** My value claim has a cost side, and unlike some of my colleagues I'm not going to pretend it doesn't exist. Every steer costs the engineer's attention, the context-switch, and the wall-clock wait. So the observable I insist on is **ask cost**: how long between the agent surfacing a decision and the human answering, and how much attention it consumed. If rework-avoided minus ask-cost is not positive, my position is dead on this metric alone, and I'm not interested in defending it.

**4. Steer-response rate.** The fraction of asks that actually get answered — and answered *differently* than the agent's own recommendation. If the response rate collapses, the mechanism has decayed into ritual, and I want that number visible before the trust is. This is the metric that catches my own failure mode, and I'll come back to it.

What I will *not* claim: that steering makes outputs better in some unmeasurable aesthetic sense, or that a human signature per step adds quality. That's the value the other side can't show me a number for, and I'm not carrying it.

---

## Durable or Temporary? Split — And the Split Is the Point

This is the question where I think both Kai and Maya are half right, and where the honest answer is uncomfortable for both.

**On the judgment bits: durable.** I have run agents long enough to have no reason to believe a model will ever stop choosing the wrong direction sometimes. Not because of a permanent capability ceiling — Kai's trajectory is real and I concede it — but because the *inputs to the decision change.* The world is underspecified. Tickets are half-written. The CEO's priorities shift between Friday and Monday. A premise that held at kickoff — the integration contract, the budget envelope, the assumption that the legacy service was safe to touch — fails at hour six in a way the model cannot evaluate, because the premise's meaning was authored by a human whose intent the model can only infer. Capability growth makes agents *better optimizers of a wrong goal* — more thorough, more persuasive in their confidence, faster to scale the error. I have watched this happen with every release, not in theory but in the morning-after diffs. The wrong-direction rate may shrink; I see no mechanism, and no release cadence, that takes it to zero, because the goal-worthiness question is upstream of the model and never enters its inputs. On this, Maya is right, and her reasoning is better than mine.

**On the mechanism: it must not be permanent.** And here Kai is right, and more right than he gets credit for from the governance side. A steering *gate* — a mandatory checkpoint that halts the process and demands an answer — is a legacy mechanism the moment it ships. It serializes. It floods. It decays into ritual. I have retired three of them, and Kai has retired three of his. The thing that must be permanent is not the gate; it is the *ask* — rare, early, bounded, cheap — and the asks must be renegotiated constantly. Ask rarely. Ask early. Ask bounded. And keep the asks so cheap they never become ritual. The moment the mechanism outlives the value it was built to capture, it starts eating the very attention that makes the real steers possible.

So my answer to "durable or temporary" is: **the need is durable, and the surface is not.** The kind of moment that deserves a human shifts as capability grows. Today, some of the surface is "which direction should the search take" — and Kai is right that that's beam search's job and it's retiring fast. What retires slower, and maybe never, is the goal-worthiness and premise-failure surface — "is this still the right thing to be doing, given what changed." The surface shrinks and migrates toward judgment; it does not vanish. I want the mechanism designed so that as the surface migrates, the interaction points migrate with it — never ossifying into a permanent gate, never being defended for its own sake. Build the steering so it is easy to *move*, because the only thing I am confident is permanent is that the map of where steering pays will keep changing.

---

## The Minimal Interaction Points — Derived, Not Assumed

I argued that steering pays where three conditions hold: a direction decision, early, and one a human will actually answer. The minimal set follows directly. Three points. Not four. Not per-step. Three.

**Point 1 — The front door: a cheap pre-commitment, not a write-up.** Before the run, the responsible human records the goal, its priority against alternatives, the spend envelope, and the load-bearing premises — the things that, if they change, mean the goal is no longer the right goal. I insist on one operational constraint that my own side's theorists keep missing: **this must be a two-minute structured fill, not a calibration essay.** A long write-up will be skipped. I know this because I've built the long write-up and watched it be skipped. The front door is where the values decision genuinely happens — it is the cheapest moment in the run because the human is already engaged — and it is what makes everything after it possible: you cannot notice a premise you never recorded. This is also where ownership gets manufactured, which is where I concede the most ground to Elena: the owner is named at the door, and that's what accountability actually requires — not a signature per step. But I will fight any version of this that turns into a fifteen-minute form, because the form is the ritual in disguise.

**Point 2 — The early direction-check: ask only when the run is about to commit to something big on a broken premise.** The agent surfaces, at a calibrated threshold — a recorded premise failing, an irreversible step about to be taken, spend blowing the envelope — not "please confirm what I'm about to do" but *"here's where I'm heading, here's the assumption that changed, here's what each direction costs, re-scope or hold."* This is a judgment moment, not an endorsement moment: the agent's confidence about the direction is uninformative exactly when a premise has failed, because the premise's meaning lives with the human. It must be *early* — before wasted execution, which is where the value lives — and it must be *rare*, tuned from data, because over-ask floods the human and under-ask lets confident agents commit to wrong goals, and I've seen both and both are documented. The frequency knob is an empirical one, and turning it is the owner's job.

**Point 3 — The off-ramp: an always-armed abort, a pull not a push.** One channel, no threshold, that lets a human truncate a run the moment cost, trust, or world-state exceeds the envelope they wrote at the front door. The agent never spams the human; the human pulls when the telemetry says "wrong goal, spending, unbudgeted." Because the criteria were written at Point 1, the human at the ramp is making a call they were already authorized and prepped to make — recognition cost drops because the decision-worthy envelope was defined in advance. And I want this one built with a kill switch on itself, the same way Kai wants his: the moment the telemetry shows the ramp has never been pulled in N thousand runs, retire it and keep the telemetry. The gate should be the first thing to go when the metric says it earned nothing.

What my argument does *not* license, stated as loudly as what it does: per-step approvals, checkpoint sign-offs, mid-run output validation, "which direction should the search take" at every fork — none of these follow from my three conditions, because none of them are early, none of them are direction decisions, and every one of them ratifies. A steer that ratifies is worth nothing, and I would rather ship no steering at all than ship steering that trains my team to ignore it.

---

## The Fatal Failure Mode, and What Would Falsify Me

**The failure mode of my own position is ritual.** A gate that must be answered gets rubber-stamped. And rubber-stamped approval is worse than no approval, because it teaches the operator the system is fake — and once an operator learns the system is fake, they stop showing up for the real moments too. Every mechanism I've watched die died of this, not of capability. It dies because the ask got too expensive, or too frequent, or too obviously inconsequential, and the human who was once in flow started clicking without reading. The safeguards are exactly my three operational rules: ask rarely, ask early, ask bounded. And one more that I cannot say often enough: **the default must be safe and visible.** If the agent asks and no human answers, what happens? If the default is "agent proceeds anyway," the ask is fake and the team knows it. If the default is a safe, visible pause that respects the envelope the owner set at the front door, the ask is honest — and an honest pause that occasionally costs us an hour is a bargain compared to a fake gate that costs us the team's attention forever.

**The condition that would falsify me is operational, and I am genuinely happy to be falsified, because I've told you I'm split.** Two findings, either of which kills my position:

1. **The steers don't change runs.** Over a sustained period, the re-scope rate at my direction-check points is zero, and the recorded diffs between steered and unsteered trajectories show the early steers saved nothing — the runs would have gone where they went anyway. If the steers ratify, my value claim is empty, and I'll retire the mechanism myself. I have runbooks for exactly this, and I follow them.

2. **The capability curve eats the surface faster than the world generates it.** If a purely autonomous policy with self-generated goal-checking matches human-steered outcomes on goal-correctness — the access gap closes, and the premise failures turn out to have been decidable from inside the model after all — then my "judgment bits are durable" claim is wrong, and I'll concede it in public, the way I've conceded that beam-search steering belongs to the agent.

But I'll demand one thing before accepting either finding, and it's the same thing I demand of myself: **measure the steering, not the ritual.** Don't show me a per-step approval gate failing and call it the death of steering — that gate is endorsement, it's exactly the mechanism I said was poison, and it can fail without touching my position. Show me the direction-checks, the re-scopes, the off-ramps. Show me the runs that went somewhere they wouldn't have gone because a human showed up early with judgment. Those are the only numbers that can move me, because those are the only numbers that describe what I actually ship.

---

I am the panelist who has seen steering save hours and seen it decay into ritual, and both experiences are true, and that is the point. Steering is needed exactly where it pays: at a direction decision, early, where a human will actually answer. The judgment bits look durable — I have no reason to think a model stops choosing wrong directions sometimes. The mechanism must not be permanent — ask rarely, ask early, ask bounded, and keep the asks cheap enough that they never become ritual. And I will happily retire every interaction point I just argued for the day the telemetry says it earned nothing, because I have built and buried enough of them to know the difference between a mechanism and a monument.

> "Steering is needed exactly where it pays — a steer that changes direction early is worth hours, a steer that ratifies is worth nothing. Ask rarely, ask early, ask bounded. Everything else is a mechanism decaying into ritual."
