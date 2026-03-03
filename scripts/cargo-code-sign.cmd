@echo off
REM Cargo wrapper that signs binaries after building.
REM
REM Uses CARGO_CODE_SIGN_CARGO to determine the inner cargo command.
REM If unset, falls back to plain `cargo`.
REM
REM Requires:
REM   cargo install --git https://github.com/zanieb/cargo-code-sign cargo-code-sign --locked

cargo-code-sign.exe code-sign %*
