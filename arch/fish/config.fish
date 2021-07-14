alias cl "clear"
alias sys "systemctl"
alias rcheck "cargo check && cargo clippy && cargo fmt --all && cargo test -- --nocapture"
alias rdoc 'RUSTDOCFLAGS="--cfg docsrs" cargo +nightly doc --all-features --document-private-items'
alias loomtest 'RUSTFLAGS="--cfg loom" cargo test --release'
