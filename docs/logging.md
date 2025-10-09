---
title: Logging Framework
---

# Bash Logging Framework

This document explains how to use the Bash logging utilities provided in `share/logs`.  The goal of the framework is to give your shell scripts robust, configurable logging with minimal boilerplate: coloured terminal output, timestamped records, level filtering, and archival log files for later inspection.

## Quick Start

```bash
#!/usr/bin/env bash

# Source the logging helpers
source "${HOME}/.ilm/share/logs"

# Optional: choose where logs are written and the default verbosity
LOG_DIR="$HOME/my-job/logs"
LOG_LEVEL=DEBUG

# Create a new logging session
log_init --session nightly-sync

slog "Starting nightly sync"
log_debug "Debug details only visible when LOG_LEVEL allows"
log_warn "Non-critical issue detected"
log_fail "Something went wrong"
```

Running the script produces colourised output on the terminal (when attached to a TTY) and creates log files in `$HOME/my-job/logs`.

## Features Overview

- ISO-8601 UTC timestamps prepended to every entry.
- Log level filtering (`TRACE`, `DEBUG`, `INFO`, `WARN`, `FAIL/ERROR`).
- Optional `--quiet` flag to suppress terminal output per-message while still recording to files.
- Separate files for info/warn/fail levels plus dedicated stdout/stderr capture.
- Automatic colour detection with manual override.
- Idempotent initialisation so multiple `log_init` calls are safe.

## `log_init`

Initialises the logging environment. Call it early in your script and just once per session.

**Options**
- `--session`, `-s <name>` – Friendly name for log files (default: timestamp).
- `--dir`, `-d <path>` – Directory for all log output (default: `$LOG_DIR` or `$DOT_DIR/logs` or `$HOME/logs`).
- `--no-redirect` – Do **not** redirect stdout/stderr to files automatically.
- `--redirect` – Explicitly enable stdout/stderr redirection (default behaviour).
- `--force` – Reinitialise even if logging is already configured.

Once initialised the following environment variables are populated:

| Variable            | Description                                   |
|---------------------|-----------------------------------------------|
| `LOG_DIR`           | Directory used for this session               |
| `LOG_SESSION`       | Session name (file prefix)                    |
| `LOG_INFO_FILE`     | Path to info-level log file                   |
| `LOG_WARN_FILE`     | Path to warn-level log file                   |
| `LOG_FAIL_FILE`     | Path to fail-level log file                   |
| `LOG_STDOUT_FILE`   | Captured stdout stream                        |
| `LOG_STDERR_FILE`   | Captured stderr stream                        |

## Writing Logs

| Function           | Purpose                                           |
|--------------------|---------------------------------------------------|
| `log_trace`        | Ultra-verbose messages for deep diagnostics       |
| `log_debug`        | Debug-level information (default hidden)         |
| `log_info` / `slog`| General informational output                      |
| `log_warn` / `warn`| Non-fatal warnings                                |
| `log_fail` / `fail`| Errors and fatal issues                           |

Each accepts an optional `--quiet` flag to disable terminal printing:

```bash
log_warn --quiet "Persisted without spamming the console"
```

## Controlling Verbosity

`log_set_level <LEVEL>` adjusts the global threshold at runtime. Accepted levels: `TRACE`, `DEBUG`, `INFO`, `WARN`, `FAIL`, `ERROR`.

For example:

```bash
log_set_level WARN  # Now only WARN and FAIL reach the terminal/files
```

## Stdout/Stderr Capture

By default `log_init` redirects stdout and stderr to `LOG_STDOUT_FILE` and `LOG_STDERR_FILE`. If you disabled redirection, you can enable it later:

```bash
log_redirect_stdstreams
```

Each print after this call, whether via `echo` or another command, is appended to the corresponding file.

## Environment Configuration

Set these variables before sourcing `share/logs` or before calling `log_init`:

- `LOG_LEVEL` – Initial threshold (default `INFO`).
- `LOG_USE_COLOR` – `auto`, `always`, or `never` (default `auto`).
- `LOG_DISABLE_REDIRECT` – `1` to skip stdout/stderr redirection.
- `LOG_DIR` – Base directory for logs; auto-created if missing.

## Testing

Run the test suite to validate logger behaviour and lint scripts with ShellCheck:

```bash
cd "${HOME}/.ilm"
bash tests/logs_test.sh
```

The suite now bundles an automatic ShellCheck pass (downloaded on demand if not already available) alongside behavioural checks for level filtering, quiet mode, colour handling, stream capture, and session reinitialisation. Ensure `curl` or `wget` is available when running the tests so the linter can be fetched if needed.

## Integration with `share/utils`

The shared utility library sources `share/logs`, so all calls to `slog`, `warn`, and `fail` across the dotfiles use this logging system. Any custom script can do the same by sourcing `share/utils` instead of `share/logs` directly.
