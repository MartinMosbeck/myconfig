################################
#        PLUGINS, THEME        #
################################
source ~/.myconfig/support/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Load the theme
antigen theme gallois

antigen bundle git
antigen bundle sudo
antigen bundle wd
antigen bundle jeffreytse/zsh-vi-mode
antigen bundle zsh-system-clipboard
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle docker
antigen bundle docker-compose

# Tell Antigen that you're done.
antigen apply

################################
#        GENERAL SETTINGS      #
################################
# How often to auto-update (in days).
export UPDATE_ZSH_DAYS=14

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

export EDITOR="vim"

export KEYTIMEOUT=1

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# PROMPT SETUP
git_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

git_status_color() {
    if [[ -n $(git status -s) ]]; then
        echo "%F{red}" # Use red if there are changes
    else
        echo "%F{green}" # Use green if there are no changes
    fi
}

# Customize the prompt
PROMPT='%{$fg[white]%}%n@%M:%{$fg[cyan]%}[%~% ]%(?.%{$fg[green]%}.%{$fg[red]%})%B$%b '


################################
#    ALIASES, FUNCTIONS        #
################################
# list all directories
alias lsd='ls -d */'

# list all directories + hidden
alias lsad='ls -ad .*/ */'

alias cls="ls -lha --color=always -F --group-directories-first |awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"

#diskusage
alias diskuse="du -m -d 1 -h 2> /dev/null | sort -h"

#Recursively searches the files in the current directory for string matches.
#You can optionally provide a second glob argument to restrict what files to search
# Alternative for busybox: find . -type f -exec grep -Hn "pattern" {} \;
function search() {
    local search_expr="$1"
    local filename_expr="$2"

    if [[ -z $filename_expr ]]; then
        find . -type f -print0 | xargs -0 grep -n --color=auto "$search_expr";
    else
        find . -name "$filename_expr" -type f -print0 \
            | xargs -0 grep -n --color=auto "$search_expr";
    fi
}

