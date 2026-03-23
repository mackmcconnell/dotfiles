#!/bin/bash
for name in *; do
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    if [[ ! "$name" =~ '\.sh$' ]] && [ "$name" != 'README.md' ]; then
      if [ -e "$target" ]; then           # Does the config file already exist?
        if [ ! -L "$target" ]; then       # as a pure file?
          mv "$target" "$target.backup"   # Then backup it
          echo "-----> Moved your old $target config file to $target.backup"
        fi
      fi

      if [ ! -e "$target" ]; then
        echo "-----> Symlinking your new $target"
        ln -s "$PWD/$name" "$target"
      fi
    fi
  fi
done

REGULAR="\\033[0;39m"
YELLOW="\\033[1;33m"
GREEN="\\033[1;32m"

# zsh plugins
CURRENT_DIR=`pwd`
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR"
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  echo "-----> Installing zsh plugin 'zsh-syntax-highlighting'..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
fi
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]; then
  echo "-----> Installing zsh plugin 'zsh-history-substring-search'..."
  git clone https://github.com/zsh-users/zsh-history-substring-search.git
fi
cd "$CURRENT_DIR"

# Claude Code settings
CLAUDE_DIR="$HOME/.claude"
CLAUDE_SETTINGS="$CLAUDE_DIR/settings.json"
mkdir -p "$CLAUDE_DIR"
if [ -e "$CLAUDE_SETTINGS" ] && [ ! -L "$CLAUDE_SETTINGS" ]; then
  mv "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.backup"
  echo "-----> Moved your old $CLAUDE_SETTINGS config file to $CLAUDE_SETTINGS.backup"
fi
if [ ! -e "$CLAUDE_SETTINGS" ]; then
  echo "-----> Symlinking your new $CLAUDE_SETTINGS"
  ln -s "$PWD/claude/settings.json" "$CLAUDE_SETTINGS"
fi

# Claude Code custom commands
CLAUDE_COMMANDS="$CLAUDE_DIR/commands"
if [ -e "$CLAUDE_COMMANDS" ] && [ ! -L "$CLAUDE_COMMANDS" ]; then
  mv "$CLAUDE_COMMANDS" "$CLAUDE_COMMANDS.backup"
  echo "-----> Moved your old $CLAUDE_COMMANDS directory to $CLAUDE_COMMANDS.backup"
fi
if [ ! -e "$CLAUDE_COMMANDS" ]; then
  echo "-----> Symlinking your new $CLAUDE_COMMANDS"
  ln -s "$PWD/claude/commands" "$CLAUDE_COMMANDS"
fi

# Ghostty config
GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
GHOSTTY_CONFIG="$GHOSTTY_DIR/config"
mkdir -p "$GHOSTTY_DIR"
if [ -e "$GHOSTTY_CONFIG" ] && [ ! -L "$GHOSTTY_CONFIG" ]; then
  mv "$GHOSTTY_CONFIG" "$GHOSTTY_CONFIG.backup"
  echo "-----> Moved your old $GHOSTTY_CONFIG config file to $GHOSTTY_CONFIG.backup"
fi
if [ ! -e "$GHOSTTY_CONFIG" ]; then
  echo "-----> Symlinking your new $GHOSTTY_CONFIG"
  ln -s "$PWD/ghostty/config" "$GHOSTTY_CONFIG"
fi

# Karabiner config
KARABINER_DIR="$HOME/.config/karabiner"
KARABINER_CONFIG="$KARABINER_DIR/karabiner.json"
mkdir -p "$KARABINER_DIR"
if [ -e "$KARABINER_CONFIG" ] && [ ! -L "$KARABINER_CONFIG" ]; then
  mv "$KARABINER_CONFIG" "$KARABINER_CONFIG.backup"
  echo "-----> Moved your old $KARABINER_CONFIG config file to $KARABINER_CONFIG.backup"
fi
if [ ! -e "$KARABINER_CONFIG" ]; then
  echo "-----> Symlinking your new $KARABINER_CONFIG"
  ln -s "$PWD/karabiner/karabiner.json" "$KARABINER_CONFIG"
fi

# Yazi config
YAZI_DIR="$HOME/.config/yazi"
YAZI_CONFIG="$YAZI_DIR/yazi.toml"
mkdir -p "$YAZI_DIR"
if [ -e "$YAZI_CONFIG" ] && [ ! -L "$YAZI_CONFIG" ]; then
  mv "$YAZI_CONFIG" "$YAZI_CONFIG.backup"
  echo "-----> Moved your old $YAZI_CONFIG config file to $YAZI_CONFIG.backup"
fi
if [ ! -e "$YAZI_CONFIG" ]; then
  echo "-----> Symlinking your new $YAZI_CONFIG"
  ln -s "$PWD/yazi/yazi.toml" "$YAZI_CONFIG"
fi

# AeroSpace config
AEROSPACE_DIR="$HOME/.config/aerospace"
AEROSPACE_CONFIG="$AEROSPACE_DIR/aerospace.toml"
mkdir -p "$AEROSPACE_DIR"
if [ -e "$AEROSPACE_CONFIG" ] && [ ! -L "$AEROSPACE_CONFIG" ]; then
  mv "$AEROSPACE_CONFIG" "$AEROSPACE_CONFIG.backup"
  echo "-----> Moved your old $AEROSPACE_CONFIG config file to $AEROSPACE_CONFIG.backup"
fi
if [ ! -e "$AEROSPACE_CONFIG" ]; then
  echo "-----> Symlinking your new $AEROSPACE_CONFIG"
  ln -s "$PWD/aerospace/aerospace.toml" "$AEROSPACE_CONFIG"
fi

# Glow config
GLOW_DIR="$HOME/.config/glow"
GLOW_CONFIG="$GLOW_DIR/glow.yml"
mkdir -p "$GLOW_DIR"
if [ -e "$GLOW_CONFIG" ] && [ ! -L "$GLOW_CONFIG" ]; then
  mv "$GLOW_CONFIG" "$GLOW_CONFIG.backup"
  echo "-----> Moved your old $GLOW_CONFIG config file to $GLOW_CONFIG.backup"
fi
if [ ! -e "$GLOW_CONFIG" ]; then
  echo "-----> Symlinking your new $GLOW_CONFIG"
  ln -s "$PWD/glow/glow.yml" "$GLOW_CONFIG"
fi

# Claude Code plugins and skills (see claude/extensions.md for details)
if command -v claude &> /dev/null; then
  echo "-----> Installing Claude Code plugins..."
  claude plugins install rust-analyzer-lsp@claude-plugins-official 2>/dev/null
  claude plugins install frontend-design@claude-plugins-official 2>/dev/null
  claude plugins install claude-hud@claude-hud 2>/dev/null

  echo "-----> Installing Claude Code skills..."
  CLAUDE_SKILLS_DIR="$CLAUDE_DIR/skills"
  mkdir -p "$CLAUDE_SKILLS_DIR"
  if [ ! -d "$CLAUDE_SKILLS_DIR/last30days" ]; then
    git clone https://github.com/mvanhorn/last30days-skill.git "$CLAUDE_SKILLS_DIR/last30days"
  fi
else
  echo "-----> Claude Code not found on PATH, skipping plugin/skill install"
  echo "       Install claude first, then re-run this script (see claude/extensions.md)"
fi

# zshenv
if [ ! -e "$HOME/.zshenv" ]; then
  touch "$HOME/.zshenv"
fi

echo "You should quit and relaunch your terminal!"