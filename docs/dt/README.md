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
dt_ubuntu my-ubuntu

# Enter the container
dt_enter my-ubuntu

# Create a development environment
dt_dev fedora-init my-dev-env

# List all containers
dt_root_list-ips
```

## 🔧 Core Functions

### Container Management

| Function                              | Description          | Example                                    |
| ------------------------------------- | -------------------- | ------------------------------------------ |
| [`dt_enter`](#dt_enter)           | Enter a container    | `dt_enter my-container`                  |
| [`dt_enter_root`](#dt_enter_root) | Enter as root        | `dt_enter_root my-container`             |
| [`dt_exec`](#dt_exec)             | Execute command      | `dt_exec my-container ls -la`            |
| [`dt_exec_root`](#dt_exec_root)   | Execute as root      | `dt_exec_root my-container apt update`   |
| [`dt_bash_exec`](#dt_bash_exec)   | Execute bash command | `dt_bash_exec my-container "echo hello"` |
| [`dt_logs`](#dt_logs)             | View container logs  | `dt_logs my-container`                   |

### Container Creation

| Function                                | Description            | Example                                      |
| --------------------------------------- | ---------------------- | -------------------------------------------- |
| [`dt_create`](#dt_create)           | Create basic container | `dt_create my-box ubuntu:latest`           |
| [`dt_create_root`](#dt_create_root) | Create root container  | `dt_create_root my-root-box fedora:latest` |

---

### dt_enter
```bash
dt_enter <container_name> [-- additional_commands]
```
Enters a distrobox container with a clean path environment.

**Parameters:**
- `container_name`: Name of the container to enter
- `additional_commands`: Optional commands to execute after entering

**Example:**
```bash
dt_enter my-container
dt_enter my-container -- ls -la
```

### dt_enter_root
```bash
dt_enter_root <container_name> [-- additional_commands]
```
Enters a distrobox container as root with a clean path environment.

**Parameters:**
- `container_name`: Name of the container to enter as root
- `additional_commands`: Optional commands to execute after entering

### dt_exec
```bash
dt_exec <container_name> <command>
```
Executes a command inside a distrobox container.

**Parameters:**
- `container_name`: Name of the container to execute command in
- `command`: Command to execute

### dt_exec_root
```bash
dt_exec_root <container_name> <command>
```
Executes a command inside a distrobox container as root.

**Parameters:**
- `container_name`: Name of the container to execute command in as root
- `command`: Command to execute

### dt_bash_exec
```bash
dt_bash_exec <container_name> <bash_command>
```
Executes a bash command inside a distrobox container.

**Parameters:**
- `container_name`: Name of the container to execute command in
- `bash_command`: Bash command to execute

### dt_logs
```bash
dt_logs <container_name>
```
Displays the logs for a specified container using podman.

**Parameters:**
- `container_name`: Name of the container to view logs for

### dt_create
```bash
dt_create <container_name> <image> [-- additional_options]
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

### dt_create_root
```bash
dt_create_root <container_name> <image> [-- additional_options]
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
| `dt_ubuntu`         | `ubuntu:questing`                                  | ubuntu         |
| `dt_arch`           | `archlinux:latest`                                 | arch           |
| `dt_fedora`         | `fedora:latest`                                    | fedora         |
| `dt_debian`         | `debian:latest`                                    | debian         |
| `dt_centos`         | `centos:latest`                                    | centos         |
| `dt_rocky`          | `rockylinux:9`                                     | rocky          |
| `dt_tw`             | `opensuse/tumbleweed`                              | tumbleweed     |
| `dt_fedora-minimal` | `registry.fedoraproject.org/fedora-minimal:latest` | fedora-minimal |
| `dt_debian-slim`    | `debian:trixie-slim`                               | debian-slim    |

### Systemd-Enabled Containers

| Function                | Image                                         | Default Name     |
| ----------------------- | --------------------------------------------- | ---------------- |
| `dt_ubuntu-init`      | `ubuntu:questing`                             | ubuntu-init      |
| `dt_debian-init`      | `debian:latest`                               | debian-init      |
| `dt_arch-init`        | `archlinux:latest`                            | arch-init        |
| `dt_fedora-init`      | `fedora:latest`                               | fedora-init      |
| `dt_tw-init`          | `opensuse/tumbleweed`                         | tw-init          |
| `dt_alpine-init`      | `quay.io/toolbx-images/alpine-toolbox:latest` | alpine-init      |
| `dt_alpine-edge-init` | `quay.io/toolbx-images/alpine-toolbox:edge`   | alpine-edge-init |

### Development-Ready Containers

| Function           | Image                                         | Default Name | Pre-installed Tools                                                          |
| ------------------ | --------------------------------------------- | ------------ | ---------------------------------------------------------------------------- |
| `dt_alpine`      | `quay.io/toolbx-images/alpine-toolbox:latest` | alpine       | gcc, git, neovim, tmux, ripgrep, fzf, eza, zoxide, gh, delta, bat, trash-cli |
| `dt_alpine-edge` | `quay.io/toolbx-images/alpine-toolbox:edge`   | alpine-edge  | Same as alpine                                                               |

### Specialized Images

| Function       | Image                            | Default Name |
| -------------- | -------------------------------- | ------------ |
| `dt_bluefin` | `ghcr.io/ublue-os/bluefin-cli`   | bluefin-cli  |
| `dt_wolfi`   | `ghcr.io/ublue-os/wolfi-toolbox` | wolfi-ublue  |

## 💻 Development Environments

### Quick Development Setup

```bash
# Create a development environment with default settings
dt_dev-default

