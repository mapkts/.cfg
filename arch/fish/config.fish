set bashrc $HOME/.bashrc

# set -gx EDITOR nvim

# set -gx http_proxy http://127.0.0.1:1081
# set -gx https_proxy http://127.0.0.1:1081

# Aliases
alias cl 'clear'
alias sys 'systemctl'
alias rcheck 'cargo check && cargo clippy && cargo fmt --all && cargo test -- --nocapture'
alias rdoc 'RUSTDOCFLAGS="--cfg docsrs" cargo +nightly doc --all-features --document-private-items'
alias loomtest 'RUSTFLAGS="--cfg loom" cargo test --release'

alias vi 'nvim'
alias ls 'ls -lh --color=auto'
alias la 'ls -lh -a'

alias idea '/home/mapkts/idea/bin/idea.sh'
alias tshark 'tshark --color'

# Default to human-readable format
alias df 'df -h'
