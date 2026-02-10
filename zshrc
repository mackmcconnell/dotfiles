# ==============================================================================
# Oh My Zsh
# ==============================================================================

# Path to Oh My Zsh installation
ZSH=$HOME/.oh-my-zsh

# Theme (see: https://github.com/robbyrussell/oh-my-zsh/wiki/themes)
ZSH_THEME="robbyrussell"

# Show red dots while waiting for tab completion
COMPLETION_WAITING_DOTS="true"

# Plugins loaded from ~/.oh-my-zsh/plugins/
#   git            - git aliases and shortcuts (e.g., gst, gco, gp)
#   sublime        - 'st' command to open files in Sublime Text
#   zsh-syntax-highlighting  - colors commands as you type (red = invalid, green = valid)
#   zsh-history-substring-search - up/down arrows search history matching what you've typed
plugins=(git sublime zsh-syntax-highlighting zsh-history-substring-search)

# Load Oh My Zsh (must come after theme and plugin settings)
source $ZSH/oh-my-zsh.sh

# ==============================================================================
# Shell Options
# ==============================================================================

# Disable zsh's auto-correct ("Did you mean...?" prompts)
unsetopt correct_all

# ==============================================================================
# History
# ==============================================================================

# Number of commands kept in memory during a session
HISTSIZE=10000

# Number of commands saved to the history file between sessions
SAVEHIST=9000

# Where history is stored on disk
HISTFILE=~/.zsh_history

# ==============================================================================
# Keybindings
# ==============================================================================

# Up/down arrows search history based on what you've already typed
# (two variants cover different terminal emulators)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# ==============================================================================
# Encoding
# ==============================================================================

# Set UTF-8 as the default text encoding everywhere
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ==============================================================================
# Editor
# ==============================================================================

# Use Sublime Text as the default terminal editor (for git commits, etc.)
export EDITOR='subl -w'

# ==============================================================================
# PATH
# ==============================================================================

# Base PATH: system dirs + Homebrew + npm + misc tools + personal ~/bin
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/share/npm/bin:/usr/X11/bin:/usr/texbin:~/bin:$PATH"

# Heroku CLI
export PATH="/usr/local/heroku/bin:$PATH"

# pipx — installs Python CLI tools in isolated environments
export PATH="$PATH:/Users/mackmcconnell1/.local/bin"

# ==============================================================================
# Ruby — rbenv (manages Ruby versions)
# ==============================================================================

# Use Homebrew's rbenv directory instead of ~/.rbenv
export RBENV_ROOT=/usr/local/var/rbenv
export PATH="${RBENV_ROOT}/bin:/usr/local/opt/rbenv/shims:/usr/local/opt/rbenv/bin:$PATH"

# Initialize rbenv (sets up shims so 'ruby' points to the right version)
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# RVM — another Ruby version manager (you have both; they can conflict)
export PATH="$PATH:$HOME/.rvm/bin"

# ==============================================================================
# Node — nvm (manages Node.js versions)
# ==============================================================================

export NVM_DIR="$HOME/.nvm"
# Load nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# Load nvm tab-completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ==============================================================================
# Python — Conda (manages Python environments)
# ==============================================================================

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/mackmcconnell1/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/mackmcconnell1/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/mackmcconnell1/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/mackmcconnell1/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# ==============================================================================
# PostgreSQL
# ==============================================================================

# Connect to local Postgres by default
export PGHOST=localhost

# Start/stop the local PostgreSQL server
alias pg-start='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias pg-stop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'

# ==============================================================================
# Aliases
# ==============================================================================

# Launch Claude Code
alias c="claude"

# ==============================================================================
# External Config Files
# ==============================================================================

# Load API keys and secrets (NOT tracked in dotfiles)
[[ -f "$HOME/.env.local" ]] && source "$HOME/.env.local"

# Load custom aliases from ~/.aliases (if the file exists)
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Load default profile settings from ~/.profile (if the file exists)
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"