# Create a development environment with specific OS
dt_dev fedora-init my-dev-env

# Valid OS types: ubuntu-init, debian-init, arch-init, tw-init, fedora-init
```

### Development Functions

| Function             | Description                                       | Example                                   |
| -------------------- | ------------------------------------------------- | ----------------------------------------- |
| `dt_dev-default`   | Creates default development environment           | `dt_dev-default`                        |
| `dt_dev`           | Creates development environment with specified OS | `dt_dev fedora-init my-dev`             |
| `dt_main-install`  | Creates container and runs mainstall script       | `dt_main-install fedora my-mainstall`   |
| `dt_group-install` | Creates container and runs groupstall script      | `dt_group-install ubuntu my-groupstall` |
| `dt_nix`           | Creates Debian container with Nix                 | `dt_nix my-nix-env`                     |

### dt_dev
```bash
dt_dev [os_type] [container_name]
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

#### dt_virt-manager
```bash
dt_virt-manager [container_name]
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

#### dt_fedora-virt-manager
```bash
dt_fedora-virt-manager [container_name]
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
| `dt_docker-base` | Basic Fedora with Docker   | docker-base  |
| `dt_docker-slim` | Minimal Docker container   | docker       |
| `dt_docker`      | Full Docker with dev tools | docker       |

#### dt_docker
```bash
dt_docker [container_name]
```
Creates a fully configured Docker container with development tools.

**Default name:** docker

**Features:**
- 🐳 Creates a slim Docker container
- 🛠️ Sets up development environment via ILM setup script
- 🔑 Configures SSH access

### Container Management

#### dt_incus
```bash
dt_incus [container_name]
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
| `dt_ublue-all`   | Creates all uBlue containers (bluefin, wolfi, docker, incus, ubuntu, fedora, arch)   |
| `dt_toolbox-all` | Creates all toolbox containers (alpine, arch, fedora, centos, debian, rocky, ubuntu) |

## 🌐 Network & SSH

### Network Management

| Function                     | Description                     | Example                                              |
| ---------------------------- | ------------------------------- | ---------------------------------------------------- |
| `dt_static-network-create` | Create static network           | `dt_static-network-create my-net 192.168.100.0/24` |
| `dt_static-network-remove` | Remove static network           | `dt_static-network-remove my-net`                  |
| `dt_static-ip`             | Create container with static IP | `dt_static-ip my-box 192.168.100.10`               |

### SSH & Remote Access

| Function               | Description              | Example                              |
| ---------------------- | ------------------------ | ------------------------------------ |
| `dt_root-ip`         | Get container IP         | `dt_root-ip my-container`          |
| `dt_root-ssh`        | SSH into container       | `dt_root-ssh my-container user 22` |
| `dt_root-ssh-tui`    | Interactive SSH menu     | `dt_root-ssh-tui`                  |
| `dt_root_list-ips`   | List containers with IPs | `dt_root_list-ips`                 |
| `vscode-dt_root-ssh` | Connect VS Code via SSH  | `vscode-dt_root-ssh my-container`  |

### dt_root-ssh-tui
```bash
dt_root-ssh-tui [user] [port]
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
| `dt_containers`               | List all containers with sizes | `dt_containers`               |
| `dt_to-image`                 | Convert container to image     | `dt_to-image my-container`    |
| `dt_from-image`               | Create container from image    | `dt_from-image my-image`      |
| `dt_nvidia-container-toolkit` | Create GPU-enabled container   | `dt_nvidia-container-toolkit` |

### dt_to-image
```bash
dt_to-image <container_name>
```
Converts a distrobox container to an image.

**Parameters:**
- `container_name`: Name of the container to convert

**Features:**
- 💾 Commits the container to an image
- 🗜️ Saves the image to a compressed file
- 🔧 Uses different compression based on container runtime

### dt_from-image
```bash
dt_from_image <image_name> [container_name]
```
Creates a distrobox container from an existing image.

**Parameters:**
- `image_name`: Name of the image to use
- `container_name`: Name for the new container (default: dt)

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
- [whiptail](https://packages.debian.org/sid/whiptail) - Required for `dt_root-ssh-tui`
- [curl](https://curl.se/) - Required for setup scripts
- [ssh](https://www.openssh.com/) - Required for SSH functions
- [VS Code](https://code.visualstudio.com/) - Required for `vscode-dt_root-ssh`

## 💡 Tips & Tricks

### Quick Container Creation
```bash
# Create multiple containers at once
dt_ublue-all    # All uBlue containers
dt_toolbox-all  # All toolbox containers
```

### Development Workflow
```bash
# Create a development environment
dt_dev fedora-init my-project

# Enter the container
dt_enter my-project

# Execute commands without entering
dt_exec my-project -- make build
```

### Container Management
```bash
# List all containers with IPs
dt_root_list-ips

# SSH into any container
dt_root-ssh-tui

# Connect VS Code to container
vscode-dt_root-ssh my-container
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Acknowledgments

- [Distrobox](https://github.com/89luca89/distrobox) for the amazing container management tool
- [uBlue](https://ublue.it/) for the excellent container images
- All contributors and users of these functions
