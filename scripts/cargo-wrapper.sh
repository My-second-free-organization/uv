#!/bin/sh
## Wrapper script that invokes `cargo auditable` instead of plain `cargo`.
##
## Usage (local):
##   cargo install cargo-auditable --locked
##   CARGO="$PWD/scripts/cargo-wrapper.sh" cargo build --release
##
## Usage (maturin):
##   CARGO="$PWD/scripts/cargo-wrapper.sh" maturin build --release
##
## The wrapper inserts the `auditable` subcommand so that dependency metadata
## (SBOM) is embedded into every compiled binary. See:
##   https://github.com/rust-secure-code/cargo-auditable
##
## Set REAL_CARGO to override the path to the real cargo binary
## (defaults to the first `cargo` found on PATH that is not this script).

set -eu

# Locate the real cargo binary.
if [ -n "${REAL_CARGO:-}" ]; then
    CARGO_BIN="$REAL_CARGO"
else
    # Find the real cargo, skipping this wrapper.
    SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
    CARGO_BIN=""
    OLDIFS="$IFS"
    IFS=":"
    for dir in $PATH; do
        candidate="$dir/cargo"
        if [ -x "$candidate" ] && [ "$(cd "$(dirname "$candidate")" && pwd)/$(basename "$candidate")" != "$SELF" ]; then
            CARGO_BIN="$candidate"
            break
        fi
    done
    IFS="$OLDIFS"
    if [ -z "$CARGO_BIN" ]; then
        echo "cargo-wrapper: could not find real cargo on PATH" >&2
        exit 1
    fi
fi

exec "$CARGO_BIN" auditable "$@"
