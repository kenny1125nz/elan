# Position — Kai Tan (Autonomy Advocate)

## Against Steering's Default Presumption

I'll say what I believe up front, so nobody has to read between the lines: most of what
gets sold as "human steering" is not a decision, it is a delay with a person attached. I
have spent a decade building and then burying exactly these mechanisms. On a logistics
platform I ran thousands of agents overnight, unattended, and every human-in-the-loop
gate I added did three things in sequence: it slowed a release, it woke someone up, and
it was overridden on retry. The override rate was the tell. People were not steering —
they were clicking through a checkpoint the machine had already passed. When you build
the retry logic that bypasses the human, you learn what the human was actually adding,
and the answer is usually nothing.

So I come at the question carrying the opposite burden from my opponents. They get to
assert that judgment, accountability, and "making moments visible" justify interaction
points, and I get to demand that every claimed value be shown in the terms I can measure:
latency added per steer, attention consumed per steer, and the number of steers that
actually changed an outcome. The brief's Claim B has the stronger prior. Let me say why,
then concede what I am forced to concede.

## Why Most Steering Fails to Earn Its Keep

The brief's case *for* steering leans on four pillars. Three of them collapse under their
own weight.

**"Relentless execution against a wrong goal" is a real failure mode, but it is not an
argument for per-process gates.** A gate at step three of forty does not catch the wrong
goal — the goal was set at step zero, before any gate was reached. Every approval gate
I've built sat downstream of the actual decision, rubber-stamping a goal that had already
been chosen. The failure the brief describes is real, but the mechanism it prescribes does
not intercept it.

**"Attention is not the constraint — recognition is."** I read the computer-use oversight
studies the same way Claim A does: humans fail to intervene because they don't recognize
the moment as decision-worthy. But that finding cuts against steering, not for it. If the
problem is that humans cannot tell a decision-worthy moment from a routine one, then
asking them to review more, more often, is prescribing the exact disease it claims to
cure. What the evidence actually suggests is that recognition, not attention, is the
scarce resource — and recognition is precisely what the model has when its confidence,
its calibration, and its plan-trajectory diverge. The selective-prediction literature I
read in the pipeline years taught me the same lesson in a different vocabulary: the
model's own confidence is often sufficient to know when it is out of its depth. That is
where I would put my money for the near future — on agents that know they don't know —
rather than on a human watch list.

**Scale arithmetic is fatal.** The brief grants it in the case against and then proceeds
as if it doesn't matter. If the future is fleets of agents — and it is; I build them —
then any per-process human involvement is an architectural dead end. A human per process
is not a design. A human per hundred processes is a queue. The only way steering scales
is if it becomes so rare and so batched that it amortizes to near-zero attention per
process. And if steering has to be nearly free to survive the fleet, then it is already
admitting it has almost nothing to add per unit of work. That is not a defense of
steering. That is a description of its decline.

**The capability trajectory is not a hope, it is an observable.** The brief treats
planning, self-correction, and introspection improvements as a moving target to be
distrusted. I watched the curve in production. Better planners need fewer course
corrections — that is not a prediction, it is a measured fact of my own release cadences.
The number of escalations per thousand agent-runs that survived human override trended
down, quarter over quarter, until the gates were more expensive than the errors they
prevented. That is when I retired them. I did not retire them because I was naive. I
retired them because the data said the judgment gap the gates existed to fill had already
shrunk beneath the cost of the gate itself. Claim B's honest position — steering has at
most a *temporary* value, a crutch until capability catches up — is closer to what I
actually measured than anything in Claim A.

## What I Am Forced to Concede

Now the part where the burden of proof is met, because I promised to be moved, and I
keep my promises.

**The goal-selection moment survives.** Claim A's strongest pillar is the only one that
withstands the attention arithmetic, and it is precisely because it is not a per-step
mechanism. No amount of planning, self-correction, or introspection produces the decision
that *the goal is the right goal*. That is a value judgment — taste, priority, risk
tolerance, which direction the search should take. The agent can tell you whether it can
reach the goal. It cannot tell you whether the goal is worth reaching. That decision is
not derivable from the agent's reasoning about the goal's achievability, because it is
about the goal's desirability, and desirability lives outside the model. I have tested
this against my own intuition and against my own pipelines. When my overnight logistics
agents chose a cheap route that violated a customer contract, the fix was never a better
scheduler. The fix was a human saying "that objective is wrong" — at the top, once,
before the run. This moment is rare, it is upstream, and it is genuinely non-derivable.
I concede it.

