#!/bin/sh
## Verify that all release artifacts contain cargo-auditable SBOM data.
##
## Requires:
##   cargo install rust-audit-info --locked
##
## Usage:
##   scripts/read-release-artifact-sboms.sh <run-id>

set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 <github-actions-run-id>" >&2
    exit 1
fi

RUN_ID="$1"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

if ! command -v rust-audit-info >/dev/null 2>&1; then
    echo "error: rust-audit-info not found, install with: cargo install rust-audit-info --locked" >&2
    exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "error: gh CLI not found" >&2
    exit 1
fi

ARTIFACTS=$(gh api "repos/astral-sh/uv/actions/runs/${RUN_ID}/artifacts" \
    --paginate --jq '.artifacts[] | select(.name | startswith("artifacts-")) | .name')

if [ -z "$ARTIFACTS" ]; then
    echo "error: no release artifacts found for run ${RUN_ID}" >&2
    exit 1
fi

PASS=0
FAIL=0

for artifact in $ARTIFACTS; do
    echo "--- ${artifact} ---"
    ARTIFACT_DIR="${WORKDIR}/${artifact}"
    gh run download "$RUN_ID" -R astral-sh/uv -n "$artifact" -D "$ARTIFACT_DIR"

    # Extract the archive (tar.gz for Unix, zip for Windows)
    EXTRACT_DIR="${WORKDIR}/${artifact}-extracted"
    mkdir -p "$EXTRACT_DIR"
    if ls "$ARTIFACT_DIR"/*.tar.gz >/dev/null 2>&1; then
        tar xzf "$ARTIFACT_DIR"/*.tar.gz -C "$EXTRACT_DIR"
    elif ls "$ARTIFACT_DIR"/*.zip >/dev/null 2>&1; then
        unzip -q "$ARTIFACT_DIR"/*.zip -d "$EXTRACT_DIR"
    else
        echo "  SKIP: no archive found"
        continue
    fi

    # Find the uv binary (uv or uv.exe)
    UV_BIN=$(find "$EXTRACT_DIR" -name 'uv' -o -name 'uv.exe' | head -1)
    if [ -z "$UV_BIN" ]; then
        echo "  FAIL: uv binary not found in archive"
        FAIL=$((FAIL + 1))
        continue
    fi

    if rust-audit-info "$UV_BIN" >/dev/null 2>&1; then
        echo "  PASS: SBOM present"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: no SBOM data"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
