---
name: journal
description: The user's daily work journal at ~/journal, shared by every Claude session. Use it whenever you log progress, a decision, a finding, a task you start or finish, a plan change, or unplanned work that came up, and whenever you need to know what the user is working on in other sessions or what today's plan is. Also use it before writing to any journal file, so you follow the format and don't overwrite other sessions' entries.
---

# Daily journal

The user works with several Claude sessions at once. The journal is how they all share one picture of the day: what was planned, what actually happened, and what came up unexpectedly. The user uses it to plan tomorrow and to reflect on how much of the plan got done and what pulled them off it.

## Files

- One file per day: `~/journal/YYYY-MM-DD-dayname.md`, e.g. `2026-11-01-sunday.md`. The work week is Sunday to Thursday, Israel time.
- `~/journal/config.md`: the user's sources and settings (Monday board, GitHub login, Slack channels). Read it when you plan or report.
- Sections: **Plan** (items `P1`, `P2`, ... with checkboxes), **Meetings**, **Log** (append-only, last section).

## Writing entries

Other sessions write to the same file at the same time, so never rewrite or reformat a journal file. Write only through the script, which appends under a lock:

```bash
J=~/.claude/skills/journal/scripts/journal.sh
$J add DECISION "package_core 5 runs the @types/react codemods in compat mode"
$J add UNPLANNED "Oded asked for a re-review of #2821 on Slack"   # gets the next U<n> id
$J add START "P2 4.19.2 upgrades in communication_sphinx"
$J done P2                                                          # ticks P2 and logs DONE
```

The only in-place edits allowed are writing the Plan and Meetings sections, done by the plan-today and plan-tomorrow skills after the user approves the plan. Use the Edit tool for those, never Write.

Entry types: `DECISION`, `FINDING`, `TASK` (new task identified), `START` and `DONE` (work on a plan item or `U<n>`; these give rough durations), `BLOCKED`, `PLAN` (a change to the plan), `UNPLANNED` (work that wasn't planned but got done or started), `NOTE`.

## What's worth an entry

After each step, ask: would the user, or a Claude in another session, need this tomorrow to plan, report or pick up the work? If yes, add it. If not, skip it.

Worth it: decisions and their reason in a few words, findings that change the plan, tasks started, finished or blocked, PRs opened, merged or reviewed, tickets created or changed, anything unplanned that took time.

Not worth it: routine commands, intermediate steps, things already obvious from a done item, restating the plan.

Write each entry as one plain sentence with the key fact and identifiers (PR numbers, Monday item ids). No jargon, no filler. Refer to plan items by id (`P3`, `U2`) so reports can match them.

After adding an entry, tell the user in one line what you added and why.

## Reading

The SessionStart hook already shows the session today's plan and the last log entries. Read the full file, or previous days' files, when you need more context about other sessions' work.
