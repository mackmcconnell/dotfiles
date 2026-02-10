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

# zshenv
if [ ! -e "$HOME/.zshenv" ]; then
  touch "$HOME/.zshenv"
fi

echo "You should quit and relaunch your terminal!"