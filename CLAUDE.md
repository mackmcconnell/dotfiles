# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles. Each top-level file/dir is a config that gets symlinked into `$HOME` (or the appropriate `~/.config/...` location) by `install.sh`. The repo IS the source of truth — the home-directory copies are symlinks pointing back here, so edits made via `~/.zshrc` etc. are edits to this repo.

## Install / apply changes

```bash
./install.sh         # idempotent; backs up any non-symlink it would replace as <file>.backup
```

There is no build, lint, or test step. To "apply" a change, just edit the file in place — the symlink means the new config is live. Shell changes need a new terminal (or `source ~/.zshrc`).

## How install.sh maps files

- Top-level **files** (non-directories, excluding `*.sh` and `README.md`) → `~/.<name>` (e.g. `zshrc` → `~/.zshrc`, `aliases` → `~/.aliases`).
- Top-level **directories** are NOT auto-symlinked by the generic loop; each one that needs installing has a dedicated block lower in `install.sh` that targets a specific path:
  - `claude/settings.json` → `~/.claude/settings.json`
  - `claude/commands` → `~/.claude/commands`
  - `ghostty/config` → `~/Library/Application Support/com.mitchellh.ghostty/config`
  - `karabiner/karabiner.json` → `~/.config/karabiner/karabiner.json`
  - `yazi/yazi.toml`, `aerospace/aerospace.toml`, `glow/glow.yml` → corresponding `~/.config/...` paths
- `bin/` is not symlinked by `install.sh`; scripts there (e.g. `bin/transcribe`) are expected to be on `PATH` via `zshrc`.

When adding a new app config that lives in a subdirectory, add a new dedicated block to `install.sh` following the same pattern (back up non-symlink, then `ln -s`).

## Claude Code config layout

`claude/` is the Claude Code config tree that gets symlinked into `~/.claude/`:
- `claude/settings.json` — settings (symlinked as a file)
- `claude/commands/` — custom slash commands (symlinked as a directory)
- `claude/skills/` — skills, NOT symlinked by install.sh; lives in-repo and is referenced via `~/.claude/skills` separately. `claude/skills/last30days` is a git submodule (see `.gitmodules`); other skills under `claude/skills/` are currently untracked working directories.
- `claude/extensions.md` — notes on plugins/skills the install script tries to install via the `claude` CLI.

The tail of `install.sh` also `claude plugins install`s a few plugins and `git clone`s the `last30days` skill if `claude` is on PATH.

## bin/transcribe

Transcribes Voice Memos to `daily` (default), `notes`, or `clipboard`. Two backends: local `openai-whisper` (default) or OpenAI Whisper API (`--cloud`, needs `OPENAI_API_KEY` from `.env`). Argument order is forgiving: `--cloud`, destination, and file/name can appear in any order, e.g. `transcribe --cloud "New Recording 80" daily`.
