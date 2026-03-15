# vme-tmux - Tmux Session Manager for VMs

The `vme-tmux` script creates and manages a tmux session (`VME`) with SSH connections to libvirt VMs in a tiled grid layout.

| Implementation | Path |
|---|---|
| Bash | [`bin/vt/vme-tmux`](../../../bin/vt/vme-tmux) |
| Nushell | [`nu/vme-tmux.nu`](../../../nu/vme-tmux.nu) |

## Usage

```bash
vme-tmux [command]
```

## Commands

| Command | Description |
|---------|-------------|
| `create` (default) | Kill any existing `VME` session and create a fresh one |
| `attach` | Attach to an existing `VME` session |
| `detach` | Detach from the current session (leaves it running) |
| `destroy` | Kill the `VME` tmux session |
| `--help` | Show help |

## Session Details

- **Session name**: `VME` (fixed)
- **VMs**: all `DISTRO_LIST_VME` distros — `ubuntu-vme`, `fedora-vme`, `arch-vme`, `debian-vme`, `tw-vme`
- **Layout**: tiled grid, one pane per VM
- **SSH command per pane**: `vme ssh <vm-name> $USER`
- **Startup**: VMs that are not running are started automatically before the session opens

## Command Details

### create (default)

Kills any existing `VME` session, starts any non-running VMs, then opens a new tiled tmux grid with SSH panes for each VM.

```bash
vme-tmux          # same as vme-tmux create
vme-tmux create
vme-tmux -c
vme-tmux --create
```

**Process:**
1. Checks prerequisites (`virsh`, `tmux`)
2. Kills existing `VME` session if present
3. Generates VM names: `<distro>-vme` for each distro in `DISTRO_LIST_VME`
4. Starts any VMs that are not currently running
5. Creates a tiled tmux grid with `vme ssh <vm> $USER` in each pane
6. Attaches to the new session

### attach

Attaches to an already-running `VME` session. Fails if the session doesn't exist.

```bash
vme-tmux attach
```

### detach

Detaches from the current `VME` session without killing it.

```bash
vme-tmux detach
```

### destroy

Kills the `VME` tmux session and all its panes.

```bash
vme-tmux destroy
```

## Examples

```bash
# Create (or recreate) the VME session
vme-tmux

# Attach to existing session
vme-tmux attach

# Detach from current session
vme-tmux detach

# Kill the session
vme-tmux destroy
```

## Typical Workflow

1. `vme-all create` — create all VMs
2. `vme-tmux` — open grid session (starts VMs automatically)
3. Navigate panes: `Ctrl+B` then arrow keys or `Ctrl+B q` for pane numbers
4. `vme-tmux detach` — leave session running in background
5. `vme-tmux attach` — reconnect later
6. `vme-all stop` then `vme-tmux destroy` — clean up when done

## Tmux Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl+B` | Prefix key |
| `Ctrl+B` + arrow | Move between panes |
| `Ctrl+B q` | Show pane numbers |
| `Ctrl+B d` | Detach from session |
| `Ctrl+B &` | Kill current window |
| `Ctrl+B ?` | Show all shortcuts |

## Integration

- **`share/vm-utils.nu`** / **`bin/vt/vm-utils`** — `vm-running`, `virt-check-prerequisites`
- **`share/tmux-utils.nu`** / **`bin/vt/tmux-utils`** — `tmux-session`, `tmux-grid`, `attach-session`, `detach-session`, `destroy-session`, `generate-names`, `create-commands-generic`, `start-sessions`

## Troubleshooting

```bash
# Check if session exists
tmux list-sessions

# Verify VMs are running
vme list

# Test a single VM SSH connection
vme ssh ubuntu-vme

# Recreate session from scratch
vme-tmux destroy
vme-tmux create
```
