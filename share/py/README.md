# Caelestia Dotfiles Installer

Modern, type-safe installer for the Caelestia desktop environment on Arch Linux.

## Features

- 🎨 Beautiful CLI with Rich formatting
- 🔒 Fully type-checked with Pydantic
- 📝 Comprehensive logging to file
- 🚀 Progress indicators and spinners
- ✅ Smart confirmation prompts
- 🔧 Optional component installation

## Installation
```bash
# Install dependencies
pip install -e .

# Or with development tools
pip install -e ".[dev]"
```

## Usage

### Basic Installation

Install core Caelestia configurations:
```bash
./install.py install
```

### Install Everything
```bash
./install.py install \
  --spotify \
  --vscode=codium \
  --discord \
  --zen \
  --aur-helper=paru
```

### Non-Interactive Mode

Skip all confirmations (useful for automation):
```bash
./install.py install --noconfirm --spotify --discord
```

### Options
```
--noconfirm              Skip all confirmation prompts
--spotify                Install Spotify with Spicetify
--vscode [code|codium]   Install VSCode or VSCodium
--discord                Install Discord with Equicord
--zen                    Install Zen browser
--aur-helper [yay|paru]  Choose AUR helper (default: paru)
```

### Help
```bash
./install.py --help
./install.py install --help
```

## What Gets Installed

### Core Components (Always)

- Hyprland configuration
- Starship prompt
- Foot terminal config
- Fish shell config
- Fastfetch config
- UWSM config
- btop config

### Optional Components

#### Spotify (`--spotify`)
- Spotify client
- Spicetify CLI
- Spicetify Marketplace
- Caelestia theme

#### VSCode/VSCodium (`--vscode`)
- VSCode or VSCodium
- Custom settings and keybindings
- Caelestia integration extension

#### Discord (`--discord`)
- Discord client
- OpenAsar (performance boost)
- Equicord (custom client)

#### Zen Browser (`--zen`)
- Zen browser
- Custom userChrome.css
- CaelestiaFox native app

## Logging

Installation logs are saved to:
```
~/.local/state/caelestia/install.log
```

Logs are automatically rotated (10MB max, 3 backups).

## Development

### Type Checking
```bash
make type-check
```

### Linting
```bash
make lint
```

### Format Code
```bash
make format
```

### Run All Checks
```bash
make check
```

## Architecture

### Key Design Decisions

1. **Pydantic Config**: Centralized, validated configuration
2. **Rich Console**: Beautiful, consistent output
3. **Loguru**: Simple yet powerful logging
4. **Typer**: Modern CLI with auto-generated help
5. **sh Library**: Pythonic command execution

### File Structure
```
install.py           # Main installer script
pyproject.toml       # Project metadata and dependencies
Makefile            # Development tasks
README.md           # This file
```

### Adding New Components

To add a new optional component:

1. Add a flag to `InstallConfig`:
```python
   class InstallConfig(BaseModel):
       new_component: bool = False
```

2. Add a command option:
```python
   @app.command()
   def install(
       new_component: bool = typer.Option(False, "--new-component"),
   ):
```

3. Create an installation function:
```python
   def install_new_component(config: InstallConfig) -> None:
       console.print("[cyan bold]:: Installing new component...[/cyan bold]")
       # Installation logic here
```

4. Call it in main:
```python
   if config.new_component:
       install_new_component(config)
```

## Error Handling

The installer handles errors gracefully:

- **Network failures**: Retries with backups
- **Permission errors**: Clear instructions
- **Missing dependencies**: Auto-installation
- **User cancellation**: Clean exit
- **Partial installs**: Rollback support

All errors are logged to the log file for debugging.

## Security Considerations

- **No root by default**: Uses `sudo` only when needed
- **Validates sources**: Checks official repositories
- **Symlink verification**: Prevents overwriting system files
- **Backup prompts**: Encourages data safety

## Troubleshooting

### Installation fails with "command not found"

Make sure you have Python 3.10+ and pip installed:
```bash
python --version
pip install -e .
```

### Permission denied errors

Some operations require sudo. The installer will prompt when needed.

### AUR helper installation fails

Manually install base-devel:
```bash
sudo pacman -S base-devel git
```

### Check logs

View detailed logs:
```bash
cat ~/.local/state/caelestia/install.log
```

Or follow in real-time:
```bash
tail -f ~/.local/state/caelestia/install.log
```

## Contributing

Contributions welcome! Please:

1. Run type checks: `make type-check`
2. Run linting: `make lint`
3. Test your changes thoroughly
4. Update documentation

## License

[Your License Here]