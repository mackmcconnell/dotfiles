Review our entire conversation and generate a HANDOVER.md file in the current project root. This is a shift-change report for the next Claude session so nothing gets lost.

The handover doc must include:

## Session Goal
What we set out to accomplish this session.

## What Got Done
Concrete list of what was completed - files created, changed, commands run, features built.

## What Didn't Work
Failed approaches, bugs hit, dead ends - and how they were resolved (or not).

## Key Decisions
Important choices made during the session and the reasoning behind them.

## Gotchas and Lessons
Non-obvious things discovered that would waste time if re-learned. Include specific file paths, config quirks, API behaviors, etc.

## Current State
Where things stand right now - what's working, what's broken, what's half-done.

## Next Steps
Prioritized list of what to pick up first in the next session.

## Key Files
Map of the most important files touched or referenced, with a one-line description of each.

---

Guidelines:
- Be specific and concrete, not vague
- Include exact file paths, command snippets, and error messages where relevant
- Prioritize information that would be hard to reconstruct from code alone (the "why" behind decisions, failed approaches, context about external systems)
- Keep it scannable - use bullets, not paragraphs
- Don't pad it - if a section has nothing worth noting, skip it
