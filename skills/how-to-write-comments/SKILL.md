---
name: how-to-write-comments
description: Rules for writing code comments. ALWAYS invoke BEFORE writing or editing any comment, in any file type - source code, YAML, CI workflows, Dockerfiles, nginx and other config. Applies even when the comment is a small part of a larger change - one explanatory line, a docstring, comments in a diff you are about to commit, or reviewing comments someone else wrote. Do not skip because it is "just one comment" or because the main task is a feature or a bugfix.
---

# How to write good comments

Think of the content being commented on and the audience that will read it. Include relevant context.

Explain in simple terms and put emphasis on the Why. The code is the how and the comment is the why.

Never include details that are relevant only to the current discussion or of past attempts and ideas - only comment on the current implementation. Think about the reader - he doesn't know or doesn't need to know every attempt you made to get to the current implementation. unless it is relevant information in the sense that it helps the reader understand why the current implementation is a must.

Don't use jargon and speak coherently. State it simply and concisely, like one human talking to another.

## Before you save

Reread the comment and cut anything the reader has no way to see:

- a bug that was just fixed, or a value the code used to have
- something that was tried and abandoned
- anything that only makes sense if you were in the conversation

Keep it only when the reader would otherwise be tempted to simplify the code back into the problem it is avoiding.
