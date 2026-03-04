@echo off
REM Wrapper script that invokes `cargo auditable` instead of plain `cargo`.
REM
REM Usage:
REM   cargo install cargo-auditable --locked
REM   set CARGO=%CD%\scripts\cargo.cmd
REM   maturin build --release
REM
REM The wrapper inserts the `auditable` subcommand so that dependency metadata
REM (SBOM) is embedded into every compiled binary. See:
REM   https://github.com/rust-secure-code/cargo-auditable

if defined REAL_CARGO (
    "%REAL_CARGO%" auditable %*
) else (
    cargo.exe auditable %*
)
