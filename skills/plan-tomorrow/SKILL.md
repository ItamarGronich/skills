---
name: plan-tomorrow
description: Closes the day and drafts the plan for the next workday. Use when the user asks to plan tomorrow, plan the next day or Sunday, wrap up or close the day, or accepts the evening offer to draft tomorrow's plan. Reviews today's journal (planned vs done vs unplanned), carries over unfinished work, scans Monday, GitHub, Slack, Gmail and Google Calendar, and writes the approved plan into the next workday's journal file.
---

# Plan tomorrow

Goal: end the day knowing what got done compared to the plan, and start the next workday with a plan the user already agreed to.

## Steps

1. **Review today.** Read today's journal file and summarize:
   - planned items done, partly done and not started
   - unplanned items (`U<n>`) and roughly how long they took, from START/DONE timestamps
   - key decisions and findings

   Append the review as one `NOTE` entry starting with "End of day:". Keep it to a few lines, e.g. "End of day: 3 of 5 planned done, 2 carried over; 2 unplanned items took about 2h (U1 review request on #2821, U2 CI failure)".

   On Thursday (the last workday of the week), also produce a short weekly report with the journal-report skill for Sunday to Thursday. Show it to the user and append it as one `NOTE` entry starting with "Week:".

2. **Find the next workday:** `~/.claude/skills/journal/scripts/journal.sh next-workday`. The work week is Sunday to Thursday, so on Thursday it's Sunday.

3. **Gather inputs** as in the plan-today skill (Monday sprint, GitHub, Slack, Gmail), plus the next workday's meetings from Google Calendar. Use parallel subagents.

4. **Draft the plan:**
   - carry-overs first
   - then sprint items by priority and due date
   - then reviews and replies others are waiting on
   - fit it to the free time around the meetings, and leave room for unplanned work, which usually shows up

   Show the draft with a one-line reason per item, plus any Monday updates you suggest.

5. **Write after approval.**
   - Run `journal.sh ensure <next-workday>`.
   - Write its Plan and Meetings sections with the Edit tool.
   - Log `PLAN "Drafted plan for <day>"` in today's file.

6. **Outward actions:** draft first and post only after the user explicitly approves. That covers Monday writes, Slack messages, emails and GitHub comments.
