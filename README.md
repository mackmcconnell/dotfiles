# Dotfiles

Personal shell and editor config for macOS.

## What's included

| File | What it configures |
|---|---|
| `zshrc` | Zsh shell — Oh My Zsh, PATH, history, keybindings, version managers (rbenv, nvm, conda), Postgres, aliases |
| `aliases` | Custom shell shortcuts |
| `gitconfig` | Git settings (user, editor, aliases) |
| `gemrc` | Ruby Gems config |
| `vimrc` | Vim editor config |
| `tm_properties` | TextMate editor config |
| `libre_office_shortcuts.cfg` | LibreOffice keyboard shortcuts |

## Prerequisites

- [Oh My Zsh](https://ohmyz.sh/) installed

## Install

Clone the repo and run the install script:

```bash
git clone https://github.com/mackmcconnell/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

The install script will:
1. Symlink each config file into your home directory (e.g. `~/code/dotfiles/zshrc` → `~/.zshrc`)
2. Back up any existing config files to `<file>.backup` before replacing them
3. Symlink the canonical Codex config to `~/.codex/config.toml`
4. Install the `zsh-syntax-highlighting` and `zsh-history-substring-search` Oh My Zsh plugins

Restart your terminal after running.

### Codex configuration

`codex/config.toml` is the canonical user-level Codex configuration. `./install.sh` backs up an existing regular `~/.codex/config.toml` and replaces it with a symlink to the canonical file.

After syncing this repository to another machine, run `./install.sh` there once to create the symlink. Future config changes then become live as soon as the dotfiles repository is synced.

## Shared user skills

Maintain one source per personal skill; app discovery folders contain links, not separate copies. Keep app settings and state in their respective `.codex` and `.claude` folders. Team-owned skills stay in their project repositories, and plugin-owned skills stay managed by their plugins.

**Current implementation:** `codex/skills/<name>/SKILL.md` is the shared source. `bin/install-agent-skills` links each skill into `~/.codex/skills/<name>` and `~/.claude/skills/<name>`. `install.sh` also calls this helper. `sync` and `geopetto` use this layout. The repo's matching `claude/skills/` entries are relative links to the same sources.

**Proposed next step, not yet implemented:** consolidate the remaining personal skills under `skills/` and update the helper accordingly. Verify Codex discovery before switching its installation path to the currently documented `~/.agents/skills`; avoid installing the same skill in both Codex locations. Keep this section and the helper in agreement when migrating.

### Install or repair

After committing and pushing changes from the source machine, run on another machine:

```bash
cd ~/code/dotfiles
git pull --rebase
bash bin/install-agent-skills
```

To repair local links, run only the helper. It is safe to repeat: it repairs stale links for skills in the shared source and backs up replaced real directories under `~/.codex/skill-backups/` or `~/.claude/skill-backups/`. It does not remove links for deleted skills or repair unrelated skills.

If a skill is missing, check that both app paths resolve to its canonical source:

```bash
ls -ld ~/.codex/skills/sync ~/.claude/skills/sync
(cd ~/.codex/skills/sync && pwd -P)
(cd ~/.claude/skills/sync && pwd -P)
```

Both resolved paths should end in `dotfiles/codex/skills/sync`. Confirm `SKILL.md` exists there, rerun the helper, then start a fresh app session and check its skill picker. If an old duplicate definition remains in a project's skills or Claude commands, compare it with the canonical source before removing it. Never delete unique content just to eliminate a duplicate name.

## Scripts

### `bin/transcribe`

Transcribes iPhone Voice Memos into Apple Notes, today's Obsidian daily note, or the clipboard. Finds the latest untranscribed voice memo by default, runs it through Whisper, sends it to the chosen destination, and marks the memo as transcribed in the Voice Memos app.

```bash
transcribe                                  # Latest memo to daily note, local Whisper
transcribe cloud                           # Latest memo to daily note, OpenAI Whisper API
transcribe cloud "New Recording 80"        # Named memo to daily note
transcribe "New Recording 80" cloud daily  # Same thing, any argument order works
transcribe menu cloud daily                # Pick from recent recordings
transcribe notes /path/to/audio.m4a        # Specific file to Apple Notes
```

Run it multiple times to work through your backlog - it skips already-transcribed memos.

**Dependencies:** `openai-whisper` (local mode), `ffmpeg` (cloud mode), Voice Memos iCloud sync enabled.

## Customization

- **Shell aliases** — edit `~/.aliases`
- **Zsh config** — edit `~/.zshrc`
- **Git settings** — edit `~/.gitconfig`

Since these are all symlinks back to this repo, you can commit and push changes directly:

```bash
cd ~/code/dotfiles
git add -A
git commit -m "description of change"
git push
```
