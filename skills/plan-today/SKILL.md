---
name: plan-today
description: Shows the user today's plan and checks it against what's actually going on. Use when the user asks for today's plan, "what's the plan", "what should I work on", "what's on my plate", a morning check-in, or wants the plan re-checked during the day. Reads the journal, scans Monday, GitHub, Slack, Gmail and Google Calendar, and flags anything new, done, blocked or out of sync with Monday. If today has no plan yet, builds one.
---

# Plan today

Goal: the user knows what to work on today, and the plan matches reality: their Monday sprint, open PRs, messages that need an answer, and their meetings.

## Steps

1. **Read the journal.** Run `~/.claude/skills/journal/scripts/journal.sh ensure` and read today's file, plus the previous workday's file for unfinished plan items and open threads. Read `~/journal/config.md` for the sources.

2. **Gather inputs.** Do this in parallel subagents to keep this session's context small. Ask each for a short list of items with links and ids, not raw data:
   - **Monday:** the user's items in the current sprint on the board in config.md. Report status, due date, what changed since yesterday, and blockers.
   - **GitHub:** the user's open PRs (review state, CI, new comments), PRs waiting for the user's review, and mentions in the last 2 days.
   - **Slack:** mentions, DMs and the configured channels since the last plan. Report only messages that need the user to do something.
   - **Gmail:** actionable mail from the last 2 days, skipping automated notifications and promotions.
   - **Google Calendar:** today's meetings and free time.

3. **Reconcile.** Compare the plan with the inputs and list:
   - plan items that are already done, blocked, or no longer needed
   - new things that need the user today and aren't in the plan
   - mismatches with Monday, e.g. a merged PR whose ticket isn't Done, or work that isn't in the sprint
   - whether the plan fits the free time between meetings

4. **Present** a short prioritized plan: the items, why each one is today, a rough estimate, and the meetings. Under it, list the proposed changes and the Monday updates you suggest.

5. **Write after approval.**
   - When the user approves, write the Plan and Meetings sections with the Edit tool (never Write) if they're empty. Otherwise log the changes with `journal.sh add PLAN "..."`.
   - New work that wasn't in the plan is logged as `UNPLANNED` only once work on it starts.

6. **Monday and other outward actions.** Draft the exact change for Monday writes, Slack messages, emails and GitHub comments, show it, and post only after the user explicitly approves.

## Plan item format

```
- [ ] P1 Get communication_sphinx onto package_core_nx_plugin 4.19.2 (source: Monday 13386056277) ~1h
```

Keep ids stable through the day. Add new items as the next `P<n>`, never renumber, so log entries and reports keep matching.
