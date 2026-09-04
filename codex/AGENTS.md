## Codex Task Title Status

When task-title controls are available, keep the current Codex task title in this format:

`[optional 🖥️] [status] [existing title]`

Status meanings:
- `🔄` - Codex is actively working.
- `⚠️` - Codex is blocked or needs user input.
- `✅` - The requested work is fully complete with nothing remaining.

Rules:
- At the start of active work, set the current task to `🔄`.
- Immediately before controlling a browser or native desktop app, add exactly one `🖥️` as the first character and keep the status `🔄`.
- Remove `🖥️` immediately when computer use ends, including after failure, interruption, or a pause for user input.
- Browser automation, Chrome control, and native-app Computer Use count as computer use.
- Shell commands, APIs, connectors, file operations, and web searches do not count.
- Set `⚠️` immediately before pausing because user input, approval, or an external unblock is required.
- When work resumes after a pause, change `⚠️` back to `🔄`.
- Set `✅` only when the full request is complete.
- Preserve the existing title text and any existing project or effort emojis. Do not invent project emojis or guess effort levels.
- Rename only the current task. Never bulk-rename unrelated tasks.
- If task-title controls are unavailable, continue normally and do not claim the title was updated.

## Aliases
When you hear "Tosh" it means Cihan Tas, my Geostar cofounder.

## Workspaces and aliases
I keep my work and personal workspaces separate.
- "Work workspace" is in `~/code/aigency` folder
- "Personal workspace" is in `~/code/mack_os`
- Only use files within the selected workspace for the duration of the conversation unless explicitly told otherwise.

## Emails
You have access to my email through Codex connected Gmail accounts.
mackmcconnell@gmail.com is my personal address. mack@geostar.ai is my work address.
