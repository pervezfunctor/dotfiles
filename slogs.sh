#!/bin/bash

# slogs.sh - A robust bash logging script with emoji support, color coding, and multiple log levels
# Author: Generated for logging purposes
# Version: 1.0

# =============================================================================
# CONFIGURATION OPTIONS
# =============================================================================

# Log directory where all log files will be stored
LOG_DIR="logs"

# Minimum log level to display (DEBUG=0, INFO=1, WARN=2, ERROR=3, FAIL=4)
# Messages below this level will not be displayed or logged
MIN_LOG_LEVEL=0

# Log file format: timestamp + extension
# Format: YYYYMMDD-HHMMSS
TIMESTAMP_FORMAT=$(date +"%Y%m%d-%H%M%S")

# Enable/disable colored output (true/false)
ENABLE_COLORS=true

# Enable/disable emoji in logs (true/false)
ENABLE_EMOJIS=true

# =============================================================================
# COLOR CODES
# =============================================================================

if [[ "$ENABLE_COLORS" == "true" ]]; then
    # ANSI color codes
    COLOR_DEBUG='\033[0;36m'    # Cyan
    COLOR_INFO='\033[0;32m'     # Green
    COLOR_WARN='\033[0;33m'     # Yellow
    COLOR_ERROR='\033[0;31m'    # Red
    COLOR_FAIL='\033[1;31m'     # Bold Red
    COLOR_RESET='\033[0m'       # Reset
else
    # Empty color codes if colors are disabled
    COLOR_DEBUG=''
    COLOR_INFO=''
    COLOR_WARN=''
    COLOR_ERROR=''
    COLOR_FAIL=''
    COLOR_RESET=''
fi

# =============================================================================
# EMOJI CODES
# =============================================================================

if [[ "$ENABLE_EMOJIS" == "true" ]]; then
    EMOJI_DEBUG="🔍"      # Magnifying glass
    EMOJI_INFO="ℹ️"       # Information
    EMOJI_WARN="⚠️"       # Warning
    EMOJI_ERROR="❌"      # Cross mark
    EMOJI_FAIL="🔥"       # Fire
else
    # Empty emoji codes if emojis are disabled
    EMOJI_DEBUG=''
    EMOJI_INFO=''
    EMOJI_WARN=''
    EMOJI_ERROR=''
    EMOJI_FAIL=''
fi

# =============================================================================
# LOG LEVELS
# =============================================================================

# Log level constants
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3
LOG_LEVEL_FAIL=4

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Create log directory if it doesn't exist
create_log_dir() {
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR" 2>/dev/null || {
            printf "Failed to create log directory: %s\n" "$LOG_DIR" >&2
            return 1
        }
    fi
    return 0
}

# Get current timestamp in ISO 8601 format
get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Get timestamp for log entries (using the same format as filenames)
get_log_timestamp() {
    date +"%Y%m%d-%H%M%S"
}

# Check if a log level should be displayed based on MIN_LOG_LEVEL
should_log() {
    local level=$1
    [[ $level -ge $MIN_LOG_LEVEL ]]
}

# =============================================================================
# CORE LOGGING FUNCTIONS
# =============================================================================

# Generic logging function that handles all log levels
# Usage: _log <level> <level_name> <color> <emoji> <message>
_log() {
    local level=$1
    local level_name=$2
    local color=$3
    local emoji=$4
    local message=$5

    # Check if we should log this level
    if ! should_log "$level"; then
        return 0
    fi

    # Ensure log directory exists
    create_log_dir || return 1

    # Get current timestamp for log entries
    local timestamp
    timestamp=$(get_log_timestamp)

    # Format the message
    local formatted_message="${emoji} [${timestamp}] [${level_name}] ${message}"

    # Determine output file based on level
    local output_file=""
    case $level in
        "$LOG_LEVEL_DEBUG"|"$LOG_LEVEL_INFO")
            output_file="${LOG_DIR}/${TIMESTAMP_FORMAT}.info.log"
            ;;
        "$LOG_LEVEL_WARN")
            output_file="${LOG_DIR}/${TIMESTAMP_FORMAT}.warn.log"
            ;;
        "$LOG_LEVEL_ERROR"|"$LOG_LEVEL_FAIL")
            output_file="${LOG_DIR}/${TIMESTAMP_FORMAT}.fail.log"
            ;;
    esac

    # Main log file (all levels)
    local main_log_file="${LOG_DIR}/${TIMESTAMP_FORMAT}.main.log"

    # Output to console with colors
    printf "%s%s%s\n" "${color}" "${formatted_message}" "${COLOR_RESET}"

    # Output to main log file (without colors)
    printf "%s\n" "$formatted_message" >> "$main_log_file" 2>/dev/null

    # Output to level-specific log file (without colors)
    if [[ -n "$output_file" ]]; then
        printf "%s\n" "$formatted_message" >> "$output_file" 2>/dev/null
    fi
}

# =============================================================================
# PUBLIC LOGGING FUNCTIONS
# =============================================================================

