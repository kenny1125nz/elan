#!opencode:1.0

DATE = $(date +%Y-%m-%d)
OUT = "debate-output/${DATE}"
exec mkdir -p "${OUT}"

MINUTES = "${OUT}/debate-record.md"
POSITIONS = "${OUT}/positions"
exec mkdir -p "${POSITIONS}"

PROFILES = ["kai-tan", "maya-chen", "elena-petrova", "marcus-reed"]
CHAIR = "anja-novak"
DIR = "experts"
INPUTS = "inputs/steering-debate.md"
TOPIC = "Is Human Steering Needed in Agentic Processes?"

exec "printf '%s\n' '# Elan Debate Record' '' '**Topic:** ${TOPIC}' '**Date:** ${DATE}' '' '---' '' '## Panel' '' > ${MINUTES}"
for SLUG in PROFILES {
  exec echo '- ${SLUG}' >> ${MINUTES}
}
exec "printf '\n%s\n' '---' '' '## 1. Panelist Positions' '' >> ${MINUTES}"

print "=== Elan Debate: ${TOPIC} ==="
print "Date: ${DATE}"
print "Record: ${MINUTES}"
print ""

for SLUG in PROFILES {
  print ""
  print "--- ${SLUG} speaks on ${TOPIC} ---"

  do "Read the profile file named ${DIR}/${SLUG}.md. You ARE this panelist — adopt their role, background, disposition, prior art, and perspective. Also read the debate brief at ${INPUTS}, which frames the two opposing claims and the case on each side.

**Do not explore or read anything else in the workspace** — no other files, no docs, no code. Base your position solely on your profile and the brief. Avoid any bias or distraction from other material.

Argue your position on the question the brief poses: **Is human steering needed in agentic processes — now and in the near future — and what value does it provide?** Your profile gives your disposition, the prior art you'd cite, and what you would weigh — but the position is yours to reason out from the brief, not pre-scripted. Reason honestly to a conclusion, engaging the brief's two claims. Address:

- Whether human steering is needed at all, and why
- The concrete value it provides (or fails to provide), and how that value would be observable
- Whether that value is durable or only temporary (a stopgap until agent capability catches up)
- Only if you argue steering is justified: the minimal interaction points that would deliver its value — as a consequence of your argument, not an assumption
- The key failure mode or condition that would falsify your position

**Write your full position to ${POSITIONS}/${SLUG}.md.** Ground your argument in the brief and in the prior art your profile references. Write in your voice. This is your complete position — the chair will read only this file. No token limit."
}

print ""
print "--- Chair summarizes each panelist ---"

for SLUG in PROFILES {
  print "--- chair summarizes ${SLUG} ---"

  do "Read the debate brief (${INPUTS}). Read the position file ${POSITIONS}/${SLUG}.md.

You are the debate chair (read ${DIR}/${CHAIR}.md for context).

**Do not explore or read anything else in the workspace** — no other files, no docs, no code. Base your summary solely on the brief, this position file, and the chair profile.

**Append to ${MINUTES}**, under the existing section '## 1. Panelist Positions', a new subsection for this panelist with proper heading layering:

- Start with a `### <Panelist Full Name>` heading
- Under it, three labeled bullet points: `- **Position:** ...`, `- **Values:** ...`, `- **Costs:** ...`
- Keep each bullet to one sentence or a short clause; focused on the debate's real question: **does human steering still provide real value, and will it?**

Explicitly cover:

1. **Position:** whether this panelist argues steering is needed, and why
2. **Values:** the value(s) they claim human steering provides, and why — and whether they see that value as durable or temporary
3. **Costs:** what they say is the cost or negative side of human steering

Do not editorialize; stay faithful to the position file."
}

print ""
print "--- Chair produces the synthesis ---"

do "Read the per-panelist summaries already in ${MINUTES} under section '1. Strategic Discussion — Human Steering'. Also read the debate brief (${INPUTS}).

You are the debate chair (read ${DIR}/${CHAIR}.md for context).

**Do not explore or read anything else in the workspace** — no other files, no docs, no code. Base your synthesis solely on the brief, the per-panelist summaries, and the chair profile.

**Append to ${MINUTES}** a new top-level section, '## 2. Chair's Synthesis', that answers the debate's real question — **does human steering still provide real value, and will it?** Format as a numbered list with a bold lead-in for each item:

1. **Value verdict:** the panel's core conclusion on whether human steering provides real, observable value today
2. **What the value is:** the concrete value(s) the panel identified, in the panelist's own terms
3. **Durability:** whether that value is durable or a temporary stopgap, and the strongest argument on each side
4. **Conditions:** the conditions under which the value holds (and the failure modes that would negate it)
5. **Strongest challenge:** the single hardest objection to the value claim
6. **Design implication:** what interaction points, if any, the 'why' argument supports — the 'what' surfaced by the debate

**6 items total. One sentence each.** The full positions are archived under ${POSITIONS}/."
