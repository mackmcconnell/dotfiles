# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look at https://github.com/robbyrussell/oh-my-zsh/wiki/themes for alternatives
ZSH_THEME="robbyrussell"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git sublime zsh-syntax-highlighting zsh-history-substring-search)

source $ZSH/oh-my-zsh.sh
export PATH='~/.rbenv/shims:/usr/local/bin:/usr/local/share:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/share/npm/bin:/usr/X11/bin:/usr/texbin:~/bin'

# Disable zsh correction
unsetopt correct_all

# To use Homebrew's directories rather than ~/.rbenv
export RBENV_ROOT=/usr/local/var/rbenv
export PATH="${RBENV_ROOT}/bin:${PATH}"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Gather handy aliases
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Enhance history with substring search and purple highlighting
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# UTF-8 is our default encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export PATH=/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$PATH
export EDITOR='subl -w'

alias pg-start='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias pg-stop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'
export PGHOST=localhost

export PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH="/usr/local/opt/rbenv/shims:/usr/local/opt/rbenv/bin:$PATH"

# HISTORY
HISTSIZE=10000
SAVEHIST=9000
HISTFILE=~/.zsh_history