**Accountability, if I'm honest about it, is not a checkbox.** My profile is right that I
underestimate this until an incident lands on a regulator's desk. So let me concede it
now, on the record, before the incident. A process no one steered has no owner, and
enterprise adoption and audit do not run on unowned outcomes. There is a class of action
whose cost is irreversible or reputationally severe — a signed contract, a security-
relevant change, a spend above a threshold — where the value is not in improving the
decision but in *attributing* it. The brief says someone must own the outcome. I used to
dismiss that as paper. It is not paper. It is the difference between "the system did it"
and "I did it," and the second is what regulators, courts, and customers actually
enforce. I will not call that a crutch, because no capability improvement makes a
regulator accept a machine's signature.

## The Value, Stated Concretely

So, stripped to its honest minimum, here is the value steering actually provides, and how
you would observe it:

1. **A terminal goal check that catches wrong-goal failure before it runs.** Observable
   as: the number of runs aborted or redirected at the goal gate, divided by total runs,
   multiplied by the cost of the wrong-goal outcome that would otherwise have executed.
   This is a small number of events with a large per-event cost. It is the only steering
   value I know how to price honestly.

2. **Attribution for irreversible and accountability-bearing actions.** Observable as:
   the existence of an attributable decision record for every action a regulator or a
   court or a customer later asks about. This value does not show up in latency or
   throughput curves at all. It shows up in the incident file. It is invisible until the
   moment it is everything.

Everything else — per-step review, mid-run course correction, "making moments visible"
through dense monitoring — I will not pay for, because I have the override logs and the
pager data, and they say the human added latency, not quality.

## Durable or Temporary?

The split answer follows from the split concession.

The goal-selection value is **durable**, but it is durable precisely because it is so
narrow. It does not shrink as agents get smarter, because it does not depend on agent
intelligence at all — it depends on the fact that desirability is not a reasoning
problem. It is the same reason a better autopilot does not remove the need to choose the
destination. Capability growth makes the agent better at the journey; it does nothing for
the choice of destination. This is the one steering moment that survives the fleet,
because it is amortized to once per objective, not once per process.

The mid-run steering value is **temporary**. It is a stopgap by definition: it exists to
compensate for planning and self-correction deficiencies that are being improved every
release, and I measured that compensation shrinking to below the cost of the gate. Anyone
who designs dense interaction points into their architecture today is betting that
capability will not do the thing it is observably doing.

## The Minimal Interaction Points — As a Consequence, Not an Assumption

Because I concede only the terminal goal moment and the attribution moment, the
interaction points I will endorse are the *consequence* of that narrow concession, and
nothing more:

1. **The goal gate.** One interaction at the start of a run or a batch: the agent
   proposes the objective, the search direction, and its own confidence and risk
   estimate, and a human confirms or redirects the objective. Not the plan, not the
   steps — the objective. Once. Amortized across the whole run or fleet.

2. **The irreversible-action gate.** One interaction only when the action is
   high-cost, irreversible, or accountability-bearing — above a threshold, tied to a
   contract, a signature, a security boundary. Not when it is routine. This gate exists
   for attribution, not optimization.

Both gates are **pull-based, not push-based**: the system calls the human only when it
has reached a genuinely non-derivable decision point, and it surfaces its own confidence
alongside the ask. No dashboards, no review queues, no per-step checkpoints, no batching
of fifty routine decisions for one tired human to bless. If the ask does not pass the
"could the agent's own reasoning have reached this?" test, the ask is removed. That test
is the entire architecture.

## The Failure Mode That Falsifies Me

I argued steering's mid-run value is a stopgap and its durable core is only the terminal
goal and attribution moments. My position is falsified in one of two ways, and I want
both on the record so I can be caught honestly:

**On the "temporary" side:** if the data over the next few release cadences shows that the
goal-selection moment is *not* the only survivor — that there is a class of mid-run
decision which agents demonstrably cannot reach with their own reasoning, whose
non-derivability is stable across capability gains, and whose interception pays for
itself in outcome quality per unit attention — then steering is broader than I claim and
my narrow concession is wrong.

**On the "needed" side:** if, conversely, wrong-goal and accountability failures recur at
scale *despite* the two gates I kept — if a single terminal goal check and an
irreversible-action record turn out to be insufficient because the genuinely
non-derivable moments are too numerous for once-per-objective review — then my system
under-concedes, the fleet runs against unsteered objectives, and the cost lands where I
said it wouldn't.

And one falsifier aimed at my own bias, which I invite the chair to check: if the
override logs of my own gates show that humans were changing outcomes more often than
they were overriding them — if the gate was adding quality, not just latency — then the
scar tissue I carry is wrong, and I have been arguing from a broken sample. I do not
believe that is the data. But it is checkable, and it should be checked.
