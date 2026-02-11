# ilm-scripts

A collection of useful Python scripts, including `tmux-grid` for managing tmux sessions with tiled panes or named windows.

## Installation

This project is managed with [pixi](https://prefix.dev/). To install the project and its dependencies:

```bash
# Clone the repository
git clone https://github.com/pervezfunction/dotfiles.git
cd dotfiles/py

# Install dependencies
pixi install
```

Alternatively, you can install it using `pip` in a virtual environment:

```bash
pip install .
```

## Usage: tmux-grid

`tmux-grid` allows you to create tmux sessions where commands are executed in a grid of panes or across multiple named windows.

### Basic Grid

Create a session with multiple panes, each running a specified command. The layout will define a grid (e.g., 2x2 for 4 commands).

```bash
# Syntax: tmux-grid grid <SESSION_NAME> <COMMAND_1> <COMMAND_2> ...
pixi run tmux-grid grid my-monitor "htop" "tail -f /var/log/syslog" "dmesg -w"
```

### Grid from File

Read commands from a file (one command per line) and execute them in a grid.

```bash
# commands.txt:
# htop
# tail -f /var/log/syslog
# dmesg -w

pixi run tmux-grid grid-file my-monitor commands.txt
```

### Named Windows

Create a session with separate windows, each having a custom name and command.

```bash
# Syntax: tmux-grid windows <SESSION_NAME> <NAME_1> <CMD_1> <NAME_2> <CMD_2> ...
pixi run tmux-grid windows my-dev \
    editor "nvim" \
    shell "zsh" \
    logs "tail -f logs.txt"
```

### Windows from File

Read window definitions from a file. Each line should contain a name followed by the command.

```bash
# windows.txt:
# editor nvim
# shell zsh
# logs tail -f logs.txt

pixi run tmux-grid windows-file my-dev windows.txt
```

### Session Management

- **Attach**: `pixi run tmux-grid attach <SESSION_NAME>`
- **Detach**: `pixi run tmux-grid detach` (must be run inside a tmux session)
- **Destroy**: `pixi run tmux-grid destroy <SESSION_NAME>`

## Development

This project uses `pixi` for development workflow management.

### Prerequisites

- [pixi](https://prefix.dev/)

### Setup

```bash
pixi install
```

### Available Commands

The following commands are defined in `pyproject.toml` and can be run via `pixi run <task>`:

- **Linting**: Check code style and common errors.
  ```bash
  pixi run lint
  ```

- **Lint with Fix**: Automatically fix linting errors where possible.
  ```bash
  pixi run lint-fix
  ```

- **Formatting**: Format code using `ruff`.
  ```bash
  pixi run fmt
  ```

- **Type Checking**: Run static type analysis with `pyright`.
  ```bash
  pixi run typecheck
  ```

- **Testing**: Run the test suite with `pytest`.
  ```bash
  pixi run test
  ```

- **Full Check**: Run type checking, linting, and tests in one go.
  ```bash
  pixi run check
  ```

- **Pre-commit**: Run pre-commit hooks on all files.
  ```bash
  pixi run pre-commit
  ```
