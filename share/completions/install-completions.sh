#!/usr/bin/env bash
# Installation script for vm and vm-create shell completions

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

usage() {
    cat <<EOF
Install shell completions for vm and vm-create scripts

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --bash              Install bash completions only
    --zsh               Install zsh completions only
    --system            Install system-wide (requires sudo)
    --user              Install for current user only (default)
    --help, -h          Show this help

EXAMPLES:
    $0                  # Install both bash and zsh completions for current user
    $0 --bash --user    # Install bash completions for current user
    $0 --zsh --system   # Install zsh completions system-wide
    $0 --system         # Install both completions system-wide

EOF
}

install_bash_completions() {
    local install_type="$1"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ "$install_type" == "system" ]]; then
        log_info "Installing bash completions system-wide..."

        if [[ ! -d "/etc/bash_completion.d" ]]; then
            log_error "System bash completion directory not found. Please install bash-completion package."
            return 1
        fi

        sudo cp "$script_dir/vm.bash" /etc/bash_completion.d/vm
        sudo cp "$script_dir/vm-create.bash" /etc/bash_completion.d/vm-create
        sudo cp "$script_dir/ivm.bash" /etc/bash_completion.d/ivm
        sudo cp "$script_dir/ivm-create.bash" /etc/bash_completion.d/ivm-create
        sudo cp "$script_dir/ict.bash" /etc/bash_completion.d/ict
        sudo cp "$script_dir/ict-create.bash" /etc/bash_completion.d/ict-create

        log_success "Bash completions installed system-wide"
        log_info "Run 'source /etc/bash_completion' or restart your shell"

    else
        log_info "Installing bash completions for current user..."

        local completion_dir="$HOME/.local/share/bash-completion/completions"
        mkdir -p "$completion_dir"

        cp "$script_dir/vm.bash" "$completion_dir/vm"
        cp "$script_dir/vm-create.bash" "$completion_dir/vm-create"
        cp "$script_dir/ivm.bash" "$completion_dir/ivm"
        cp "$script_dir/ivm-create.bash" "$completion_dir/ivm-create"
        cp "$script_dir/ict.bash" "$completion_dir/ict"
        cp "$script_dir/ict-create.bash" "$completion_dir/ict-create"

        # Add to bashrc if not already present
        local bashrc="$HOME/.bashrc"
        if [[ -f "$bashrc" ]]; then
            if ! grep -q "source.*bash-completion.*vm" "$bashrc"; then
                {
                    echo ""
                    echo "# VM and container script completions"
                    echo "source ~/.local/share/bash-completion/completions/vm"
                    echo "source ~/.local/share/bash-completion/completions/vm-create"
                    echo "source ~/.local/share/bash-completion/completions/ivm"
                    echo "source ~/.local/share/bash-completion/completions/ivm-create"
                    echo "source ~/.local/share/bash-completion/completions/ict"
                    echo "source ~/.local/share/bash-completion/completions/ict-create"
                } >>"$bashrc"
                log_info "Added completion sources to ~/.bashrc"
            fi
        fi

        log_success "Bash completions installed for current user"
        log_info "Run 'source ~/.bashrc' or restart your shell"
    fi
}

install_zsh_completions() {
    local install_type="$1"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ "$install_type" == "system" ]]; then
        log_info "Installing zsh completions system-wide..."

        local system_dir="/usr/share/zsh/site-functions"
        if [[ ! -d "$system_dir" ]]; then
            system_dir="/usr/local/share/zsh/site-functions"
            sudo mkdir -p "$system_dir"
        fi

        sudo cp "$script_dir/_vm" "$system_dir/_vm"
        sudo cp "$script_dir/_vm-create" "$system_dir/_vm-create"
        sudo cp "$script_dir/_ivm" "$system_dir/_ivm"
        sudo cp "$script_dir/_ivm-create" "$system_dir/_ivm-create"
        sudo cp "$script_dir/_ict" "$system_dir/_ict"
        sudo cp "$script_dir/_ict-create" "$system_dir/_ict-create"

        log_success "Zsh completions installed system-wide"
        log_info "Run 'autoload -U compinit && compinit' or restart your shell"

    else
        log_info "Installing zsh completions for current user..."

        local completion_dir="$HOME/.local/share/zsh/site-functions"
        mkdir -p "$completion_dir"

        cp "$script_dir/_vm" "$completion_dir/_vm"
        cp "$script_dir/_vm-create" "$completion_dir/_vm-create"
        cp "$script_dir/_ivm" "$completion_dir/_ivm"
        cp "$script_dir/_ivm-create" "$completion_dir/_ivm-create"
        cp "$script_dir/_ict" "$completion_dir/_ict"
        cp "$script_dir/_ict-create" "$completion_dir/_ict-create"

        # Add to zshrc if not already present
        local zshrc="$HOME/.zshrc"
        if [[ -f "$zshrc" ]]; then
            if ! grep -q "fpath.*zsh/site-functions" "$zshrc"; then
                {
                    echo ""
                    echo "# VM and container script completions"
                    echo "fpath=(~/.local/share/zsh/site-functions \$fpath)"
                    echo "autoload -U compinit && compinit"
                } >>"$zshrc"
                log_info "Added completion setup to ~/.zshrc"
            fi
        fi

        log_success "Zsh completions installed for current user"
        log_info "Run 'source ~/.zshrc' or restart your shell"
    fi
}

main() {
    local install_bash=false
    local install_zsh=false
    local install_type="user"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --bash)
            install_bash=true
            shift
            ;;
        --zsh)
            install_zsh=true
            shift
            ;;
        --system)
            install_type="system"
            shift
            ;;
        --user)
            install_type="user"
            shift
            ;;
        --help | -h)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
        esac
    done

    # If no specific shell specified, install both
    if [[ "$install_bash" == false && "$install_zsh" == false ]]; then
        install_bash=true
        install_zsh=true
    fi

    log_info "Installing completions for vm, vm-create, ivm, ivm-create, ict, and ict-create scripts..."

    if [[ "$install_bash" == true ]]; then
        install_bash_completions "$install_type"
    fi

    if [[ "$install_zsh" == true ]]; then
        install_zsh_completions "$install_type"
    fi

    echo
    log_success "Installation complete!"
    log_info "Test the completions by typing 'vm <TAB>', 'ivm <TAB>', or 'ivm-create --<TAB>'"
}

main "$@"
