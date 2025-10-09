#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT=$(
  cd -- "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1
  pwd -P
)

LOGGER_SCRIPT="${PROJECT_ROOT}/share/logs"

if [[ ! -f "$LOGGER_SCRIPT" ]]; then
  echo "Logger script not found at ${LOGGER_SCRIPT}" >&2
  exit 1
fi

TMP_ROOT=$(mktemp -d)
trap 'rm -rf "$TMP_ROOT"' EXIT

TMP_BASE="${TMP_ROOT}/work"
mkdir -p "$TMP_BASE"

tests_total=0
tests_failed=0
SHELLCHECK_BIN=${SHELLCHECK_BIN:-}

ensure_shellcheck() {
  if [[ -n "${SHELLCHECK_BIN:-}" && -x "$SHELLCHECK_BIN" ]]; then
    return 0
  fi

  if command -v shellcheck >/dev/null 2>&1; then
    SHELLCHECK_BIN=$(command -v shellcheck)
    return 0
  fi

  local bundled="${PROJECT_ROOT}/share/shellcheck-v0.9.0"
  if [[ -x "$bundled" ]]; then
    SHELLCHECK_BIN="$bundled"
    return 0
  fi

  local work_dir="${TMP_ROOT}/shellcheck"
  mkdir -p "$work_dir"

  local archive="${work_dir}/shellcheck.tar.xz"
  local url="https://github.com/koalaman/shellcheck/releases/download/v0.9.0/shellcheck-v0.9.0.linux.x86_64.tar.xz"

  if command -v curl >/dev/null 2>&1; then
    curl -sSfL "$url" -o "$archive"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$archive" "$url"
  else
    echo "Unable to download shellcheck: curl or wget required" >&2
    return 1
  fi

  tar -xf "$archive" -C "$work_dir"
  SHELLCHECK_BIN="${work_dir}/shellcheck-v0.9.0/shellcheck"

  if [[ ! -x "$SHELLCHECK_BIN" ]]; then
    echo "Failed to prepare shellcheck binary" >&2
    return 1
  fi
}

run_test() {
  local name="$1"
  shift || true
  local script_path="${TMP_ROOT}/test_${tests_total}.sh"
  local output_path="${TMP_ROOT}/output_${tests_total}.log"

  cat >"$script_path"
  chmod +x "$script_path"

  if PROJECT_ROOT="$PROJECT_ROOT" LOGGER_SCRIPT="$LOGGER_SCRIPT" TMP_BASE="$TMP_BASE" SHELLCHECK_BIN="$SHELLCHECK_BIN" bash "$script_path" >"$output_path" 2>&1; then
    printf '[PASS] %s\n' "$name"
    rm -f "$output_path" "$script_path"
  else
    tests_failed=$((tests_failed + 1))
    printf '[FAIL] %s\n' "$name"
    sed 's/^/  /' "$output_path" || true
  fi

  tests_total=$((tests_total + 1))
}

if ! ensure_shellcheck; then
  echo "shellcheck is required for the test suite" >&2
  exit 1
fi

run_test "shellcheck passes" <<'EOF'
set -euo pipefail

"$SHELLCHECK_BIN" "$LOGGER_SCRIPT" "${PROJECT_ROOT}/tests/logs_test.sh"
EOF

run_test "initializes log files" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/init.XXXXXX")
export LOG_DIR

source "$LOGGER_SCRIPT"
log_init --session smoke --no-redirect

[[ "$LOG_INFO_FILE" == "${LOG_DIR}/smoke.info.log" ]]
[[ "$LOG_WARN_FILE" == "${LOG_DIR}/smoke.warn.log" ]]
[[ "$LOG_FAIL_FILE" == "${LOG_DIR}/smoke.fail.log" ]]
[[ "$LOG_STDOUT_FILE" == "${LOG_DIR}/smoke.stdout.log" ]]
[[ "$LOG_STDERR_FILE" == "${LOG_DIR}/smoke.stderr.log" ]]

