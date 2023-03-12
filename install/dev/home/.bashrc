#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

export TERM=xterm-256color
export EDITOR=vim

###############################################################################
#   Shell command aliases
###############################################################################
echo "Sourcing basic command aliases..."
alias   diff="diff -u --color=auto"
alias    edt="sudo vim"
alias    fnd="sudo find"
alias    lsa="sudo ls -lah --color=auto"
alias    lsd="sudo ls -lhd --color=auto */"
alias    lsl="sudo ls -lh  --color=auto"
alias    lsx="sudo ls -lhX --color=auto"
alias   psef="ps -ef | grep -v 'grep' | grep"
alias    prt="sudo cat"
alias  ptree="sudo pstree"

###############################################################################
#   Shell functions
###############################################################################
function entitle() {
    echo -ne "\033]0;$1\a"
}
export -f entitle

# systemd aliases
systemctl > /dev/null 2>&1
if [[ $? -eq 0 ]];then
   echo "Found systemd on system; setting systemd aliases..."
   alias sctl="sudo systemctl"
   alias jctl="sudo journalctl -b"
fi

# Dir colors
eval $(dircolors)

#Git aliases
git --version > /dev/null 2>&1
if [[ $? -eq 0 ]];then
   echo "Found Git on system; setting Git aliases..."
   alias gitb="git branch -va"
   alias gitc="git checkout"
   alias gitd="git diff"
   alias gitf="git fetch"
   alias gith="git --help"
   alias gitg="git log --graph --all --decorate"
   alias gitl="git log"
   alias gits="git status"
   alias gitr="git remote -v"
fi

# tmux aliases
tmux -V > /dev/null 2>&1
if [[ $? -eq 0 ]];then
   echo "Found tmux on system; setting tmux aliases..."
   alias tmxa="tmux attach -t"
   alias tmxl="tmux list-sessions"
   alias tmxn="tmux new-session -s"
   alias tmxk="tmux kill-session"
fi

# TO DO - source misc utilities, if they exist, or do this in .bashrc_local
# alias sshk="ssh-keygen"
# alias luks="sudo cryptsetup"

# Source distro-specific env, if present
if [[ -f ~/.bashrc_local_ubuntu ]]; then
   echo "Found Ubuntu env override; sourcing it..."
   . ~/.bashrc_local_ubuntu
elif [[ -f ~/.bashrc_local_fedora ]];then
   echo "Found Fedora env override; sourcing it..."
   . ~/.bashrc_local_fedora
elif [[ -f ~/.bashrc_local_rhel ]];then
   echo "Found RHEL env override; sourcing it..."
   . ~/.bashrc_local_rhel
elif [[ -f ~/.bashrc_local_centos ]];then
   echo "Found CentOS env override; sourcing it..."
   . ~/.bashrc_local_centos
fi

# Source customized env if present
if [[ -f ~/.bashrc_local ]];then
   echo "Found local system env override; sourcing it..."
   . ~/.bashrc_local
fi
echo "Environment setup complete"
