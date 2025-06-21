#!/usr/bin/env bash
# Test script for vm and vm-create completions
# shellcheck disable=SC1091  # Don't follow sourced completion files

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

test_bash_completion() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    log_info "Testing bash completions..."

    # Source the completion scripts
    source "$script_dir/vm.bash"
    source "$script_dir/vm-create.bash"

    # Test if completion functions are registered
    if complete -p vm >/dev/null 2>&1; then
        log_success "vm completion function registered"
    else
        log_error "vm completion function not registered"
        return 1
    fi

    if complete -p vm-create >/dev/null 2>&1; then
        log_success "vm-create completion function registered"
    else
        log_error "vm-create completion function not registered"
        return 1
    fi

    # Test completion function exists
    if declare -f _vm_completion >/dev/null 2>&1; then
        log_success "_vm_completion function exists"
    else
        log_error "_vm_completion function not found"
        return 1
    fi

    if declare -f _vm_create_completion >/dev/null 2>&1; then
        log_success "_vm_create_completion function exists"
    else
        log_error "_vm_create_completion function not found"
        return 1
    fi

    log_success "Bash completions test passed"
}

test_zsh_completion() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    log_info "Testing zsh completions..."

    # Check if zsh completion files exist and are readable
    if [[ -r "$script_dir/_vm" ]]; then
        log_success "_vm zsh completion file exists and is readable"
    else
        log_error "_vm zsh completion file not found or not readable"
        return 1
    fi

    if [[ -r "$script_dir/_vm-create" ]]; then
        log_success "_vm-create zsh completion file exists and is readable"
    else
        log_error "_vm-create zsh completion file not found or not readable"
        return 1
    fi

    # Basic syntax check for zsh files
    if grep -q "#compdef vm" "$script_dir/_vm"; then
        log_success "_vm has correct compdef directive"
    else
        log_error "_vm missing or incorrect compdef directive"
        return 1
    fi

    if grep -q "#compdef vm-create" "$script_dir/_vm-create"; then
        log_success "_vm-create has correct compdef directive"
    else
        log_error "_vm-create missing or incorrect compdef directive"
        return 1
    fi

    log_success "Zsh completions test passed"
}

test_completion_content() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    log_info "Testing completion content..."

    # Test that bash completions contain expected commands
    if grep -q "install list status create autostart start stop restart destroy delete console ip logs cleanup ssh" "$script_dir/vm.bash"; then
        log_success "vm.bash contains expected commands"
    else
        log_error "vm.bash missing expected commands"
        return 1
    fi

    # Test that vm-create completions contain expected options
    if grep -q "\-\-distro \-\-name \-\-memory \-\-vcpus \-\-disk-size" "$script_dir/vm-create.bash"; then
        log_success "vm-create.bash contains expected options"
    else
        log_error "vm-create.bash missing expected options"
        return 1
    fi

    # Test that zsh completions contain expected content
    if grep -q "_arguments" "$script_dir/_vm" && grep -q "_describe" "$script_dir/_vm"; then
        log_success "_vm contains expected zsh completion functions"
    else
        log_error "_vm missing expected zsh completion functions"
        return 1
    fi

    if grep -q "_arguments" "$script_dir/_vm-create"; then
        log_success "_vm-create contains expected zsh completion functions"
    else
        log_error "_vm-create missing expected zsh completion functions"
        return 1
    fi

    log_success "Completion content test passed"
}

main() {
    log_info "Running completion tests..."
    echo

    test_bash_completion
    echo

    test_zsh_completion
    echo

    test_completion_content
    echo

    log_success "All tests passed!"
    echo
    log_info "To install completions, run: ./install-completions.sh"
    log_info "To test manually:"
    echo "  Bash: source vm.bash && vm <TAB>"
    echo "  Zsh:  Add _vm to fpath and run: vm <TAB>"
}

main "$@"