# Like search, but opens files containing the search in gvim -p
function searchg() {
    local search_expr="$1"
    local filename_expr="$2"

    escaped_search_expr=$(printf '%s\n' "$search_expr" | sed 's/[]\/$*.^[]/\\&/g')

    # Create a temporary file to store the list of filenames
    tmpfile=$(mktemp)

    # Find files containing the search pattern and save the filenames
    # to the temporary file
    if [[ -z $filename_expr ]]; then
      find . -type f -print0 | xargs -0 grep -l "$search_expr" > "$tmpfile"
    else
        find . -name "$filename_expr" -type f -print0 \
            | xargs -0 grep -l --color=auto "$search_expr" > "$tmpfile";
    fi

    # Read the filenames from the temporary file into an array
    files=()
    while IFS= read -r file; do
        files+=("$file")
    done < "$tmpfile"

    # Remove the temporary file
    rm "$tmpfile"

    # Check if files array is not empty
    if [ ${#files[@]} -gt 0 ]; then
      # Convert array to space-separated string for gvim
      files_list=$(printf "%q " "${files[@]}")

      # Open files in gvim as tabs and perform the search
      eval gvim -p $files_list -c "/$escaped_search_expr"
    else
      echo "No files found containing the search pattern."
    fi
}

alias zshconfig="vim ~/.zshrc"
alias n.="nemo . &"
alias d.="dolphin --new-window . &"

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

sshping() {
    local host
    host=$(ssh -G "$1" | awk '/^hostname / {print $2}')
    echo "Pinging $host ($1)..."
    ping "$host"
}

sshuntil() {
  until ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $1 echo -e "Online" 2> /dev/null; do
      echo -n "."
      sleep 3
  done
}

# ---------- ALIAS gvim ---------- #
alias gvimtab="gvim -p"
alias gvimmul="gvim -O"

# ---------- ALIASES GIT ---------- #
# log with affected files
alias gitl="git log --stat"
alias gitlo="git log --stat --oneline"

# show branches, give copy to clipboard possibility

# local
gitbl() {
  gitb_helper "local"
}

gitbr() {
  gitb_helper "remote"
}

gitb() {
  gitb_helper "all"
}

gitb_helper() {

    local mode="$1"
    local mode_flag=""
    if [[ $mode == "local" ]]; then
      mode_flag="-l"
    elif [[ $mode == "remote" ]]; then
      mode_flag="-r"
    elif [[ $mode == "all" ]]; then
      mode_flag="-a"
    fi

    # Color codes for print -P
    local c_key="%F{cyan}"
    local c_branch="%F{green}" #TODO: for local branch only
    local c_branch_remote="%F{red}" #TODO: for local branch only
    local c_reset="%f"

    # Get branches
    local branches
    branches=("${(@f)$(git branch ${mode_flag} | sed 's/^[* ] *//')}")

    # Keys to choose from
    local keys=( {0..9} {a..z} {A..Z} )

    # Determine longest branch for alignment
    local maxlen=0
    for b in $branches; do
        (( ${#b} > maxlen )) && maxlen=${#b}
    done

    print "Available branches:"

    # Print each line with aligned formatting + print -P colors
    for i in {1..$#branches}; do
        local idx=$((i-1))
        (( idx >= ${#keys} )) && break

        local key="${keys[$((idx+1))]}"
        local branch="${branches[$i]}"

        if [[ "$branch" == remotes/* ]]; then
          color="$c_branch_remote"
        else
          color="$c_branch"
        fi

        # formatted branch text
        local padded=$(printf "%-*s" $maxlen "$branch")

        # print with colors expanded
        print -P "${c_key}[${key}]${c_reset} ${color}${padded}${c_reset}"
    done

    # Read key
    echo -n "Press key to copy branch name: "
    local key
    read -k 1 key
    echo

    # Find selected
    local pos=-1
    for i in {1..${#keys}}; do
        [[ "$key" == "${keys[$i]}" ]] && pos=$((i-1))
    done

    if (( pos < 0 || pos >= $#branches )); then
        print "Invalid key."
        return 1
    fi

    local selected="${branches[$((pos+1))]}"

    printf "%s" "$selected" | xclip -selection clipboard

    print "Copied: $selected"
}

# commit all modified
alias gitc="git commit -a"

# short status of repo
alias gits="git status -sb --renames"

# shortcut to commit with message
alias gitm="git commit -m"

# tree view of repository
alias gitt="git log --graph --full-history --all --color --date=short \
--pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%ad %s'"

alias gitaff="git diff-tree --no-commit-id --name-only -r"

# get dropped stashes
alias gitu="git fsck --unreachable |grep commit | cut -d\  -f3 \
| xargs git log --merges --no-walk --grep=WIP"

# follow the change history for a file
alias gitf="git log --follow --all --stat -p --"

# dir diff with difftool
alias gitdd="git difftool --dir-diff"

#find on which branch a commit is
alias gitbb="git branch -a --contains"

# swich to prevoius checked out branch
alias git-="git checkout -"

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

# Push new branch upstream
function gitp() {
  local branchname=$(git rev-parse --abbrev-ref HEAD)
  local upstream=${1:-origin}
  git push --set-upstream $upstream $branchname
}

# ---------- ALIASES RUST ---------- #
alias cr="cargo run"
alias crr="cargo run --release"
alias cb="cargo build"
alias cbr="cargo build --release"


#-------- PYTHON DEV ----------- #
alias venv-create="python3 -m venv .venv"
alias venv-activate=". .venv/bin/activate"

#-------- OTHER ALIASES ----------- #

# MD5 Sum of full directory
function dirsum() {
    directory="${1:-.}"
    cd $directory
    find . -type f | xargs -d'\n' -P0 -n1 md5sum |
        sort -k 2 | md5sum
    cd - > /dev/null
}

function keyinfo {
  key="$1"
  openssl pkey -in "$key" -text -noout
}

# see details x509 cert
function certinfo() {
  cert="$1"
  openssl x509 -text -noout -in "$cert"
}

function csrinfo() {
  csr="$1"
  openssl req -noout -text -in "$csr"
}

function certverify() {
  ca="$1"
  cert="$2"
  openssl verify -partial_chain -CAfile "$ca" "$cert"
}

function sshkeyinfo {
  key="$1"
  ssh-keygen -lf "$key"
}

function sshcertinfo {
  cert="$1"
  ssh-keygen -L -f "$cert"
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

######################
#    APP SHORTCUTS   #
######################

# bash into docker container
function dbash() {
  docker exec -it $1 bash
}

# activate/deactivate wireguard
function wire () {
  conf="$1"
  operation="$2"

  if [[ $operation == "d" ]]; then
    operation="down"
  else
    operation="up"
  fi

  wg-quick $operation $conf
}

which thefuck &> /dev/null && eval $(thefuck --alias)

#################################
#           JUJUTSU VCS         #
#################################
autoload -U compinit
compinit
source <(jj util completion zsh)

alias js="jj status"
alias jl="jj log"
alias jla="jj log 'all()'"
alias jll="jj log --stat"
alias jlog="watch -n 1 --color jj log --color=always"
alias je="jj edit"
alias jn="jj new"
alias jd="jj describe"
alias ja="jj abandon"
alias jr="jj rebase"
alias jsq="jj squash"
alias jop="jj op log"
alias ju="jj undo"
alias jadd="jj file track"
alias jgp="jj git push"
alias jgf="jj git fetch"
alias jbc="jj bookmark create"
alias jbm="jj bookmark move"
alias jba="jj bookmark advance"
alias jbl="jj bookmark list"
alias jbt="jj bookmark track"
alias jdiff="jj diffedit --tool meld"

# Prepopulate description with ticket number of nearest bookmark
jdd() {
  local ticket
  ticket=$(jj log -r 'heads(::@ & bookmarks())' --no-graph -T 'bookmarks' 2>/dev/null \
    | grep -oE 'ME[A-Z][0-9]+-[0-9]+' \
    | head -1)

  if [ -n "$ticket" ]; then

    jj desc --config "template-aliases.default_commit_description='\"$ticket \\n\"'" "$@"
    #jj desc --editor -m "$ticket "
  else
    jj desc "$@"
  fi
}

# Create remote track to closest bookmark
jbtt() {
  local remote=${1:-origin}
  local bookmark=$(jj log -r "heads(::@ & bookmarks())" \
    --no-graph -T "local_bookmarks.map(|b| b.name() ++ \"\n\")" | \
    head -1)
  echo "Set remote for $bookmark at remote $remote"
  set -x
  jj bookmark track $bookmark --remote=$remote
}

# create parallel feature branch between bookmark dev-root and dev-merge
function jbfeat() {
  jn -A dev-root -B dev-merge
}

##################################
# INCLUDE MACHINE LOCAL SETTINGS #
##################################
if [[ -f ~/.myconfig/local/.zshrc ]]; then
    source ~/.myconfig/local/.zshrc
fi
