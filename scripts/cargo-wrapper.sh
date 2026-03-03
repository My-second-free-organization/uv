#!/bin/sh
## Wrapper script that invokes `cargo auditable` instead of plain `cargo`.
##
## Requires `cargo-auditable`:
##   cargo install cargo-auditable --locked
##
## Usage:
##   CARGO="$PWD/scripts/cargo-wrapper.sh" cargo build --release

set -eu

exec cargo auditable "$@"
