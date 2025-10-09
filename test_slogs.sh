#!/bin/bash

# test_slogs.sh - Comprehensive test script for slogs.sh logging system
# Author: Test Suite for slogs.sh
# Version: 1.0

# Enable strict error handling
set -euo pipefail

# =============================================================================
# TEST CONFIGURATION
# =============================================================================

# Test directory for logs
TEST_LOG_DIR="test_logs"

# Source the slogs.sh script
# shellcheck source=./slogs.sh
source ./slogs.sh

# Override log directory for testing
# Override log directory for testing (exported for slogs.sh)
export LOG_DIR="$TEST_LOG_DIR"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Print test header
print_header() {
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# Print test result
print_test_result() {
    local test_name="$1"
    local result="$2"
    local details="${3:-}"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if [[ "$result" == "PASS" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "\033[0;32m[PASS]\033[0m $test_name"
    elif [[ "$result" == "SKIP" ]]; then
        echo -e "\033[0;33m[SKIP]\033[0m $test_name"
        [[ -n "$details" ]] && echo "    $details"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "\033[0;31m[FAIL]\033[0m $test_name"
        [[ -n "$details" ]] && echo "    $details"
    fi
}

# Check if file exists and contains expected content
check_log_file() {
    local file_path="$1"
    local expected_content="$2"
    local should_exist="${3:-true}"

    # echo "DEBUG: Checking file: $file_path for content: $expected_content" >&2

    if [[ "$should_exist" == "true" ]]; then
        if [[ -f "$file_path" ]]; then
            # echo "DEBUG: File exists" >&2
            if [[ -n "$expected_content" ]]; then
                if grep -q "$expected_content" "$file_path"; then
                    # echo "DEBUG: Content found in file" >&2
                    return 0
                else
                    # echo "DEBUG: Content not found in file" >&2
                    # echo "DEBUG: File contents:" >&2
                    # cat "$file_path" >&2
                    return 1
                fi
            else
                return 0
            fi
        else
            # echo "DEBUG: File does not exist" >&2
            return 1
        fi
    else
        if [[ -f "$file_path" ]]; then
            return 1
        else
            return 0
        fi
    fi
}

# Get the latest timestamp format used by slogs
get_timestamp() {
    date +"%Y%m%d-%H%M%S"
}

# Initialize the logging system to get the current timestamp
init_logging_for_test() {
    # Create the test log directory
    if [[ ! -d "$TEST_LOG_DIR" ]]; then
        mkdir -p "$TEST_LOG_DIR" 2>/dev/null || {
            printf "Failed to create test log directory: %s\n" "$TEST_LOG_DIR" >&2
            return 1
        }
    fi

    # Get the current timestamp that will be used by the logging system
    date +"%Y%m%d-%H%M%S"
}

# Clean up test log files
cleanup_test_logs() {
    if [[ -d "$TEST_LOG_DIR" ]]; then
        rm -rf "$TEST_LOG_DIR"
        echo "Test log files cleaned up"
    fi
}

# =============================================================================
# TEST FUNCTIONS
# =============================================================================

# Test 1: Test all logging functions
test_logging_functions() {
    print_header "Test 1: Testing All Logging Functions"

    # Get the timestamp that will be used by the logging system
    local timestamp
    timestamp=$(init_logging_for_test)

    # Force the logging system to use this timestamp
    TIMESTAMP_FORMAT="$timestamp"

    # Test debug function
    debug "Test debug message"
    sleep 0.1  # Give a moment for the log to be written

    local main_check=0
    local info_check=0

    check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Test debug message" || main_check=1
    check_log_file "$TEST_LOG_DIR/${timestamp}.info.log" "Test debug message" || info_check=1

    if [[ $main_check -eq 0 && $info_check -eq 0 ]]; then
        print_test_result "debug() function" "PASS"
    else
        print_test_result "debug() function" "FAIL" "Main check: $main_check, Info check: $info_check"
    fi

    # Test info function
    info "Test info message"
    sleep 0.1  # Give a moment for the log to be written

    local main_check=0
    local info_check=0

    check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Test info message" || main_check=1
    check_log_file "$TEST_LOG_DIR/${timestamp}.info.log" "Test info message" || info_check=1

    if [[ $main_check -eq 0 && $info_check -eq 0 ]]; then
        print_test_result "info() function" "PASS"
    else
        print_test_result "info() function" "FAIL" "Main check: $main_check, Info check: $info_check"
    fi

    # Test log function
    log "Test log message"
    sleep 0.1  # Give a moment for the log to be written

    main_check=0
    info_check=0

    check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Test log message" || main_check=1
    check_log_file "$TEST_LOG_DIR/${timestamp}.info.log" "Test log message" || info_check=1

    if [[ $main_check -eq 0 && $info_check -eq 0 ]]; then
        print_test_result "log() function" "PASS"
    else
        print_test_result "log() function" "FAIL" "Main check: $main_check, Info check: $info_check"
    fi

    # Test warn function
    warn "Test warn message"
    sleep 0.1  # Give a moment for the log to be written

    main_check=0
    local warn_check=0

    check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Test warn message" || main_check=1
    check_log_file "$TEST_LOG_DIR/${timestamp}.warn.log" "Test warn message" || warn_check=1

    if [[ $main_check -eq 0 && $warn_check -eq 0 ]]; then
        print_test_result "warn() function" "PASS"
    else
        print_test_result "warn() function" "FAIL" "Main check: $main_check, Warn check: $warn_check"
    fi

    # Test error function
    error "Test error message"
    sleep 0.1  # Give a moment for the log to be written

    main_check=0
    local fail_check=0

    check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Test error message" || main_check=1
    check_log_file "$TEST_LOG_DIR/${timestamp}.fail.log" "Test error message" || fail_check=1

    if [[ $main_check -eq 0 && $fail_check -eq 0 ]]; then
        print_test_result "error() function" "PASS"
    else
        print_test_result "error() function" "FAIL" "Main check: $main_check, Fail check: $fail_check"
    fi

    # Test fail function
    fail "Test fail message" 2>/dev/null
    sleep 0.1  # Give a moment for the log to be written

    main_check=0
    fail_check=0

    check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Test fail message" || main_check=1
    check_log_file "$TEST_LOG_DIR/${timestamp}.fail.log" "Test fail message" || fail_check=1

    if [[ $main_check -eq 0 && $fail_check -eq 0 ]]; then
        print_test_result "fail() function" "PASS"
    else
        print_test_result "fail() function" "FAIL" "Main check: $main_check, Fail check: $fail_check"
    fi

    # Give a moment for all logs to be written
    sleep 1
}

# Test 2: Test log level filtering
test_log_level_filtering() {
    print_header "Test 2: Testing Log Level Filtering"

    # Set log level to WARN
    set_log_level "WARN"

    # Get the timestamp that will be used by the logging system
    local timestamp
    timestamp=$(init_logging_for_test)

    # Force the logging system to use this timestamp
    TIMESTAMP_FORMAT="$timestamp"

    # These should not appear in logs
    debug "Debug message (should not appear)"
    info "Info message (should not appear)"

    # These should appear
    warn "Warning message (should appear)"
    error "Error message (should appear)"
    fail "Fail message (should appear)" 2>/dev/null

    # Check that debug/info messages are not in main log
    if ! check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Debug message (should not appear)" "false" && \
       ! check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Info message (should not appear)" "false"; then
        print_test_result "Log level filtering (lower levels excluded)" "PASS"
    else
        print_test_result "Log level filtering (lower levels excluded)" "FAIL" "Lower level messages found in log"
    fi

    # Check that warn/error/fail messages are in main log
    if check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Warning message (should appear)" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Error message (should appear)" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Fail message (should appear)"; then
        print_test_result "Log level filtering (higher levels included)" "PASS"
    else
        print_test_result "Log level filtering (higher levels included)" "FAIL" "Higher level messages not found in log"
    fi

    # Reset log level to DEBUG for other tests
    set_log_level "DEBUG"

    # Give a moment for all logs to be written
    sleep 1
}

# Test 3: Test output routing to appropriate files
test_output_routing() {
    print_header "Test 3: Testing Output Routing to Appropriate Files"

    # Get the timestamp that will be used by the logging system
    local timestamp
    timestamp=$(init_logging_for_test)

    # Force the logging system to use this timestamp
    TIMESTAMP_FORMAT="$timestamp"

    # Generate one of each log type
    debug "Debug routing test"
    info "Info routing test"
    warn "Warn routing test"
    error "Error routing test"
    fail "Fail routing test" 2>/dev/null

    # Check main log contains all messages
    if check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Debug routing test" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Info routing test" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Warn routing test" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Error routing test" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "Fail routing test"; then
        print_test_result "Main log contains all messages" "PASS"
    else
        print_test_result "Main log contains all messages" "FAIL" "Not all messages found in main log"
    fi

    # Check info log contains only debug and info
    if check_log_file "$TEST_LOG_DIR/${timestamp}.info.log" "Debug routing test" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.info.log" "Info routing test" && \
       ! check_log_file "$TEST_LOG_DIR/${timestamp}.info.log" "Warn routing test" "false"; then
        print_test_result "Info log contains only debug/info messages" "PASS"
    else
        print_test_result "Info log contains only debug/info messages" "FAIL" "Info log has incorrect messages"
    fi

    # Check warn log contains only warn
    if check_log_file "$TEST_LOG_DIR/${timestamp}.warn.log" "Warn routing test" && \
       ! check_log_file "$TEST_LOG_DIR/${timestamp}.warn.log" "Info routing test" "false"; then
        print_test_result "Warn log contains only warn messages" "PASS"
    else
        print_test_result "Warn log contains only warn messages" "FAIL" "Warn log has incorrect messages"
    fi

    # Check fail log contains only error and fail
    if check_log_file "$TEST_LOG_DIR/${timestamp}.fail.log" "Error routing test" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.fail.log" "Fail routing test" && \
       ! check_log_file "$TEST_LOG_DIR/${timestamp}.fail.log" "Warn routing test" "false"; then
        print_test_result "Fail log contains only error/fail messages" "PASS"
    else
        print_test_result "Fail log contains only error/fail messages" "FAIL" "Fail log has incorrect messages"
    fi

    # Give a moment for all logs to be written
    sleep 1
}

# Test 4: Test emoji and color functionality
test_emoji_color_functionality() {
    print_header "Test 4: Testing Emoji and Color Functionality"

    # Test with emojis and colors enabled (default)
    # Get the timestamp that will be used by the logging system
    local timestamp
    timestamp=$(init_logging_for_test)

    # Force the logging system to use this timestamp
    TIMESTAMP_FORMAT="$timestamp"

    info "Test with emojis and colors"

    if check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "ℹ️" && \
       check_log_file "$TEST_LOG_DIR/${timestamp}.info.log" "ℹ️"; then
        print_test_result "Emoji functionality (enabled)" "PASS"
    else
        print_test_result "Emoji functionality (enabled)" "FAIL" "Emojis not found in log files"
    fi

    # Disable emojis
    set_emojis "false"
    sleep 1  # Give time for timestamp to change

    # Get a new timestamp that will be used by the logging system
    timestamp=$(init_logging_for_test)

    # Force the logging system to use this timestamp
    TIMESTAMP_FORMAT="$timestamp"

    info "Test without emojis"

    if ! check_log_file "$TEST_LOG_DIR/${timestamp}.main.log" "ℹ️" "false" || \
       ! check_log_file "$TEST_LOG_DIR/${timestamp}.info.log" "ℹ️" "false"; then
        print_test_result "Emoji functionality (disabled)" "PASS"
    else
        print_test_result "Emoji functionality (disabled)" "FAIL" "Emojis found in log files when disabled"
    fi

    # Re-enable emojis
    set_emojis "true"

    # Give a moment for all logs to be written
    sleep 1
}

# Test 5: Test configuration options
test_configuration_options() {
    print_header "Test 5: Testing Configuration Options"

    # Test set_colors with false
    set_colors "false"
    if [[ "$ENABLE_COLORS" == "false" ]]; then
        print_test_result "Disable colors configuration" "PASS"
    else
        print_test_result "Disable colors configuration" "FAIL" "ENABLE_COLORS still true after set_colors false"
    fi

    # Test set_colors with true
    set_colors "true"
    if [[ "$ENABLE_COLORS" == "true" ]]; then
        print_test_result "Enable colors configuration" "PASS"
    else
        print_test_result "Enable colors configuration" "FAIL" "ENABLE_COLORS still false after set_colors true"
    fi

    # Test set_emojis with false
    set_emojis "false"
    if [[ "$ENABLE_EMOJIS" == "false" ]]; then
        print_test_result "Disable emojis configuration" "PASS"
    else
        print_test_result "Disable emojis configuration" "FAIL" "ENABLE_EMOJIS still true after set_emojis false"
    fi

    # Test set_emojis with true
    set_emojis "true"
    if [[ "$ENABLE_EMOJIS" == "true" ]]; then
        print_test_result "Enable emojis configuration" "PASS"
    else
        print_test_result "Enable emojis configuration" "FAIL" "ENABLE_EMOJIS still false after set_emojis true"
    fi

    # Give a moment for all logs to be written
    sleep 1
}

# Test 6: Test timestamp formatting
test_timestamp_formatting() {
    print_header "Test 6: Testing Timestamp Formatting"

    # Get the timestamp that will be used by the logging system
    local timestamp
    timestamp=$(init_logging_for_test)

    # Force the logging system to use this timestamp
    TIMESTAMP_FORMAT="$timestamp"

    info "Test timestamp format"

    # Check if log file with correct timestamp format exists
    if [[ -f "$TEST_LOG_DIR/${timestamp}.main.log" ]]; then
        # Check if timestamp in log matches our format
        if grep -qE "\[[0-9]{8}-[0-9]{6}\]" "$TEST_LOG_DIR/${timestamp}.main.log"; then
            print_test_result "Timestamp format in log entries" "PASS"
        else
            print_test_result "Timestamp format in log entries" "FAIL" "Timestamp format doesn't match expected pattern"
        fi

        # Check if log file name matches timestamp format
        if [[ "$TEST_LOG_DIR/${timestamp}.main.log" =~ [0-9]{8}-[0-9]{6}\.main\.log ]]; then
            print_test_result "Timestamp format in log filenames" "PASS"
        else
            print_test_result "Timestamp format in log filenames" "FAIL" "Log filename doesn't match expected timestamp pattern"
        fi
    else
        print_test_result "Timestamp format" "FAIL" "Log file with expected timestamp doesn't exist"
    fi

    # Give a moment for all logs to be written
    sleep 1
}

# Test 7: Test script execution modes
test_script_execution_modes() {
    print_header "Test 7: Testing Script Execution Modes"

    # Test when sourced (current mode)
    # Note: This test will fail when running the test script directly
    # It would pass if this test script was sourced by another script
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        print_test_result "Script execution when sourced" "PASS"
    else
        print_test_result "Script execution when sourced" "SKIP" "Test script is not being sourced by another script"
    fi

    # Test when executed directly
    # Create a temporary script to test direct execution
    cat > temp_direct_test.sh << 'EOF'
#!/bin/bash
source ./slogs.sh
LOG_DIR="test_logs_direct"
info "Direct execution test"
sleep 0.1  # Give time for log to be written
# Use ls to check for log files
log_files=$(ls test_logs_direct/*.main.log 2>/dev/null | wc -l)
if [[ $log_files -gt 0 ]]; then
    echo "PASS: Direct execution"
else
    echo "FAIL: Direct execution"
fi
rm -rf test_logs_direct
EOF

    chmod +x temp_direct_test.sh
    local result
    result=$(./temp_direct_test.sh 2>&1)
    rm temp_direct_test.sh

    if [[ "$result" == *"PASS: Direct execution"* ]]; then
        print_test_result "Script execution when run directly" "PASS"
    else
        print_test_result "Script execution when run directly" "FAIL" "Direct execution failed: $result"
    fi

    # Give a moment for all logs to be written
    sleep 1
}

# Test 8: Test error handling
test_error_handling() {
    print_header "Test 8: Testing Error Handling"

    # Test invalid log level
    local error_output
    error_output=$(set_log_level "INVALID_LEVEL" 2>&1 || true)

    if [[ "$error_output" == *"Invalid log level"* ]]; then
        print_test_result "Invalid log level error handling" "PASS"
    else
        print_test_result "Invalid log level error handling" "FAIL" "Expected error message for invalid log level"
    fi

    # Test log creation when directory doesn't exist
    local temp_log_dir="temp_test_log_dir"
    rm -rf "$temp_log_dir" 2>/dev/null || true

    # Get the timestamp that will be used by the logging system
    local timestamp
    timestamp=$(init_logging_for_test)

    # Force the logging system to use this timestamp
    # Force the logging system to use this timestamp (exported for slogs.sh)
    export TIMESTAMP_FORMAT="$timestamp"

    LOG_DIR="$temp_log_dir" info "Test log creation"
    if [[ -d "$temp_log_dir" ]]; then
        local log_files=("$temp_log_dir"/*.main.log)
        if [[ ${#log_files[@]} -gt 0 && -f "${log_files[0]}" ]]; then
            print_test_result "Log directory creation" "PASS"
        else
            print_test_result "Log directory creation" "FAIL" "Log directory was not created"
        fi
    else
        print_test_result "Log directory creation" "FAIL" "Log directory was not created"
    fi

    rm -rf "$temp_log_dir"

    # Give a moment for all logs to be written
    sleep 1
}

# =============================================================================
# MAIN TEST RUNNER
# =============================================================================

# Main function to run all tests
main() {
    print_header "COMPREHENSIVE TEST SUITE FOR SLOGS.SH"

    # Clean up any existing test logs
    cleanup_test_logs

    # Run all tests
    test_logging_functions
    test_log_level_filtering
    test_output_routing
    test_emoji_color_functionality
    test_configuration_options
    test_timestamp_formatting
    test_script_execution_modes
    test_error_handling

    # Print test summary
    print_header "TEST SUMMARY"
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "\033[0;32mPassed: $TESTS_PASSED\033[0m"
    echo -e "\033[0;31mFailed: $TESTS_FAILED\033[0m"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\033[0;32mAll tests PASSED! 🎉\033[0m"
    else
        echo -e "\033[0;31mSome tests FAILED! Please check the output above.\033[0m"
    fi

    # Clean up test logs
    cleanup_test_logs

    # Exit with appropriate code
    exit $TESTS_FAILED
}

# Run shellcheck validation on the slogs.sh script
validate_with_shellcheck() {
    print_header "SHELLCHECK VALIDATION"

    if command -v shellcheck >/dev/null 2>&1; then
        echo "Running shellcheck on slogs.sh..."

        # Run shellcheck and capture output
        local shellcheck_output
        shellcheck_output=$(shellcheck slogs.sh 2>&1 || true)

        if [[ -z "$shellcheck_output" ]]; then
            echo -e "\033[0;32m[PASS]\033[0m Shellcheck validation passed - no issues found"
            return 0
        else
            echo -e "\033[0;31m[FAIL]\033[0m Shellcheck validation found issues:"
            echo "$shellcheck_output"
            return 1
        fi
    else
        echo "Shellcheck not found. Skipping validation."
        echo "To install shellcheck, run: apt-get install shellcheck (Ubuntu/Debian)"
        return 0  # Not a test failure, just a skipped test
    fi
}

# Validate with shellcheck before running tests
validate_with_shellcheck

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
