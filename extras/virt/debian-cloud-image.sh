#!/usr/bin/env bash

# Function to create a Debian 12 KVM VM using the latest cloud image and cloud-init.
# Downloads the image automatically if not found. Allows configuration via arguments.
#
# Usage:
#   virt_debian_latest [options]
#
# Options:
#   --vm-name <name>       Set the name for the new VM (default: debian12-cloud)
#   --vcpu <count>         Set the number of vCPUs (default: 2)
#   --memory <MB>          Set the memory in Megabytes (default: 2048)
#   --vm-disk-size <size>  Set the size of the VM's overlay disk (e.g., 10G, 20G) (default: 10G)
#   --help, -h             Show this help message
#
# Prerequisites: (Same as before)
# 1. Cloud-init files: /var/lib/libvirt/boot/cloud-init/{debian-meta-data, debian-user-data, debian-network-config}
# 2. Host bridge 'br0' active.
# 3. KVM installed and libvirtd running.
# 4. Sudo privileges for the user.
# 5. Required tools: curl, sha512sum, virsh, virt-install, qemu-img, sudo.

virt_debian_latest() {
    # --- Default Configuration ---
    local VM_NAME="debian12-cloud"
    local VCPUS="2"
    local MEMORY_MB="2048"
    local VM_DISK_SIZE="10G" # Default size of the VM's overlay disk

    local BASE_IMAGE_DIR="/var/lib/libvirt/images"
    local BASE_IMAGE_NAME="debian-12-genericcloud-amd64.qcow2"
    local BASE_IMAGE_PATH="${BASE_IMAGE_DIR}/${BASE_IMAGE_NAME}"

    local CLOUD_INIT_DIR="/var/lib/libvirt/boot/cloud-init"
    local METADATA="${CLOUD_INIT_DIR}/debian-meta-data"
    local USERDATA="${CLOUD_INIT_DIR}/debian-user-data"
    local NETCONFIG="${CLOUD_INIT_DIR}/debian-network-config"

    local BRIDGE_IF="br0" # Your host bridge interface

    # Debian 12 Cloud Image Source URL
    local DEBIAN_CLOUD_URL="https://cloud.debian.org/images/cloud/bookworm/latest"
    local IMAGE_URL="${DEBIAN_CLOUD_URL}/${BASE_IMAGE_NAME}"
    local CHECKSUM_URL="${DEBIAN_CLOUD_URL}/SHA512SUMS"

    # --- Usage Message ---
    usage() {
        echo "Usage: virt_debian_latest [options]"
        echo ""
        echo "Options:"
        echo "  --vm-name <name>       Set the name for the new VM (default: ${VM_NAME})"
        echo "  --vcpu <count>         Set the number of vCPUs (default: ${VCPUS})"
        echo "  --memory <MB>          Set the memory in Megabytes (default: ${MEMORY_MB})"
        echo "  --vm-disk-size <size>  Set the VM overlay disk size (e.g., 10G) (default: ${VM_DISK_SIZE})"
        echo "  --help, -h             Show this help message"
        echo ""
        echo "Example: virt_debian_latest --vm-name my-test --vcpu 1 --memory 1024 --vm-disk-size 20G"
    }

    # --- Argument Parsing ---
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --vm-name)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: --vm-name requires a value." >&2
                return 1
            fi
            VM_NAME="$2"
            shift 2
            ;;
        --vcpu)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: --vcpu requires a numeric value." >&2
                return 1
            fi
            # Basic check if it looks like a number
            if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo "ERROR: --vcpu value '$2' is not a valid number." >&2
                return 1
            fi
            VCPUS="$2"
            shift 2
            ;;
        --memory)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: --memory requires a numeric value (MB)." >&2
                return 1
            fi
            if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo "ERROR: --memory value '$2' is not a valid number." >&2
                return 1
            fi
            MEMORY_MB="$2"
            shift 2
            ;;
        --vm-disk-size)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: --vm-disk-size requires a value (e.g., 10G)." >&2
                return 1
            fi
            # Basic check for common G/M suffixes (optional but helpful)
            if ! [[ "$2" =~ ^[0-9]+[GM]$ ]]; then echo "Warning: --vm-disk-size format ('$2') might not be recognized by qemu-img. Use format like 10G or 512M." >&2; fi
            VM_DISK_SIZE="$2"
            shift 2
            ;;
        --help | -h)
            usage
            return 0 # Exit successfully after showing help
            ;;
        *)
            echo "ERROR: Unknown option: $1" >&2
            usage
            return 1
            ;;
        esac
    done

    # --- Variable derived after parsing args ---
    local VM_DISK_PATH="${BASE_IMAGE_DIR}/${VM_NAME}.qcow2" # Disk specific to this VM

    # --- Tool Dependency Checks ---
    local missing_tools=()
    for tool in curl sha512sum virsh virt-install qemu-img sudo; do # Added qemu-img
        if ! command -v "${tool}" &>/dev/null; then
            missing_tools+=("${tool}")
        fi
    done
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "ERROR: Required tools missing: ${missing_tools[*]}" >&2
        echo "Please install them (e.g., apt install qemu-kvm libvirt-daemon-system libvirt-clients virtinst qemu-utils curl coreutils)" >&2
        return 1
    fi

    # --- Sudo Check ---
    if ! sudo -v; then
        echo "ERROR: Root privileges (sudo) required for VM management and image operations." >&2
        return 1
    fi

    # --- Prerequisite Checks ---
    echo "--- Checking Prerequisites ---"
    local error_found=0
    if [[ ! -f "${METADATA}" || ! -f "${USERDATA}" || ! -f "${NETCONFIG}" ]]; then
        echo "ERROR: One or more cloud-init files not found in ${CLOUD_INIT_DIR}/" >&2
        echo "       Required: debian-meta-data, debian-user-data, debian-network-config" >&2
        error_found=1
    fi
    if ! ip link show "${BRIDGE_IF}" >/dev/null 2>&1; then
        echo "ERROR: Bridge interface '${BRIDGE_IF}' not found or not active." >&2
        echo "       Please create/configure the host bridge." >&2
        error_found=1
    fi
    if virsh dominfo "${VM_NAME}" &>/dev/null; then
        echo "ERROR: A VM with the name '${VM_NAME}' already exists." >&2
        error_found=1
    fi
    if [[ -e "${VM_DISK_PATH}" ]]; then
        echo "ERROR: VM disk file already exists: ${VM_DISK_PATH}" >&2
        echo "       Delete it or choose a different VM name via --vm-name." >&2
        error_found=1
    fi
    if [[ $error_found -ne 0 ]]; then
        echo "Prerequisite check failed. Aborting." >&2
        return 1
    fi
    echo "Prerequisites look OK."

    # --- Base Image Download & Verification ---
    # (Code for downloading/verifying BASE_IMAGE_PATH remains the same as previous version)
    # ... (omitted for brevity, assume it's here) ...
    if [[ ! -f "${BASE_IMAGE_PATH}" ]]; then
        echo "Base image '${BASE_IMAGE_PATH}' not found. Attempting download..."
        # ... (download and verification logic as before) ...
        # Example placeholder for download/verify logic:
        echo "Placeholder: Downloading and verifying ${BASE_IMAGE_PATH}..."
        # Make sure download/verify returns non-zero on failure!
        # if ! download_and_verify "${BASE_IMAGE_PATH}" "${IMAGE_URL}" "${CHECKSUM_URL}"; then return 1; fi
        # Replace above placeholder with the actual download/verify code from the previous answer
        # Ensure sudo is used correctly within that code for writing files and setting permissions.
        # For now, we'll just check existence as a placeholder.
        # >>> PASTE the download/verification block from the previous answer here <<<
        # --- Start Pasted Block ---
        local temp_checksum_file
        temp_checksum_file=$(mktemp)
        if [[ -z "$temp_checksum_file" ]]; then
            echo "ERROR: Failed to create temporary file for checksums." >&2
            return 1
        fi
        trap 'rm -f "$temp_checksum_file"' RETURN EXIT

        echo "Downloading checksums from ${CHECKSUM_URL}..."
        if ! curl --fail --silent --location "${CHECKSUM_URL}" -o "${temp_checksum_file}"; then
            echo "ERROR: Failed to download checksum file from ${CHECKSUM_URL}" >&2
            return 1
        fi

        if [[ ! -d "${BASE_IMAGE_DIR}" ]]; then
            echo "Creating base image directory: ${BASE_IMAGE_DIR}"
            if ! sudo mkdir -p "${BASE_IMAGE_DIR}"; then
                echo "ERROR: Failed to create directory ${BASE_IMAGE_DIR}." >&2
                return 1
            fi
            sudo chown libvirt-qemu:kvm "${BASE_IMAGE_DIR}" || echo "Warning: Could not set ownership on ${BASE_IMAGE_DIR}" >&2
            sudo chmod 775 "${BASE_IMAGE_DIR}" || echo "Warning: Could not set permissions on ${BASE_IMAGE_DIR}" >&2
        fi

        echo "Downloading base image from ${IMAGE_URL} to ${BASE_IMAGE_PATH}..."
        if ! sudo curl --fail --location "${IMAGE_URL}" -o "${BASE_IMAGE_PATH}"; then
            echo "ERROR: Failed to download base image from ${IMAGE_URL}" >&2
            sudo rm -f "${BASE_IMAGE_PATH}" # Clean up partial download
            return 1
        fi

        echo "Verifying checksum for downloaded image..."
        local expected_checksum
        expected_checksum=$(grep "${BASE_IMAGE_NAME}" "${temp_checksum_file}" | awk '{print $1}')

        if [[ -z "${expected_checksum}" ]]; then
            echo "ERROR: Could not find checksum for ${BASE_IMAGE_NAME} in checksum file." >&2
            sudo rm -f "${BASE_IMAGE_PATH}"
            return 1
        fi

        local actual_checksum
        actual_checksum=$(sha512sum "${BASE_IMAGE_PATH}" | awk '{print $1}')

        echo "Expected Checksum: ${expected_checksum}"
        echo "Actual Checksum:   ${actual_checksum}"

        if [[ "${expected_checksum}" != "${actual_checksum}" ]]; then
            echo "ERROR: Checksum verification FAILED for ${BASE_IMAGE_PATH}!" >&2
            sudo rm -f "${BASE_IMAGE_PATH}"
            return 1
        else
            echo "Checksum verified successfully."
            echo "Setting permissions on base image..."
            sudo chown libvirt-qemu:kvm "${BASE_IMAGE_PATH}" || echo "Warning: Could not set ownership on ${BASE_IMAGE_PATH}" >&2
            sudo chmod 664 "${BASE_IMAGE_PATH}" || echo "Warning: Could not set permissions on ${BASE_IMAGE_PATH}" >&2
        fi
        rm -f "$temp_checksum_file"
        trap - RETURN EXIT # Clear trap
        # --- End Pasted Block ---
    else
        echo "Using existing base image: ${BASE_IMAGE_PATH}"
    fi

    # --- Create VM Disk ---
    echo "--- Creating VM Disk ---"
    echo "Creating VM-specific disk '${VM_DISK_PATH}' (${VM_DISK_SIZE}) linked to base image..."
    # Use sudo for qemu-img create as it writes to /var/lib/libvirt/images
    if ! sudo qemu-img create -f qcow2 -o backing_file="${BASE_IMAGE_PATH}",backing_fmt=qcow2 "${VM_DISK_PATH}" "${VM_DISK_SIZE}"; then
        echo "ERROR: Failed to create VM disk '${VM_DISK_PATH}' with qemu-img." >&2
        return 1
    fi
    echo "Setting permissions on VM disk..."
    sudo chown libvirt-qemu:kvm "${VM_DISK_PATH}" || echo "Warning: Could not set ownership on ${VM_DISK_PATH}" >&2
    sudo chmod 664 "${VM_DISK_PATH}" || echo "Warning: Could not set permissions on ${VM_DISK_PATH}" >&2
    echo "VM Disk created successfully."

    # --- Create VM using virt-install ---
    echo "--- Creating VM ---"
    echo "Attempting to create VM: ${VM_NAME}..."
    echo "  vCPUs: ${VCPUS}"
    echo "  Memory: ${MEMORY_MB} MB"
    echo "  Disk: ${VM_DISK_PATH} (size: ${VM_DISK_SIZE}, backing: ${BASE_IMAGE_NAME})"
    echo "  Network: Bridge ${BRIDGE_IF}"
    echo "  Cloud-Init: Meta=${METADATA}, User=${USERDATA}, Net=${NETCONFIG}"

    sudo virt-install \
        --connect qemu:///system \
        --virt-type kvm \
        --name "${VM_NAME}" \
        --disk path="${VM_DISK_PATH}",format=qcow2,bus=virtio,cache=none \
        --os-variant debian12 \
        --vcpus "${VCPUS}" \
        --cpu host-passthrough \
        --memory "${MEMORY_MB}" \
        --machine q35 \
        --network bridge="${BRIDGE_IF}",model=virtio \
        --graphics none \
        --console pty,target_type=serial \
        --serial pty \
        --import \
        --cloud-init meta-data="file=${METADATA}" \
        --cloud-init user-data="file=${USERDATA}" \
        --cloud-init network-config="file=${NETCONFIG}" \
        --noautoconsole

    local exit_status=$?
    if [[ ${exit_status} -eq 0 ]]; then
        echo "-----------------------------------------------------"
        echo "VM '${VM_NAME}' creation command submitted successfully."
        echo "Wait a minute or two for cloud-init to complete."
        echo "Check status: virsh list --all"
        echo "Connect to console: virsh console ${VM_NAME}"
        echo "Find IP (if DHCP): virsh domifaddr ${VM_NAME}"
        echo "-----------------------------------------------------"
    else
        echo "ERROR: virt-install command failed with exit status ${exit_status}." >&2
        echo "Consider running with --debug for more verbose output." >&2
        echo "Cleaning up potentially created disk: ${VM_DISK_PATH}"
        sudo rm -f "${VM_DISK_PATH}"
        return 1
    fi
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    virt_debian_latest "$@"
fi
