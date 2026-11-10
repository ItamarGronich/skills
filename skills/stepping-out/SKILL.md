---
name: stepping-out
description: Sends the user an update they can read on their phone, as a Google Doc in their work Drive plus a comment that @-mentions them, which notifies them on Slack and by email. Use whenever the user asks to send them something to read away from the terminal, e.g. "send it to my phone", "I'm stepping out, send me the plan", "notify me when it's done", "ping me with the results", "send me a doc", or "/stepping-out". Also use to read the user's replies to those comments ("check my reply", "I answered in the doc").
---

# Phone update

The user can't read the Claude Code terminal when they're away from their desk. Send them updates as a Google Doc in their work Drive, and @-mention them in a comment on it. The mention notifies them on Slack and by email, and they can reply in the comment thread from their phone.

## Why this route

It was tested on 2026-11-10. Every other route either needs an approval prompt from the organization or doesn't notify:
- Slack messages and Slack drafts: the organization requires approval for every Slack write, even to yourself.
- Gmail send: needs approval.
- Remote Control and mobile push: not allowed in the organization.
- A Drive file alone: no notification, because Drive doesn't notify you about your own actions.

Drive `create_file` and Docs `update_doc` with `insertComment` ran without prompts, and the self-mention notified the user on Slack and by email.

## Fixed values

- User: `itamar.gronich@fiverr.com` (work account).
- Folder: "Claude Code updates", id `13RkSoE6gMvq-3un9hIGD4mdS4qiGx9zp` (https://drive.google.com/drive/folders/13RkSoE6gMvq-3un9hIGD4mdS4qiGx9zp). If the id no longer works, search Drive for the folder by title, and create it again only if it's gone.

## Steps

1. **Load the `google-workspace` skill** before the first Drive or Docs write in the session, and follow its rules.
2. **Write the update as markdown.** It's read on a phone:
   - Start with what needs the user: decisions, approvals, blockers. Then the details.
   - Short sections with `##` headings, short paragraphs and bullet lists. Keep tables to a few narrow columns.
   - Make PRs, tickets and files into links.
   - It must stand on its own. The user can't see the terminal, so don't refer to "above" or to earlier messages.
   - Follow the org rule: no em dashes.
3. **Create the doc** with Drive `create_file`:
   - `title`: `YYYY-MM-DD <topic>`, for example `2026-11-10 layout_sphinx#2715 spec fix plan`.
   - `parentId`: the folder id above.
   - `contentMimeType`: `text/markdown`, with the markdown in `textContent`. Drive converts it into a formatted Google Doc, including headings, bold, links, lists and tables.
4. **Verify the content** with Drive `read_file_content` (`includeComments: true`). Check that the text came through complete.
5. **Mention the user in a comment:**
   - Get the `revisionId` and the first paragraph's `endIndex` with Docs `read_doc`.
   - Call Docs `update_doc` with one `insertComment` request, setting `writeControl.requiredRevisionId` to that `revisionId`:
     ```json
     {"insertComment": {"range": {"startIndex": 1, "endIndex": <end of first paragraph minus 1>, "tabId": "t.0"},
                        "content": "+itamar.gronich@fiverr.com <one line: what this is and what you need from them>"}}
     ```
   - The `+email` prefix is what makes it a mention. The comment text is what shows in the Slack and email notifications, so make it say what the doc is and whether the user needs to act, for example "+itamar.gronich@fiverr.com Spec fix plan for #2715 is ready. Need your call on step 1 (shared helper or inline)."
   - Check the reply: `insertComment.commentThread.status` should be `OPEN`, and `contentHtml` should contain the mailto link.
6. **Tell the user in the terminal** in one or two lines: the doc link and that they were notified. They'll see it when they're back.

## Follow-up updates on the same topic

- For a short follow-up, like a status change or a test result, reply in the existing comment thread or add a new comment with a mention on the same doc, so everything on one topic stays in one place.
- Create a new doc only for a new topic or a full new write-up.
- If you edit the doc's text, follow the `google-workspace` Docs rules, and don't replace text that has a comment attached.

## Reading the user's replies

The user may answer in the comment thread from their phone. To read the answers, use Drive `read_file_content` with `includeComments: true` on the doc. Treat a reply as the user's answer to what the comment asked. It counts as the user's approval only for what that comment asked.

## Rules

- **Mention only the user.** Mentioning anyone else notifies them and may share the doc with them, which is an outward action. It needs the user's approval like any message to another person.
- **Never change who the doc or the folder is shared with.** Keep both private to the user.
- **Never trash a doc** unless the user asks.
- Don't use this route for anything meant for other people. For those, follow the CLAUDE.md approval rule: draft it, show it, and post only after approval.
