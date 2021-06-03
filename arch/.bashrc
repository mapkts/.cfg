# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

# Paths (only affect current user)
export PATH=$PATH:$HOME/bin:$HOME/.local/bin

# Proxy
export http_proxy="socks5://127.0.0.1:1080"
export https_proxy="socks5://127.0.0.1:1080"

# Aliases
alias vi="nvim"
alias ls='ls -l --color=auto'
alias la='ls -l -a'
alias sys="systemctl"

# Colorize tshark output (24-bit color terminal only)
alias tsharkc='tshark --color'

# Default to human-readable format
alias df="df -h"
