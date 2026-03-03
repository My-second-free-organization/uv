#!/usr/bin/env sh
## Install cargo extensions for release builds.
##
## Installs `cargo-auditable` for SBOM embedding and `cargo-code-sign` for
## binary signing.
##
## Usage:
##   scripts/install-cargo-extensions.sh

set -eu

# TODO(zanieb): Switch back to `cargo install cargo-auditable --locked` once the
# upstream i686 Windows SAFESEH fix is released.
CARGO_AUDITABLE_INSTALL="cargo install cargo-auditable \
    --locked \
    --git https://github.com/zanieb/cargo-auditable.git \
    --rev f4bea79198b07119e831e67976bab412d5641c8f"

CARGO_CODE_SIGN_INSTALL="cargo install cargo-code-sign \
    --locked \
    --git https://github.com/zanieb/cargo-code-sign"

# In Linux containers running on x86_64, build a static musl binary so the
# installed tool works in musl-based environments (Alpine, etc.).
#
# On i686 containers the 32-bit linker can't produce 64-bit musl binaries,
# so we fall back to a default (host-native) build.
if [ "$(uname -m 2>/dev/null)" = "x86_64" ] && [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
    MUSL_TARGET="x86_64-unknown-linux-musl"
    rustup target add "$MUSL_TARGET"
    CC=gcc $CARGO_AUDITABLE_INSTALL --target "$MUSL_TARGET"
    CC=gcc $CARGO_CODE_SIGN_INSTALL --target "$MUSL_TARGET"
else
    $CARGO_AUDITABLE_INSTALL
    $CARGO_CODE_SIGN_INSTALL
fi
