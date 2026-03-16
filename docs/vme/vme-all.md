# vme-all - Batch VM Management Utility

The `vme-all` script provides batch operations for managing multiple VMs simultaneously.

| Implementation | Path |
|---|---|
| Bash | [`bin/vt/vme-all`](../../../bin/vt/vme-all) |
| Nushell | [`nu/vme-all.nu`](../../../nu/vme-all.nu) |

## Usage

```bash
vme-all [command] [args...]
```

## Commands

| Command | Description |
|---------|-------------|
| `create` (default) | Create all standard VMs |
| `start` | Start all existing VMs |
| `stop` | Gracefully stop all running VMs |
| `restart` | Restart all VMs |
| `delete` | Delete all existing VMs |
| `exec <cmd...>` | Run a command in every running VM via SSH |
| `tmux` | Open tmux grid session with SSH connections to all running VMs |
| `--help` | Show help |

## Managed VMs (`DISTRO_LIST_VME`)

Operations run across these VMs by default (named `<distro>-vme`):

| Distro | VM Name |
|--------|---------|
| ubuntu | `ubuntu-vme` |
| fedora | `fedora-vme` |
| arch | `arch-vme` |
| debian | `debian-vme` |
| tw | `tw-vme` |

VMs that don't exist are skipped with a warning.

## Command Details

### create (default)

Creates all standard VMs. Runs `vme-create --distro <distro> --name <distro>-vme` for each distro in `DISTRO_LIST_VME`, skipping any that already exist.

```bash
vme-all          # same as vme-all create
vme-all create
```

### start / stop / restart / delete

Iterate over all `DISTRO_LIST_VME` VMs and apply the operation to each existing one.

```bash
vme-all start
vme-all stop
vme-all restart
vme-all delete
```

### exec

Run a shell command in every running VM via SSH.

```bash
vme-all exec 'uptime'
vme-all exec 'sudo apt update'
```

### tmux

Open a tmux grid session with SSH panes for every currently-running VME VM.

```bash
vme-all tmux
```

## Examples

```bash
# Initial setup: create all VMs
vme-all create

# Start work environment
vme-all start

# Run a command across all VMs
vme-all exec 'hostname'

# Open a tmux session to all running VMs
vme-all tmux

# Stop all when done
vme-all stop

# Clean up everything
vme-all delete
```

## Integration

- **`share/vm-utils.nu`** / **`bin/vt/vm-utils`** — VM existence and state checks
- **`share/vt-utils.nu`** / **`bin/vt/vt-utils`** — `wait-for-ip`, distro selection
- **`share/tmux-utils.nu`** / **`bin/vt/tmux-utils`** — `tmux-grid` for the `tmux` subcommand
- **`vme-create`** — called per-distro by the `create` subcommand

## Error Handling

- VM already exists on `create` → skipped with warning
- VM doesn't exist on `start`/`stop`/`restart`/`delete` → skipped with warning
- VM has no IP on `exec` → skipped with warning
- Success/failure summary printed at the end of each batch operation
