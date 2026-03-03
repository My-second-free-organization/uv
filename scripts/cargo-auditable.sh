#!/bin/sh
## Cargo wrapper that runs `cargo auditable` to embed SBOM metadata.
##
## Requires:
##   cargo install cargo-auditable --locked

set -eu

exec cargo auditable "$@"
