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
3. Install the `zsh-syntax-highlighting` and `zsh-history-substring-search` Oh My Zsh plugins

Restart your terminal after running.

## Scripts

### `bin/transcribe`

Transcribes iPhone Voice Memos into Apple Notes. Finds the latest untranscribed voice memo, runs it through Whisper, creates a new "Brain Dump" note, and marks the memo as transcribed in the Voice Memos app.

```bash
transcribe              # Local Whisper (private, slower)
transcribe --cloud      # OpenAI Whisper API (fast, requires OPENAI_API_KEY)
transcribe <file>       # Transcribe a specific audio file
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
