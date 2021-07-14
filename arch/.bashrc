# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

# Paths (only affect current user)
export PATH=$PATH:$HOME/bin:$HOME/.local/bin

# Proxy
export http_proxy="socks5://127.0.0.1:1080"
export https_proxy="socks5://127.0.0.1:1080"

# Aliases
alias vi='nvim'
alias ls='ls -lh --color=auto'
alias la='ls -lh -a'
alias sys='systemctl'
alias rcheck='cargo check && cargo clippy && cargo fmt --all && cargo test'
alias rdoc='RUSTDOCFLAGS="--cfg docsrs" cargo +nightly doc --all-features'

# Colorize tshark output (24-bit color terminal only)
alias tsharkc='tshark --color'

# Default to human-readable format
alias df="df -h"
