# vme-tmux - Tmux Session Manager for VMs

The `vme-tmux` script creates and manages tmux sessions with SSH connections to multiple libvirt VMs. It provides a unified interface for working with multiple VMs simultaneously.

## Usage

```bash
vme-tmux [command]
```

## Commands

- `create` - Create a new tmux session with SSH connections to VMs (default if no option)
- `attach` - Attach to an existing session
- `detach` - Detach from the current session
- `destroy` - Kill the tmux session
- `help` - Display this help message

## Session Management

### Session Name
The script uses a fixed session name: `VME`

### Supported VMs
The script manages SSH connections to these VMs:
- `ubuntu-vme` - Ubuntu VM
- `fedora-vme` - Fedora VM
- `arch-vme` - Arch Linux VM
- `debian-vme` - Debian VM
- `tumbleweed-vme` - openSUSE Tumbleweed VM

## Command Details

### create
Creates a new tmux session with SSH connections to all VMs:
```bash
vme-tmux create
# Or explicitly
vme-tmux --create
```

**Process:**
1. Creates a new tmux session named `VME`
2. Generates SSH commands for each VM
3. Creates tmux windows for each VM connection
4. Arranges windows in a grid layout
5. Attaches to the new session

**Features:**
- Automatic SSH connection to each VM
- Grid layout for easy navigation
- Error handling for failed connections
- Session persistence

### attach
Attaches to an existing VME session:
```bash
vme-tmux attach
```

**Behavior:**
- If session exists, attaches to it
- If no session exists, creates one automatically
- Uses tmux attach-session with proper error handling

### detach
Detaches from the current tmux session:
```bash
vme-tmux detach
```

**Result:**
- Leaves tmux session running in background
- Returns to shell prompt
- Session remains active for later re-attachment

### destroy
Kills the VME tmux session:
```bash
vme-tmux destroy
```

**Effect:**
- Terminates all SSH connections to VMs
- Cleans up tmux session
- Frees up system resources

## Tmux Layout

The script creates a grid layout with windows for each VM:
- Window 0: Ubuntu VM SSH
- Window 1: Fedora VM SSH
- Window 2: Arch Linux VM SSH
- Window 3: Debian VM SSH
- Window 4: Tumbleweed VM SSH

## Integration

The script integrates with:
- `vm-utils` - Core VM management functions
- `tmux-utils` - Tmux session management utilities
- `vme` - VM existence checking
- SSH client for VM connections

## Prerequisites

The script requires:
- `tmux` installed and available
- `vme` script available for VM management
- Proper SSH configuration for VM access
- VMs created and accessible via SSH

## Examples

```bash
# Create session (or attach if exists)
vme-tmux

# Force create new session
vme-tmux create

# Attach to existing session
vme-tmux attach

# Detach from current session
vme-tmux detach

# Destroy session
vme-tmux destroy

# Show help
vme-tmux help
```

## Workflow

### Typical Development Workflow
1. **Create VMs**: Use `vme-all create` to set up multiple VMs
2. **Start VMs**: Use `vme-all start` to start all VMs
3. **Create Tmux Session**: Use `vme-tmux create` to connect to all VMs
4. **Work Across VMs**: Navigate between tmux windows (Ctrl+B, then arrow keys)
5. **Detach When Needed**: Use `vme-tmux detach` to leave session running
6. **Clean Up**: Use `vme-all stop` and `vme-tmux destroy` when done

### Tmux Navigation
Once in the session:
- `Ctrl+B` - Prefix key
- `Arrow keys` - Navigate between windows
- `Ctrl+B, then ?` - Show help
- `Ctrl+B, then d` - Detach from session
- `Ctrl+B, then &` - List sessions

## Error Handling

The script handles:
- Missing prerequisites with clear error messages
- Failed SSH connections with warnings
- Tmux session creation failures
- VM availability issues

## Troubleshooting

### Common Issues

1. **Session won't create**:
   - Check if tmux is installed
   - Verify VMs are running and accessible
   - Check SSH key configuration

2. **Can't connect to VMs**:
   - Verify VMs are started: `vme list`
   - Check network connectivity
   - Validate SSH credentials

3. **Tmux layout issues**:
   - Ensure all VMs in the list exist
   - Check if SSH connections succeed individually
   - Try recreating the session

### Debug Commands

```bash
# Check if session exists
tmux list-sessions

# Check tmux version
tmux -V

# Test individual SSH connections
ssh ubuntu@ubuntu-vme
