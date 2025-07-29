#!/bin/bash

# Fedora 42 Custom ISO Builder with Btrfs and Snapper
# Usage: ./build-fedora42-custom-iso.sh [method]
# Methods: mkksiso (default), livemedia-creator, manual

set -e

# Configuration
FEDORA_VERSION="42"
KICKSTART_FILE="fedora42-btrfs-snapper.ks"
INPUT_ISO="Fedora-${FEDORA_VERSION}-x86_64-netinst.iso"
OUTPUT_ISO="Fedora-${FEDORA_VERSION}-Custom-Btrfs-Snapper.iso"
WORK_DIR="$(pwd)/iso_work"
BUILD_METHOD="${1:-mkksiso}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    print_status "Checking dependencies..."

    local deps=()
    case $BUILD_METHOD in
        "mkksiso")
            deps=("mkksiso" "curl" "sha256sum")
            ;;
        "livemedia-creator")
            deps=("livemedia-creator" "curl" "sha256sum")
            ;;
        "manual")
            deps=("xorriso" "curl" "sha256sum" "unsquashfs" "mksquashfs")
            ;;
    esac

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            print_error "Missing dependency: $dep"
            case $dep in
                "mkksiso"|"livemedia-creator")
                    echo "Install with: sudo dnf install lorax"
                    ;;
                "xorriso")
                    echo "Install with: sudo dnf install xorriso"
                    ;;
                "unsquashfs"|"mksquashfs")
                    echo "Install with: sudo dnf install squashfs-tools"
                    ;;
            esac
            exit 1
        fi
    done

    print_success "All dependencies found"
}

download_fedora_iso() {
    if [[ ! -f "$INPUT_ISO" ]]; then
        print_status "Downloading Fedora $FEDORA_VERSION netinst ISO..."

        # Download from official mirror
        local iso_url="https://download.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_VERSION}/Server/x86_64/iso/Fedora-Server-netinst-x86_64-${FEDORA_VERSION}-1.1.iso"
