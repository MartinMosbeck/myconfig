# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
ZSH_THEME="gallois"

# How often to auto-update (in days).
export UPDATE_ZSH_DAYS=14

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git web-search sudo wd vi-mode zsh-autosuggestions)

export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$(git_custom_status) $EPS1"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

PROMPT='%{$fg[white]%}%n@%M:%{$fg[cyan]%}[%~% ]%(?.%{$fg[green]%}.%{$fg[red]%})%B$%b '

################################
#    ALIASES, FUNCTIONS        #
################################
# list all directories
alias lsd='ls -d */'

# list all directories + hidden
alias lsad='ls -ad .*/ */'

#diskusage
alias diskuse="du -m -d 1 -h 2> /dev/null | sort -h"

#Recursively searches the files in the current directory for string matches.
#You can optionally provide a second glob argument to restrict what files to search
function search() {
    find . ${2:+-name "\"$2\""} -type f -print0 |
    xargs -0 grep -n --color=auto "$1";
}

alias zshconfig="vim ~/.zshrc"
alias n.="nemo . &"

alias ..="cd .."
alias ...="cd ../.."

# wrapper for easy extraction of compressed files
function extract () {
  if [ -f $1 ] ; then
	  case $1 in
		  *.tar.xz)    tar xvJf $1    ;;
		  *.tar.bz2)   tar xvjf $1    ;;
		  *.tar.gz)    tar xvzf $1    ;;
		  *.bz2)       bunzip2 $1     ;;
		  *.rar)       unrar e $1     ;;
		  *.gz)        gunzip $1      ;;
		  *.tar)       tar xvf $1     ;;
		  *.tbz2)      tar xvjf $1    ;;
		  *.tgz)       tar xvzf $1    ;;
		  *.apk)       unzip $1       ;;
		  *.epub)      unzip $1       ;;
		  *.xpi)       unzip $1       ;;
		  *.zip)       unzip $1       ;;
		  *.war)       unzip $1       ;;
		  *.jar)       unzip $1       ;;
		  *.Z)         uncompress $1  ;;
		  *.7z)        7z x $1        ;;
		  *)           echo "don't know how to extract '$1'..." ;;
	  esac
  else
	  echo "'$1' is not a valid file!"
  fi
}

# ---------- ALIAS gvim ---------- #
alias gvimtab="gvim -p"
alias gvimmul="gvim -O"

# ---------- ALIASES GIT ---------- #
# log with affected files
alias gitl="git log --stat"

# commit all modified
alias gitc="git commit -a"

# shortcut to git status
alias gits="git status"

# tree view of repository
alias gitt="git log --graph --full-history --all --color --date=short \
--pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%ad %s'"

alias gitaff="git diff-tree --no-commit-id --name-only -r"

# get dropped stashes
alias gitu="git fsck --unreachable |grep commit | cut -d\  -f3 \
| xargs git log --merges --no-walk --grep=WIP"

# follow the change history for a file
alias gitf="git log --follow --all --stat -p --"

# \brief: show differences of a commit in relation to n commits before in difftool
# \param $1: sha, default:HEAD
# \param $2: n, optional, default:1
# \param $3: file, optional
function gitd(){
    commit_sha=${1:-HEAD}
    param_n=${2:-1}
    which_file="-- ${3:-}"

    cmd="git difftool ${commit_sha}~$param_n $commit_sha $which_file"

    echo "executing: $ $cmd"
    eval $cmd
}

#-------- PYTHON DEV ----------- #
alias venv-create="python3 -m venv .env"
alias venv-activate=". .env/bin/activate"

#-------- OTHER ALIASES ----------- #

# MD5 Sum of full directory
function dirsum() {
    directory="${1:-.}"
    cd $directory
    find . -type f | xargs -d'\n' -P0 -n1 md5sum |
        sort -k 2 | md5sum
    cd - > /dev/null
}

######################
# SSH KEY MANAGEMENT #
######################
# manual key adding with time limit
function keyadd () {
if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s`
fi
    ssh-add -t 300
}

# use yubikey ssh key
function yubissh() {
	if [[ -z $1 ]]
	then
		echo "specify on or off"
		return 1
	fi

	if [[ $1 = "on" ]]
	then
		unset SSH_AUTH_SOCK
		export GPG_TTY=$(tty)
		unset SSH_AGENT_PID
		if [ $EUID -ne 0 ] && [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
			eval $(gpg-agent -q --daemon 2> /dev/null)
			export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
		fi
        ssh-add -L
	elif [[ $1 = "off" ]]
	then
		unset SSH_AUTH_SOCK
		eval `ssh-agent -s`
	else
		echo "specify on or off"
		return 1
	fi
}

##################################
# INCLUDE MACHINE LOCAL SETTINGS #
##################################
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
