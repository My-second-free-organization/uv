@echo off
REM Cargo wrapper that runs `cargo auditable` to embed SBOM metadata.
REM
REM Requires:
REM   cargo install cargo-auditable --locked

cargo.exe auditable %*
