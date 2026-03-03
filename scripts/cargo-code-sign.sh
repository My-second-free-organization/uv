#!/bin/sh
## Cargo wrapper that signs binaries after building.
##
## Uses CARGO_CODE_SIGN_CARGO to determine the inner cargo command.
## If unset, falls back to plain `cargo`.
##
## Requires:
##   cargo install --git https://github.com/zanieb/cargo-code-sign cargo-code-sign --locked

set -eu

exec cargo-code-sign code-sign "$@"
