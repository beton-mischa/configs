# System-wide .bashrc file for interactive bash(1) shells.

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

alias ll='ls -l --color'
alias la='ls -lAF --color'
alias ..='cd ..'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi  
fi

# colors
clr="\[\e[0m\]"
gry="\[\e[0;37m\]"
ylw="\[\e[0;33m\]"
red="\[\e[0;31m\]"
ppl="\[\e[0;35m\]"
lbl="\[\e[0;36m\]"
dbl="\[\e[0;34m\]"
grn="\[\e[0;32m\]"
#determine user color
if [ "$EUID" -ne 0 ]; then
    clr_u=${dbl}
else
    clr_u=${red}
fi
# determine host color
if [ "$(grep -q ^flags.*\ hypervisor\  /proc/cpuinfo)X" == "X" ]; then
    clr_h=${lbl}
else
    clr_h=${ppl}
fi
# set PS1
export PS1="${gry}[${ylw}\t${gry}] ${clr_u}\u${gry}@${clr_h}\h${gry}:${grn}\w ${clr_u}\\$> ${clr}"
