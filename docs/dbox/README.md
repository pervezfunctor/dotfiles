# Distrobox Functions 🐧

[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A comprehensive collection of bash functions for managing [Distrobox](https://github.com/89luca89/distrobox) containers with ease. These functions simplify container creation, management, and development environment setup.

## 📚 Table of Contents

- [Quick Start](#-quick-start)
- [Core Functions](#-core-functions)
- [Distribution Containers](#-distribution-containers)
- [Development Environments](#-development-environments)
- [Specialized Containers](#-specialized-containers)
- [Network & SSH](#-network--ssh)
- [Utilities](#-utilities)
- [Environment Variables](#-environment-variables)
- [Dependencies](#-dependencies)

## 🚀 Quick Start

```bash
# Create an Ubuntu container
dbox-ubuntu my-ubuntu

# Enter the container
dbox_enter my-ubuntu

# Create a development environment
dbox-dev fedora-init my-dev-env

# List all containers
dbox_root_list-ips
```

## 🔧 Core Functions

### Container Management

| Function                              | Description          | Example                                    |
| ------------------------------------- | -------------------- | ------------------------------------------ |
| [`dbox_enter`](#dbox_enter)           | Enter a container    | `dbox_enter my-container`                  |
| [`dbox_enter_root`](#dbox_enter_root) | Enter as root        | `dbox_enter_root my-container`             |
| [`dbox_exec`](#dbox_exec)             | Execute command      | `dbox_exec my-container ls -la`            |
| [`dbox_exec_root`](#dbox_exec_root)   | Execute as root      | `dbox_exec_root my-container apt update`   |
| [`dbox_bash_exec`](#dbox_bash_exec)   | Execute bash command | `dbox_bash_exec my-container "echo hello"` |
| [`dbox-logs`](#dbox-logs)             | View container logs  | `dbox-logs my-container`                   |

### Container Creation

| Function                                | Description            | Example                                      |
| --------------------------------------- | ---------------------- | -------------------------------------------- |
| [`dbox_create`](#dbox_create)           | Create basic container | `dbox_create my-box ubuntu:latest`           |
| [`dbox_create_root`](#dbox_create_root) | Create root container  | `dbox_create_root my-root-box fedora:latest` |

---

### dbox_enter
```bash
dbox_enter <container_name> [-- additional_commands]
```
Enters a distrobox container with a clean path environment.

**Parameters:**
- `container_name`: Name of the container to enter
- `additional_commands`: Optional commands to execute after entering

**Example:**
```bash
dbox_enter my-container
dbox_enter my-container -- ls -la
```

### dbox_enter_root
```bash
dbox_enter_root <container_name> [-- additional_commands]
```
Enters a distrobox container as root with a clean path environment.

**Parameters:**
- `container_name`: Name of the container to enter as root
- `additional_commands`: Optional commands to execute after entering

### dbox_exec
```bash
dbox_exec <container_name> <command>
```
Executes a command inside a distrobox container.

**Parameters:**
- `container_name`: Name of the container to execute command in
- `command`: Command to execute

### dbox_exec_root
```bash
dbox_exec_root <container_name> <command>
```
Executes a command inside a distrobox container as root.

**Parameters:**
- `container_name`: Name of the container to execute command in as root
- `command`: Command to execute

### dbox_bash_exec
```bash
dbox_bash_exec <container_name> <bash_command>
```
Executes a bash command inside a distrobox container.

**Parameters:**
- `container_name`: Name of the container to execute command in
- `bash_command`: Bash command to execute

### dbox-logs
```bash
dbox-logs <container_name>
```
Displays the logs for a specified container using podman.

**Parameters:**
- `container_name`: Name of the container to view logs for

### dbox_create
```bash
dbox_create <container_name> <image> [-- additional_options]
```
Creates a new distrobox container with the specified image.

**Parameters:**
- `container_name`: Name for the new container
- `image`: Docker image to use for the container
- `additional_options`: Additional options passed to distrobox create

**Features:**
- ✅ Checks if container already exists
- ✅ Verifies home directory doesn't exist
- ✅ Creates container in `${BOXES_DIR}`
- ✅ Provides success/failure feedback

### dbox_create_root
```bash
dbox_create_root <container_name> <image> [-- additional_options]
```
Creates a new distrobox container with root privileges.

**Parameters:**
- `container_name`: Name for the new container
- `image`: Docker image to use for the container
- `additional_options`: Additional options passed to distrobox create

## 🐧 Distribution Containers

### Standard Containers

| Function              | Image                                              | Default Name   |
| --------------------- | -------------------------------------------------- | -------------- |
| `dbox-ubuntu`         | `ubuntu:questing`                                  | ubuntu         |
| `dbox-arch`           | `archlinux:latest`                                 | arch           |
| `dbox-fedora`         | `fedora:latest`                                    | fedora         |
| `dbox-debian`         | `debian:latest`                                    | debian         |
| `dbox-centos`         | `centos:latest`                                    | centos         |
| `dbox-rocky`          | `rockylinux:9`                                     | rocky          |
| `dbox-tw`             | `opensuse/tumbleweed`                              | tumbleweed     |
| `dbox-fedora-minimal` | `registry.fedoraproject.org/fedora-minimal:latest` | fedora-minimal |
| `dbox-debian-slim`    | `debian:trixie-slim`                               | debian-slim    |

### Systemd-Enabled Containers

| Function                | Image                                         | Default Name     |
| ----------------------- | --------------------------------------------- | ---------------- |
| `dbox-ubuntu-init`      | `ubuntu:questing`                             | ubuntu-init      |
| `dbox-debian-init`      | `debian:latest`                               | debian-init      |
| `dbox-arch-init`        | `archlinux:latest`                            | arch-init        |
| `dbox-fedora-init`      | `fedora:latest`                               | fedora-init      |
| `dbox-tw-init`          | `opensuse/tumbleweed`                         | tw-init          |
| `dbox-alpine-init`      | `quay.io/toolbx-images/alpine-toolbox:latest` | alpine-init      |
| `dbox-alpine-edge-init` | `quay.io/toolbx-images/alpine-toolbox:edge`   | alpine-edge-init |

### Development-Ready Containers

| Function           | Image                                         | Default Name | Pre-installed Tools                                                          |
| ------------------ | --------------------------------------------- | ------------ | ---------------------------------------------------------------------------- |
| `dbox-alpine`      | `quay.io/toolbx-images/alpine-toolbox:latest` | alpine       | gcc, git, neovim, tmux, ripgrep, fzf, eza, zoxide, gh, delta, bat, trash-cli |
| `dbox-alpine-edge` | `quay.io/toolbx-images/alpine-toolbox:edge`   | alpine-edge  | Same as alpine                                                               |

### Specialized Images

| Function       | Image                            | Default Name |
| -------------- | -------------------------------- | ------------ |
| `dbox-bluefin` | `ghcr.io/ublue-os/bluefin-cli`   | bluefin-cli  |
| `dbox-wolfi`   | `ghcr.io/ublue-os/wolfi-toolbox` | wolfi-ublue  |

## 💻 Development Environments

### Quick Development Setup

```bash
# Create a development environment with default settings
dbox-dev-default

# Create a development environment with specific OS
dbox-dev fedora-init my-dev-env

# Valid OS types: ubuntu-init, debian-init, arch-init, tw-init, fedora-init
```

### Development Functions

| Function             | Description                                       | Example                                   |
| -------------------- | ------------------------------------------------- | ----------------------------------------- |
| `dbox-dev-default`   | Creates default development environment           | `dbox-dev-default`                        |
| `dbox-dev`           | Creates development environment with specified OS | `dbox-dev fedora-init my-dev`             |
| `dbox-main-install`  | Creates container and runs mainstall script       | `dbox-main-install fedora my-mainstall`   |
| `dbox-group-install` | Creates container and runs groupstall script      | `dbox-group-install ubuntu my-groupstall` |
| `dbox-nix`           | Creates Debian container with Nix                 | `dbox-nix my-nix-env`                     |

### dbox-dev
```bash
dbox-dev [os_type] [container_name]
```
Creates a development environment with the specified OS type.

**Parameters:**
- `os_type`: OS type (ubuntu-init, debian-init, arch-init, tw-init, fedora-init)
- `container_name`: Name for the container (default: dev)

**Valid OS types:** ubuntu-init, debian-init, arch-init, tw-init, fedora-init

**Features:**
- ✅ Creates container with specified OS
- ✅ Sets up development environment via ILM setup script
- ✅ Provides feedback on successful setup

## 🏗️ Specialized Containers

### Virtualization Management

#### dbox-virt-manager
```bash
dbox-virt-manager [container_name]
```
Creates an openSUSE container for virtualization management.

**Default name:** virt-manager

**Features:**
- 🔐 Root container with SSH access on port 2222
- 📦 Pre-installed virtualization packages
- ⚙️ Configured services for virtualization
- 👤 User added to libvirt group

**Pre-installed packages:** openssh-server, patterns-server-kvm_server, patterns-server-kvm_tools, qemu-extra, qemu-linux-user, qemu-hw-display-virtio-gpu, qemu-ui-opengl, qemu-spice, spice-gtk, libvirglrenderer1, xmlstarlet, jq

**Enabled services:** sshd.service, virtqemud.socket, virtnetworkd.socket, virtstoraged.socket, virtnodedevd.socket

#### dbox-fedora-virt-manager
```bash
dbox-fedora-virt-manager [container_name]
```
Creates a Fedora container for virtualization management.

**Default name:** fedora-virt-manager

**Features:**
- 🔐 Root container with SSH access on port 2222
- 📦 Pre-installed virtualization packages
- ⚙️ Configured services for virtualization
- 👤 User added to libvirt group

### Docker Containers

| Function           | Description                | Default Name |
| ------------------ | -------------------------- | ------------ |
| `dbox-docker-base` | Basic Fedora with Docker   | docker-base  |
| `dbox-docker-slim` | Minimal Docker container   | docker       |
| `dbox-docker`      | Full Docker with dev tools | docker       |

#### dbox-docker
```bash
dbox-docker [container_name]
```
Creates a fully configured Docker container with development tools.

**Default name:** docker

**Features:**
- 🐳 Creates a slim Docker container
- 🛠️ Sets up development environment via ILM setup script
- 🔑 Configures SSH access

### Container Management

#### dbox-incus
```bash
dbox-incus [container_name]
```
Creates a container for Incus (LXD successor) management.

**Default name:** incus

**Features:**
- 🔐 Root container with systemd
- 📁 Mounts /var/lib/incus from host
- 📁 Mounts /lib/modules from host (read-only)
- 👤 User added to incus-admin group

### Batch Creation

| Function           | Description                                                                          |
| ------------------ | ------------------------------------------------------------------------------------ |
| `dbox-ublue-all`   | Creates all uBlue containers (bluefin, wolfi, docker, incus, ubuntu, fedora, arch)   |
| `dbox-toolbox-all` | Creates all toolbox containers (alpine, arch, fedora, centos, debian, rocky, ubuntu) |

## 🌐 Network & SSH

### Network Management

| Function                     | Description                     | Example                                              |
| ---------------------------- | ------------------------------- | ---------------------------------------------------- |
| `dbox-static-network-create` | Create static network           | `dbox-static-network-create my-net 192.168.100.0/24` |
| `dbox-static-network-remove` | Remove static network           | `dbox-static-network-remove my-net`                  |
| `dbox-static-ip`             | Create container with static IP | `dbox-static-ip my-box 192.168.100.10`               |

### SSH & Remote Access

| Function               | Description              | Example                              |
| ---------------------- | ------------------------ | ------------------------------------ |
| `dbox-root-ip`         | Get container IP         | `dbox-root-ip my-container`          |
| `dbox-root-ssh`        | SSH into container       | `dbox-root-ssh my-container user 22` |
| `dbox-root-ssh-tui`    | Interactive SSH menu     | `dbox-root-ssh-tui`                  |
| `dbox_root_list-ips`   | List containers with IPs | `dbox_root_list-ips`                 |
| `vscode-dbox-root-ssh` | Connect VS Code via SSH  | `vscode-dbox-root-ssh my-container`  |

### dbox-root-ssh-tui
```bash
dbox-root-ssh-tui [user] [port]
```
Provides a text user interface for selecting and SSHing into root containers.

**Parameters:**
- `user`: Username for SSH (default: current user)
- `port`: SSH port (default: 22)

**Features:**
- 🖥️ Interactive menu for container selection
- 📍 Displays IP addresses for containers
- 📋 Requires whiptail to be installed

## 🛠️ Utilities

### Container Utilities

| Function                        | Description                    | Example                         |
| ------------------------------- | ------------------------------ | ------------------------------- |
| `dbox-containers`               | List all containers with sizes | `dbox-containers`               |
| `dbox-to-image`                 | Convert container to image     | `dbox-to-image my-container`    |
| `dbox-from-image`               | Create container from image    | `dbox-from-image my-image`      |
| `dbox-nvidia-container-toolkit` | Create GPU-enabled container   | `dbox-nvidia-container-toolkit` |

### dbox-to-image
```bash
dbox-to-image <container_name>
```
Converts a distrobox container to an image.

**Parameters:**
- `container_name`: Name of the container to convert

**Features:**
- 💾 Commits the container to an image
- 🗜️ Saves the image to a compressed file
- 🔧 Uses different compression based on container runtime

### dbox-from-image
```bash
dbox-from_image <image_name> [container_name]
```
Creates a distrobox container from an existing image.

**Parameters:**
- `image_name`: Name of the image to use
- `container_name`: Name for the new container (default: dbox)

## 🌍 Environment Variables

| Variable        | Description                              | Default                                |
| --------------- | ---------------------------------------- | -------------------------------------- |
| `BOXES_DIR`     | Directory for distrobox home directories | Can be overridden with `USE_BOXES_DIR` |
| `ILM_SETUP_URL` | URL for ILM setup script                 | Used in development functions          |

## 📦 Dependencies

### Required
- [distrobox](https://github.com/89luca89/distrobox) - Core container management tool
- [podman](https://podman.io/) or [docker](https://www.docker.com/) - Container runtime

### Optional
- [whiptail](https://packages.debian.org/sid/whiptail) - Required for `dbox-root-ssh-tui`
- [curl](https://curl.se/) - Required for setup scripts
- [ssh](https://www.openssh.com/) - Required for SSH functions
- [VS Code](https://code.visualstudio.com/) - Required for `vscode-dbox-root-ssh`

## 💡 Tips & Tricks

### Quick Container Creation
```bash
# Create multiple containers at once
dbox-ublue-all    # All uBlue containers
dbox-toolbox-all  # All toolbox containers
```

### Development Workflow
```bash
# Create a development environment
dbox-dev fedora-init my-project

# Enter the container
dbox_enter my-project

# Execute commands without entering
dbox_exec my-project -- make build
```

### Container Management
```bash
# List all containers with IPs
dbox_root_list-ips

# SSH into any container
dbox-root-ssh-tui

# Connect VS Code to container
vscode-dbox-root-ssh my-container
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Acknowledgments

- [Distrobox](https://github.com/89luca89/distrobox) for the amazing container management tool
- [uBlue](https://ublue.it/) for the excellent container images
- All contributors and users of these functions
