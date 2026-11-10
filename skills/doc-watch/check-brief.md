Read-only check of the user's "Claude Code updates" Google Docs. Don't write, comment or edit anything, and don't change any file.

Load the Google Drive tools first with ToolSearch: "select:mcp__claude_ai_Google_Drive__search_files,mcp__claude_ai_Google_Drive__read_file_content,mcp__claude_ai_Google_Drive__get_file_permissions".

1. Read `~/.claude/doc-watch/state.json`. Its `docs` object is keyed by doc id. Each doc has `handledPostIds` and `claudePostIds`.
2. List the docs to check:
   - every doc in `docs`;
   - plus any doc in the folder `13RkSoE6gMvq-3un9hIGD4mdS4qiGx9zp` modified in the last 3 days. Use `search_files` with `parentId = '13RkSoE6gMvq-3un9hIGD4mdS4qiGx9zp'`, `excludeContentSnippets: true`, and follow every next-page token. The modifiedTime filter is sometimes ignored, so check each file's `modifiedTime` yourself.
   Skip docs whose title starts with "Claude Code test" or ends with "Format check". Those are test files.
3. For each doc:
   - Call `get_file_permissions`. If anyone other than itamar.gronich@fiverr.com has a permission, report the doc as SHARED and skip the rest of the checks for it.
   - Call `read_file_content` with `includeComments: true`.
   - Collect every post in `commentThreads`, both the `headPost` and every item in `replies`, whose `postId` is in neither `handledPostIds` nor `claudePostIds`. Skip posts whose content is empty. Skip posts whose content starts with "Claude:" or with "+itamar.gronich@fiverr.com Claude:", because those are Claude's own.
   - Remove the `<comment_start ...>` and `<comment_end ...>` tags from `fileContent`, and compare it with `~/.claude/doc-watch/<docId>.md` if that file exists. Collect any text that was added or changed. Ignore differences that are only whitespace or backslash escaping.

Return only this, and keep it short:
- For each doc that has anything new: its id and title, then
  - NEW_POSTS: for each post, its postId, its thread's commentId, its modifiedTime and its full content word for word;
  - TEXT_CHANGES: the added or changed text word for word;
  - SHARED, if it applies.
- If nothing is new in any doc, return exactly: NOTHING_NEW