# Debug level logging
# Usage: debug "Your debug message"
debug() {
    _log $LOG_LEVEL_DEBUG "DEBUG" "$COLOR_DEBUG" "$EMOJI_DEBUG" "$1"
}

# Info level logging
# Usage: info "Your info message"
info() {
    _log $LOG_LEVEL_INFO "INFO" "$COLOR_INFO" "$EMOJI_INFO" "$1"
}

# General log function (same as info)
# Usage: log "Your log message"
log() {
    _log $LOG_LEVEL_INFO "LOG" "$COLOR_INFO" "$EMOJI_INFO" "$1"
}

# Warning level logging
# Usage: warn "Your warning message"
warn() {
    _log $LOG_LEVEL_WARN "WARN" "$COLOR_WARN" "$EMOJI_WARN" "$1"
}

# Error level logging
# Usage: error "Your error message"
error() {
    _log $LOG_LEVEL_ERROR "ERROR" "$COLOR_ERROR" "$EMOJI_ERROR" "$1"
}

# Fail level logging (outputs to stderr)
# Usage: fail "Your failure message"
fail() {
    local message="$1"

    # Check if we should log this level
    if ! should_log $LOG_LEVEL_FAIL; then
        return 0
    fi

    # Ensure log directory exists
    create_log_dir || return 1

    # Get current timestamp for log entries
    local timestamp
    timestamp=$(get_log_timestamp)

    # Format the message
    local formatted_message="${EMOJI_FAIL} [${timestamp}] [FAIL] ${message}"

    # Output file for fail logs
    local output_file="${LOG_DIR}/${TIMESTAMP_FORMAT}.fail.log"

    # Main log file (all levels)
    local main_log_file="${LOG_DIR}/${TIMESTAMP_FORMAT}.main.log"

    # Output to stderr with colors
    printf "%s%s%s\n" "${COLOR_FAIL}" "${formatted_message}" "${COLOR_RESET}" >&2

    # Output to main log file (without colors)
    printf "%s\n" "$formatted_message" >> "$main_log_file" 2>/dev/null

    # Output to fail log file (without colors)
    printf "%s\n" "$formatted_message" >> "$output_file" 2>/dev/null
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Set minimum log level
# Usage: set_log_level <level>
# Levels: DEBUG, INFO, WARN, ERROR, FAIL
set_log_level() {
    local level_name
    level_name=$(echo "$1" | tr '[:lower:]' '[:upper:]')

    case $level_name in
        "DEBUG")
            MIN_LOG_LEVEL=$LOG_LEVEL_DEBUG
            ;;
        "INFO")
            MIN_LOG_LEVEL=$LOG_LEVEL_INFO
            ;;
        "WARN")
            MIN_LOG_LEVEL=$LOG_LEVEL_WARN
            ;;
        "ERROR")
            MIN_LOG_LEVEL=$LOG_LEVEL_ERROR
            ;;
        "FAIL")
            MIN_LOG_LEVEL=$LOG_LEVEL_FAIL
            ;;
        *)
            error "Invalid log level: $1. Valid levels: DEBUG, INFO, WARN, ERROR, FAIL"
            return 1
            ;;
    esac

    debug "Log level set to: $level_name"
}

# Enable or disable colors
# Usage: set_colors <true|false>
set_colors() {
    if [[ "$1" == "true" ]]; then
        ENABLE_COLORS=true
        # Reinitialize colors
        COLOR_DEBUG='\033[0;36m'
        COLOR_INFO='\033[0;32m'
        COLOR_WARN='\033[0;33m'
        COLOR_ERROR='\033[0;31m'
        COLOR_FAIL='\033[1;31m'
        COLOR_RESET='\033[0m'
        debug "Colors enabled"
    else
        ENABLE_COLORS=false
        # Clear color codes
        COLOR_DEBUG=''
        COLOR_INFO=''
        COLOR_WARN=''
        COLOR_ERROR=''
        COLOR_FAIL=''
        COLOR_RESET=''
        debug "Colors disabled"
    fi
}

# Enable or disable emojis
# Usage: set_emojis <true|false>
set_emojis() {
    if [[ "$1" == "true" ]]; then
        ENABLE_EMOJIS=true
        EMOJI_DEBUG="🔍"
        EMOJI_INFO="ℹ️"
        EMOJI_WARN="⚠️"
        EMOJI_ERROR="❌"
        EMOJI_FAIL="🔥"
        debug "Emojis enabled"
    else
        ENABLE_EMOJIS=false
        EMOJI_DEBUG=''
        EMOJI_INFO=''
        EMOJI_WARN=''
        EMOJI_ERROR=''
        EMOJI_FAIL=''
        debug "Emojis disabled"
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize the logging system
init_logging() {
    create_log_dir

    # Set up signal handlers to ensure logs are flushed on exit
    trap 'debug "Logging system exiting"' EXIT

    debug "Logging system initialized"
    debug "Log directory: $LOG_DIR"
    debug "Minimum log level: $MIN_LOG_LEVEL"
    debug "Colors: $ENABLE_COLORS"
    debug "Emojis: $ENABLE_EMOJIS"
}

# Auto-initialize when script is sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced
    init_logging
fi
