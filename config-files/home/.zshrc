if [ -d "$HOME/.nix-profile" ] ; then
    source $HOME/.nix-profile/etc/profile.d/nix.sh
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH:/snap/bin

if [ -d "$HOME/.local/bin" ] ; then
    export PATH=$HOME/.local/bin:$PATH
fi

export PATH="$(yarn global bin):$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

POWERLEVEL9K_DISABLE_GITSTATUS=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs virtualenv)
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# colemak

plugins=(git kubectl colorize virtualenv ansible python aws debian docker-compose emoji-clock git-flow helm httpie microk8s npm pip pipenv rsync sbt pyenv systemd vi-mode yarn wp-cli fzf)

export DISABLE_FZF_KEY_BINDINGS="false"
VIRTUAL_ENV_DISABLE_PROMPT=1

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#

# Setting fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fdfind --type f'

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

autoload -Uz compinit
compinit
# Completion for kitty
kitty + complete setup zsh | source /dev/stdin


# 
# Aliases Taken from LinkedIn - http://lnkd.in/dsBrU9F
# You may contribute more 

# ######### FUNCTIONS ###############################

# Thanks to Eric Ross
pss() { echo; ps auxwww | egrep "$@|^USER" | grep -v grep;}

# Thanks to Denis Kovalev
cls() { printf "\33[2J";}

# Thanks to Tomasz Klapinski & Carl Reynolds
mkcd() { /bin/mkdir $* && /usr/bin/cd "${@: -1}" ; }
rmk() { [ $# -eq 1 ] && sed -i $1d /home/[username]/.ssh/known_hosts ; } 

# Thanks to David A. Desrosiers
function duf { 
du -sk "$@" | sort -n | while read size fname; do for unit in k M G T P E Z Y; do if [ $size -lt 1024 ]; then echo -e "${size}${unit}\t${fname}"; break; fi; size=$((size/1024)); done; done 
} 
# ########## ALIASES ################################
# Thanks to Dave Smith
alias cls='clear' #kinda obvious, but I'm mistyping it regularly
alias df='df -h' 
alias ls='ls --color=tty' # nicer outputs

alias msg='tail -20 /var/log/messages' 
alias msgf='tail -f /var/log/messages' 
alias mlog='tail -20 /var/log/maillog' 
alias mlogf='tail -f /var/log/maillog' 
alias rd='rmdir' 
alias gorc='cd /etc/init.d' 
alias golog='cd /var/log' 
alias ver='cat /proc/version && cat /etc/system-release' 
alias exe='chmod u+x' 
alias cd..='cd ..' 
alias dir='ls -aFl --color' 
alias dr='ls -aF --color' 
alias dird='ls -aFld --color' # Show only directories 
alias mdstat='cat /proc/mdstat' 

# Thanks to Michael Eager
alias pd="pushd" 
alias po="popd" 
alias ..="cd ..;ls" 
alias dirs="dirs -v" 
alias h="cd \$PWD" 

# Thanks to Miguel E Arellano Quezada
alias ll='ls -l --color' 
alias la='ls -la --color' 
alias rm='rm -i' 
alias cp='cp -i' 
alias mv='mv -i' 

# Thanks to Tomasz Klapinski
alias hog="du -hs * | sort -n | egrep '(^[[:digit:]]{1,}.?[[:digit:]]?G)|(^[[:digit:]]{3,}M)'"

# Thanks to Jonathan Roberts
alias hist="history | grep $1"
alias cdc='cd; clear' #cd to home dir and clear screen
alias '..'='cd..' 
alias v='vim'