for suffix in info warn fail stdout stderr; do
  [[ -f "${LOG_DIR}/smoke.${suffix}.log" ]]
done
EOF

run_test "respects log level thresholds" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/levels.XXXXXX")
export LOG_DIR

source "$LOGGER_SCRIPT"
log_init --session levels --no-redirect
log_set_level WARN

slog "info suppressed"
log_warn "warn message"
log_fail "fail message"

! grep -q "info suppressed" "$LOG_INFO_FILE"
grep -q "warn message" "$LOG_WARN_FILE"
grep -q "fail message" "$LOG_FAIL_FILE"
EOF

run_test "quiet suppresses terminal output" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/quiet.XXXXXX")
export LOG_DIR

source "$LOGGER_SCRIPT"
log_init --session quiet --no-redirect

output=$(slog --quiet "silent message")
[[ -z "$output" ]]
grep -q "silent message" "$LOG_INFO_FILE"
EOF

run_test "quiet warn writes to warn log" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/warnquiet.XXXXXX")
export LOG_DIR

source "$LOGGER_SCRIPT"
log_init --session warnquiet --no-redirect

output=$(warn --quiet "be careful")
[[ -z "$output" ]]
grep -q "be careful" "$LOG_WARN_FILE"
EOF

run_test "log trace respects level" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/trace.XXXXXX")
export LOG_DIR

source "$LOGGER_SCRIPT"
log_init --session trace --no-redirect

log_trace "trace hidden"
! grep -q "trace hidden" "$LOG_INFO_FILE"

log_set_level TRACE
log_trace "trace visible"
grep -q "trace visible" "$LOG_INFO_FILE"
EOF

run_test "color modes toggle ANSI output" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/color.XXXXXX")
export LOG_DIR

LOG_USE_COLOR=always
export LOG_USE_COLOR

source "$LOGGER_SCRIPT"
log_init --session colour --no-redirect

output=$(slog "color message")
[[ "$output" == *$'\033'* ]]

LOG_USE_COLOR=never
export LOG_USE_COLOR

output_plain=$(slog "plain message")
[[ "$output_plain" != *$'\033'* ]]
EOF

run_test "redirect captures stdout and stderr" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/streams.XXXXXX")
export LOG_DIR

source "$LOGGER_SCRIPT"
log_init --session stream --no-redirect
log_redirect_stdstreams

echo "stdout sample"
>&2 echo "stderr sample"

grep -q "stdout sample" "$LOG_STDOUT_FILE"
grep -q "stderr sample" "$LOG_STDERR_FILE"

stdout_capture=$( { echo "stdout capture"; } )
[[ "$stdout_capture" == "stdout capture" ]]

stderr_capture=$({ echo "stderr capture" >&2; } 2>&1 >/dev/null)
[[ "$stderr_capture" == "stderr capture" ]]
EOF

run_test "disable redirect leaves stdstreams untouched" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/no_redirect.XXXXXX")
export LOG_DIR

LOG_DISABLE_REDIRECT=1
export LOG_DISABLE_REDIRECT

source "$LOGGER_SCRIPT"
log_init --session no_redirect

[[ -z "${LOG_STDSTREAM_REDIRECTED:-}" ]]
EOF

run_test "force reinitializes session" <<'EOF'
set -euo pipefail

LOG_DIR=$(mktemp -d "${TMP_BASE}/force.XXXXXX")
export LOG_DIR

source "$LOGGER_SCRIPT"
log_init --session first --no-redirect

first_info="$LOG_INFO_FILE"

log_init --session second --no-redirect --force
second_info="$LOG_INFO_FILE"

[[ "$first_info" != "$second_info" ]]
[[ "$second_info" == "${LOG_DIR}/second.info.log" ]]

log_redirect_stdstreams

echo "second stdout"
grep -q "second stdout" "$LOG_STDOUT_FILE"
EOF

echo
printf 'Ran %d tests, %d failed\n' "$tests_total" "$tests_failed"

if (( tests_failed > 0 )); then
  exit 1
fi
