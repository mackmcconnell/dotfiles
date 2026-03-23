# Claude Code Extensions

Claude Code has two layers of configuration:

- **User-level** (~/.claude/) — global settings, plugins, skills, and
  commands that apply to all projects. This is what dotfiles manages.
- **Project-level** (.claude/ in a repo root) — per-project settings,
  CLAUDE.md instructions, and MCP server configs. These live in each
  project's own repo, not here.

This file is a manifest of the user-level plugins and skills. These are NOT
symlinked into dotfiles because they contain auto-managed state (download
caches, absolute paths, version hashes, timestamps) that changes on updates
and breaks across machines.

Instead, this manifest documents what to install and how, so a fresh machine
can be set up with one pass through `install.sh`.

The user-level files that ARE symlinked directly (in settings.json and
commands/) are handled separately in install.sh.

---

## Plugins

Plugins extend Claude Code with new capabilities (LSP integration, design
tools, etc). They are installed from plugin marketplaces — GitHub repos that
act as registries. Claude Code downloads and caches them in
~/.claude/plugins/cache/.

To install a plugin manually: `claude plugins install <name>` or
`claude plugins install <name>@<marketplace>`.

### Marketplaces

These are the plugin registries Claude Code pulls from. They are added
automatically when you first install a plugin from them.

| Marketplace                | GitHub Repo                        |
|----------------------------|------------------------------------|
| claude-plugins-official    | anthropics/claude-plugins-official  |
| anthropic-agent-skills     | anthropics/skills                  |
| superpowers-marketplace    | obra/superpowers-marketplace       |
| claude-hud                 | jarrodwatts/claude-hud             |

### Installed Plugins

| Plugin                                       | What it does                                                       |
|----------------------------------------------|--------------------------------------------------------------------|
| rust-analyzer-lsp@claude-plugins-official     | Gives Claude access to rust-analyzer LSP for Rust projects         |
| frontend-design@claude-plugins-official       | Gives Claude tools for frontend design (screenshots, visual diff)  |
| claude-hud@claude-hud                         | Status line HUD showing token usage, cost, and session info        |

Note: Plugins listed in `enabledPlugins` in settings.json must also be
installed here. If settings.json references a plugin that isn't installed,
it will be silently ignored.

---

## Skills

Skills are prompt-based extensions that give Claude specialized behaviors
(research workflows, code review patterns, etc). They live as git repos
cloned into ~/.claude/skills/.

To install a skill manually: `claude skills install <name>` or clone the
repo directly into ~/.claude/skills/.

### Installed Skills

| Skill      | GitHub Repo                          | What it does                                                              |
|------------|--------------------------------------|---------------------------------------------------------------------------|
| last30days | mvanhorn/last30days-skill            | Research agent that searches Reddit, X, YouTube, HN, etc. for recent info |

---

## Restoring on a New Machine

Run `install.sh` — it will symlink settings.json and commands/ as usual,
then install all plugins and skills listed above. You will need Claude Code
(`claude`) available on PATH first.
