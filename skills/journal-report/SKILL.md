---
name: journal-report
description: Reports and reflects on the user's work from the daily journal at ~/journal. Use when the user asks what they did today, this week or this sprint, how much of the plan got done, what sidetracked them, how much time unplanned work took, for a weekly or sprint summary or status report, or to compare plan vs actual over any period.
---

# Journal report

Goal: an honest, short picture of a period: what was planned, what got done, what came up unplanned and what it cost.

## Steps

1. **Pick the period.** Use what the user asked for: a day, a week (Sunday to Thursday), the current sprint (dates from Monday, see `~/journal/config.md`) or a date range. Read those journal files.

2. **Count** from the Plan sections and Log entries:
   - planned items: done (`[x]`), carried over (an open item that shows up again in a later day's plan), dropped
   - plan completion rate: done / planned
   - unplanned items (`UNPLANNED U<n>`): how many, what, and rough time from START/DONE timestamps or the time to the next entry, marked as approximate
   - share of the period that went to unplanned work, approximate

3. **Collect** the key decisions, findings and blockers, one line each, with ids.

4. **Cross-check with Monday** (read only): sprint items done vs planned, and anything done in the journal but not reflected in Monday, or the other way round.

5. **Report in this structure:**
   ```
   ## <period>
   Plan: X of Y done (Z%), N carried over, M dropped
   Unplanned: K items, about H hours (~P% of logged time)
   ### Done
   ### Unplanned and what caused it
   ### Decisions and findings
   ### Not reflected in Monday
   ### Patterns
   ```
   Under Patterns, point out recurring sources of unplanned work and suggest how to plan for them.

Only write to the journal if the user asks, as one `NOTE` entry. Suggested Monday changes are drafts, posted only after explicit approval.
