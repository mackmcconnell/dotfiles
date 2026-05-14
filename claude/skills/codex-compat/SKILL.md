---
name: codex-compat
description: Make a Claude Code project readable by OpenAI Codex by symlinking AGENTS.md -> CLAUDE.md and .codex/skills -> ../.claude/skills, without modifying anything Claude Code uses. Trigger whenever the user wants to "make this project work with Codex", "add Codex support", "share config with Codex", "set up AGENTS.md", "let Codex read my Claude config", or similar phrasings about making an existing Claude Code project compatible with Codex/OpenAI Codex CLI. Use this even if the user does not say the word "skill".
---

# codex-compat

Set up the current project so Codex can read the existing Claude Code config without changing anything Claude Code currently uses.

CLAUDE.md and `.claude/skills/` remain the source of truth. Do NOT move, rename, or modify them.

## Steps

Run from the project root.

### 1. AGENTS.md -> CLAUDE.md

- If `AGENTS.md` already exists as a regular file (not a symlink to `CLAUDE.md`), STOP and report it. Do not overwrite.
- If it already exists as the correct symlink, skip.
- Otherwise: `ln -s CLAUDE.md AGENTS.md`

If `CLAUDE.md` does not exist, stop and tell the user - there is nothing to defer to.

### 2. .codex/skills -> ../.claude/skills

- `mkdir -p .codex`
- If `.codex/skills` already exists (file, directory, or wrong symlink), STOP and report it. Do not overwrite.
- Otherwise: `ln -s ../.claude/skills .codex/skills`

If `.claude/skills/` does not exist, still create the symlink - it will resolve once the directory is added.

### 3. Verify

- `ls -la AGENTS.md .codex/skills` - both should display as symlinks pointing at `CLAUDE.md` and `../.claude/skills`.
- `git status` - the two new symlinks should appear as untracked. Don't commit; the user will commit so teammates pick them up.

### 4. Report

Print a single one-line summary of what was created or skipped. Example:

```
Linked AGENTS.md -> CLAUDE.md and .codex/skills -> ../.claude/skills. Untracked, ready to commit.
```

Be brief. Do not commit anything.

## Why symlinks (not copies)

Symlinks keep CLAUDE.md as the single source of truth. If the user edits CLAUDE.md, Codex sees the change immediately - no sync step, no drift. Same for the skills directory.

## Failure modes to surface clearly

- Pre-existing `AGENTS.md` regular file: the user may already have Codex-specific instructions. Don't clobber - show them the file and let them decide.
- Pre-existing `.codex/skills` that isn't the expected symlink: same principle.
- Not at project root (no `CLAUDE.md` nearby): ask the user to confirm the working directory before linking.
