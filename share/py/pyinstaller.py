#!/usr/bin/env python3
"""
Caelestia Dotfiles Installer
A modern, type-safe installer for Caelestia desktop environment configurations.
"""

import sys
import time
from enum import Enum
from pathlib import Path

import sh
import typer
from loguru import logger
from pydantic import BaseModel, Field, validator
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.prompt import Confirm, Prompt
from sh import ErrorReturnCode

# ============================================================================
# Configuration & Types
# ============================================================================

class AURHelper(str, Enum):
    """Supported AUR helpers"""
    YAY = "yay"
    PARU = "paru"


class VSCodeVariant(str, Enum):
    """VSCode variants"""
    CODE = "code"
    CODIUM = "codium"


class InstallConfig(BaseModel):
    """Installation configuration with validation"""
    noconfirm: bool = Field(False, description="Skip confirmation prompts")
    spotify: bool = Field(False, description="Install Spotify with Spicetify")
    vscode: VSCodeVariant | None = Field(None, description="VSCode variant to install")
    discord: bool = Field(False, description="Install Discord with Equicord")
    zen: bool = Field(False, description="Install Zen browser")
    aur_helper: AURHelper = Field(AURHelper.PARU, description="AUR helper to use")

    # Computed paths
    config_dir: Path = Field(default_factory=lambda: Path.home() / ".config")
    state_dir: Path = Field(default_factory=lambda: Path.home() / ".local/state")
    script_dir: Path = Field(default_factory=lambda: Path(__file__).parent.resolve())

    @validator('config_dir', 'state_dir', pre=True)
    def resolve_xdg_paths(cls, v, values, field):
        """Resolve XDG base directories from environment"""
        if field.name == 'config_dir':
            return Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
        elif field.name == 'state_dir':
            return Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state'))
        return v

    class Config:
        use_enum_values = True


# ============================================================================
# Global Setup
# ============================================================================

console = Console()
app = typer.Typer(
    help="Caelestia Dotfiles Installer - Modern Arch Linux desktop setup",
    add_completion=True,
    rich_markup_mode="rich"
)

# Configure logging
def setup_logging(config: InstallConfig) -> None:
    """Setup dual logging: console (Rich) + file (JSON)"""
    log_file = config.state_dir / "caelestia" / "install.log"
    log_file.parent.mkdir(parents=True, exist_ok=True)

    # Remove default handler
    logger.remove()

    # Add file handler with rotation
    logger.add(
        log_file,
        rotation="10 MB",
        retention=3,
        level="DEBUG",
        format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} | {message}",
        backtrace=True,
        diagnose=True,
    )

    # Add console handler (INFO level only)
    logger.add(
        sys.stderr,
        level="INFO",
        format="<level>{message}</level>",
        colorize=True,
    )


# ============================================================================
# Utility Functions
# ============================================================================

def run_command(
    *cmd: str,
    cwd: Path | None = None,
    check: bool = True,
    silent: bool = False,
    **kwargs
) -> str | None:
    """
    Run a shell command with better error handling

    Args:
        *cmd: Command and arguments
        cwd: Working directory
        check: Raise exception on failure
        silent: Suppress output
        **kwargs: Additional sh arguments

    Returns:
        Command output if successful, None if failed and check=False
    """
    try:
        cmd_str = ' '.join(cmd)
        logger.debug(f"Running command: {cmd_str}", cwd=str(cwd) if cwd else None)

        # Build sh command
        sh_cmd = sh.Command(cmd[0])
        result = sh_cmd(
            *cmd[1:],
            _cwd=str(cwd) if cwd else None,
            _out=None if silent else sys.stdout,
            _err=None if silent else sys.stderr,
            **kwargs
        )

        return str(result) if result else None

    except ErrorReturnCode as e:
        logger.error(f"Command failed: {cmd_str}", exit_code=e.exit_code)
        if check:
            raise
        return None


def is_package_installed(package: str) -> bool:
    """Check if a pacman package is installed"""
    try:
        sh.pacman("-Q", package, _out=None, _err=None)
        return True
    except ErrorReturnCode:
        return False


def create_symlink(source: Path, dest: Path, force: bool = False) -> None:
    """
    Create a symbolic link with proper error handling

    Args:
        source: Source path (will be resolved to absolute)
        dest: Destination path
        force: Force overwrite if destination exists
    """
    source = source.resolve()
    dest.parent.mkdir(parents=True, exist_ok=True)

    if dest.exists() or dest.is_symlink():
        if force:
            if dest.is_dir() and not dest.is_symlink():
                sh.rm("-rf", str(dest))
            else:
                dest.unlink()
        else:
            raise FileExistsError(f"Destination already exists: {dest}")

    dest.symlink_to(source)
    logger.info(f"Created symlink: {dest} -> {source}")


def confirm_overwrite(path: Path, noconfirm: bool = False) -> bool:
    """
    Confirm whether to overwrite an existing path

    Args:
        path: Path to check
        noconfirm: Skip confirmation if True

    Returns:
        True if should proceed, False if should skip
    """
    if not (path.exists() or path.is_symlink()):
        return True

    if noconfirm:
        console.print(f"[yellow]⚠[/yellow] {path} already exists, removing...")
        logger.warning(f"Overwriting without confirmation: {path}")
        if path.is_dir() and not path.is_symlink():
            sh.rm("-rf", str(path))
        else:
            path.unlink(missing_ok=True)
        return True

    if Confirm.ask(f"[yellow]{path}[/yellow] already exists. Overwrite?", default=False):
        console.print("[cyan]Removing...[/cyan]")
        logger.info(f"User confirmed overwrite: {path}")
        if path.is_dir() and not path.is_symlink():
            sh.rm("-rf", str(path))
        else:
            path.unlink(missing_ok=True)
        return True

    console.print("[dim]Skipping...[/dim]")
    logger.info(f"User skipped overwrite: {path}")
    return False


# ============================================================================
# Installation Functions
# ============================================================================

def print_banner() -> None:
    """Print the Caelestia startup banner"""
    banner_text = """[magenta bold]
╭─────────────────────────────────────────────────╮
│      ______           __          __  _         │
│     / / ____  / /_  / /  \\ (_)   │
│    / /   / __ \\/ _ \\/ / _ \\/ ___/ __/ / __ \\   │
│   / /  __/ /_/ /  __/ /  __(__  ) /_/ / /_/ /   │
│   \\_/\\____/\\__,_/\\___/_/\\___/____/\\__/_/\\__/     │
│                                                 │
╰─────────────────────────────────────────────────╯[/magenta bold]"""

    console.print(Panel(banner_text, border_style="magenta", padding=(0, 2)))
    console.print("[cyan bold]Welcome to the Caelestia dotfiles installer![/cyan bold]")
    console.print("[yellow]⚠  Please ensure you have backed up your config directory.[/yellow]\n")


def prompt_for_backup(config: InstallConfig) -> None:
    """Prompt user to create a backup of their config directory"""
    if config.noconfirm:
        logger.info("Skipping backup prompt (noconfirm mode)")
        return

    choice = Prompt.ask(
        "Create a backup of your config directory?",
        choices=["yes", "no", "already"],
        default="already"
    )

    if choice == "already":
        console.print("[green]✓[/green] Great! Proceeding with installation...\n")
        logger.info("User already has backup")
        return

    if choice == "no":
        console.print("[dim]Proceeding without backup...[/dim]\n")
        logger.warning("User declined backup")
        return

    # Create backup
    backup_path = Path(f"{config.config_dir}.bak")

    if backup_path.exists():
        if not Confirm.ask(f"Backup already exists at {backup_path}. Overwrite?", default=False):
            console.print("[dim]Skipping backup...[/dim]\n")
            return
        sh.rm("-rf", str(backup_path))

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        progress.add_task(f"Backing up {config.config_dir}...", total=None)
        sh.cp("-r", str(config.config_dir), str(backup_path))

    console.print(f"[green]✓[/green] Backup created at {backup_path}\n")
    logger.info(f"Created backup at {backup_path}")


def install_aur_helper(config: InstallConfig) -> None:
    """Install AUR helper if not already installed"""
    aur_helper = config.aur_helper

    if is_package_installed(aur_helper):
        console.print(f"[green]✓[/green] {aur_helper} already installed")
        logger.info(f"{aur_helper} already installed")
        return

    console.print(f"[cyan bold]:: Installing {aur_helper}...[/cyan bold]")
    logger.info(f"Installing AUR helper: {aur_helper}")

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        # Install dependencies
        task = progress.add_task("Installing dependencies...", total=None)
        cmd_args = ["sudo", "pacman", "-S", "--needed", "git", "base-devel"]
        if config.noconfirm:
            cmd_args.append("--noconfirm")
        run_command(*cmd_args, silent=True)

        # Clone repository
        progress.update(task, description=f"Cloning {aur_helper} repository...")
        tmp_dir = Path("/tmp") / aur_helper
        if tmp_dir.exists():
            sh.rm("-rf", str(tmp_dir))
        sh.git.clone(f"https://aur.archlinux.org/{aur_helper}.git", str(tmp_dir), _out=None)

        # Build and install
        progress.update(task, description=f"Building {aur_helper}...")
        sh.makepkg("-si", _cwd=str(tmp_dir), _fg=True)

        # Cleanup
        sh.rm("-rf", str(tmp_dir))

    # Setup AUR helper
    console.print(f"[cyan]Configuring {aur_helper}...[/cyan]")
    if aur_helper == "yay":
        sh.Command(aur_helper)("-Y", "--gendb", _out=None)
        sh.Command(aur_helper)("-Y", "--devel", "--save", _out=None)
    else:
        sh.Command(aur_helper)("--gendb", _out=None)

    console.print(f"[green]✓[/green] {aur_helper} installed successfully\n")
    logger.info(f"{aur_helper} installation complete")


def install_metapackage(config: InstallConfig) -> None:
    """Install the Caelestia metapackage"""
    console.print("[cyan bold]:: Installing Caelestia metapackage...[/cyan bold]")
    logger.info("Installing metapackage")

    aur_cmd = sh.Command(config.aur_helper)

    try:
        if config.aur_helper == "yay":
            args = ["-Bi", "."]
        else:
            args = ["-Ui"]

        if config.noconfirm:
            args.append("--noconfirm")

        aur_cmd(*args, _cwd=str(config.script_dir), _fg=True)

        # Cleanup built packages
        for pkg in config.script_dir.glob("caelestia-meta-*.pkg.tar.zst"):
            pkg.unlink()

        console.print("[green]✓[/green] Metapackage installed\n")
        logger.info("Metapackage installation complete")

    except ErrorReturnCode as e:
        console.print("[red]✗[/red] Failed to install metapackage")
        logger.error("Metapackage installation failed", error=str(e))
        raise


def install_config_links(config: InstallConfig) -> None:
    """Install configuration file symlinks"""
    configs = [
        ("hypr", config.config_dir / "hypr", True),  # (source, dest, reload_hypr)
        ("starship.toml", config.config_dir / "starship.toml", False),
        ("foot", config.config_dir / "foot", False),
        ("fish", config.config_dir / "fish", False),
        ("fastfetch", config.config_dir / "fastfetch", False),
        ("uwsm", config.config_dir / "uwsm", False),
        ("btop", config.config_dir / "btop", False),
    ]

    console.print("[cyan bold]:: Installing configuration files...[/cyan bold]")

    for source_name, dest_path, reload_hypr in configs:
        source_path = config.script_dir / source_name

        if not source_path.exists():
            logger.warning(f"Source not found: {source_path}")
            continue

        if confirm_overwrite(dest_path, config.noconfirm):
            console.print(f"[cyan]→[/cyan] Installing {source_name}...")
            create_symlink(source_path, dest_path, force=True)
            console.print(f"[green]✓[/green] {source_name} installed")

            if reload_hypr:
                try:
                    sh.hyprctl("reload", _out=None, _err=None)
                    console.print("[dim]  Reloaded Hyprland config[/dim]")
                except ErrorReturnCode:
                    logger.warning("Could not reload Hyprland")

    console.print()


def install_spotify(config: InstallConfig) -> None:
    """Install Spotify with Spicetify"""
    console.print("[cyan bold]:: Installing Spotify (Spicetify)...[/cyan bold]")
    logger.info("Installing Spotify with Spicetify")

    has_spicetify = is_package_installed("spicetify-cli")

    # Install packages
    aur_cmd = sh.Command(config.aur_helper)
    args = ["-S", "--needed", "spotify", "spicetify-cli", "spicetify-marketplace-bin"]
    if config.noconfirm:
        args.append("--noconfirm")

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        progress.add_task("Installing Spotify packages...", total=None)
        aur_cmd(*args, _fg=True)

    # Set permissions on first install
    if not has_spicetify:
        console.print("[cyan]Setting Spotify permissions...[/cyan]")
        sh.sudo.chmod("a+wr", "/opt/spotify")
        sh.sudo.chmod("a+wr", "/opt/spotify/Apps", "-R")
        sh.spicetify("backup", "apply", _out=None)

    # Install config
    spicetify_config = config.config_dir / "spicetify"
    if confirm_overwrite(spicetify_config, config.noconfirm):
        console.print("[cyan]Installing Spicetify config...[/cyan]")
        create_symlink(config.script_dir / "spicetify", spicetify_config, force=True)

        # Configure theme
        sh.spicetify(
            "config",
            "current_theme", "caelestia",
            "color_scheme", "caelestia",
            "custom_apps", "marketplace",
            _out=None,
            _err=None
        )
        sh.spicetify("apply", _fg=True)
        console.print("[green]✓[/green] Spicetify configured")

    console.print("[green]✓[/green] Spotify installation complete\n")
    logger.info("Spotify installation complete")


def install_vscode(config: InstallConfig) -> None:
    """Install VSCode or VSCodium"""
    if not config.vscode:
        return

    variant = config.vscode
    prog = "code" if variant == VSCodeVariant.CODE else "codium"

    console.print(f"[cyan bold]:: Installing VS{prog.title()}...[/cyan bold]")
    logger.info(f"Installing VSCode variant: {variant}")

    # Determine packages
    if variant == VSCodeVariant.CODE:
        packages = ["code"]
        folder_name = "Code"
    else:
        packages = ["vscodium-bin", "vscodium-bin-marketplace"]
        folder_name = "VSCodium"

    # Install packages
    aur_cmd = sh.Command(config.aur_helper)
    args = ["-S", "--needed"] + packages
    if config.noconfirm:
        args.append("--noconfirm")

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        progress.add_task(f"Installing VS{prog.title()}...", total=None)
        aur_cmd(*args, _fg=True)

    # Install configs
    user_folder = config.config_dir / folder_name / "User"
    settings_json = user_folder / "settings.json"
    keybindings_json = user_folder / "keybindings.json"
    flags_conf = config.config_dir / f"{prog}-flags.conf"

    all_confirmed = (
        confirm_overwrite(settings_json, config.noconfirm) and
        confirm_overwrite(keybindings_json, config.noconfirm) and
        confirm_overwrite(flags_conf, config.noconfirm)
    )

    if all_confirmed:
        console.print(f"[cyan]Installing VS{prog.title()} config...[/cyan]")
        user_folder.mkdir(parents=True, exist_ok=True)

        create_symlink(config.script_dir / "vscode/settings.json", settings_json, force=True)
        create_symlink(config.script_dir / "vscode/keybindings.json", keybindings_json, force=True)
        create_symlink(config.script_dir / "vscode/flags.conf", flags_conf, force=True)

        # Install extension
        vsix_pattern = "caelestia-vscode-integration-*.vsix"
        vsix_files = list((config.script_dir / "vscode/caelestia-vscode-integration").glob(vsix_pattern))

        if vsix_files:
            console.print("[cyan]Installing Caelestia extension...[/cyan]")
            sh.Command(prog)("--install-extension", str(vsix_files[0]), _out=None)
            console.print("[green]✓[/green] Extension installed")

    console.print(f"[green]✓[/green] VS{prog.title()} installation complete\n")
    logger.info(f"VS{prog.title()} installation complete")


def install_discord(config: InstallConfig) -> None:
    """Install Discord with OpenAsar and Equicord"""
    console.print("[cyan bold]:: Installing Discord...[/cyan bold]")
    logger.info("Installing Discord with OpenAsar and Equicord")

    # Install packages
    aur_cmd = sh.Command(config.aur_helper)
    args = ["-S", "--needed", "discord", "equicord-installer-bin"]
    if config.noconfirm:
        args.append("--noconfirm")

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        task = progress.add_task("Installing Discord...", total=None)
        aur_cmd(*args, _fg=True)

        # Install OpenAsar and Equicord
        progress.update(task, description="Installing OpenAsar...")
        sh.sudo.Equilotl("-install", "-location", "/opt/discord", _out=None)

        progress.update(task, description="Installing Equicord...")
        sh.sudo.Equilotl("-install-openasar", "-location", "/opt/discord", _out=None)

        # Remove installer
        progress.update(task, description="Cleaning up...")
        remove_args = ["-Rns", "equicord-installer-bin"]
        if config.noconfirm:
            remove_args.append("--noconfirm")
        aur_cmd(*remove_args, _out=None)

    console.print("[green]✓[/green] Discord installation complete\n")
    logger.info("Discord installation complete")


def install_zen(config: InstallConfig) -> None:
    """Install Zen browser"""
    console.print("[cyan bold]:: Installing Zen browser...[/cyan bold]")
    logger.info("Installing Zen browser")

    # Install package
    aur_cmd = sh.Command(config.aur_helper)
    args = ["-S", "--needed", "zen-browser-bin"]
    if config.noconfirm:
        args.append("--noconfirm")

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        progress.add_task("Installing Zen browser...", total=None)
        aur_cmd(*args, _fg=True)

    # Install userChrome
    zen_profiles = list(Path.home().glob(".zen/*/chrome"))
    if zen_profiles:
        chrome_path = zen_profiles[0]
        user_chrome = chrome_path / "userChrome.css"

        if confirm_overwrite(user_chrome, config.noconfirm):
            console.print("[cyan]Installing userChrome.css...[/cyan]")
            create_symlink(config.script_dir / "zen/userChrome.css", user_chrome, force=True)
            console.print("[green]✓[/green] userChrome installed")
    else:
        console.print("[yellow]⚠[/yellow] No Zen profile found, skipping userChrome")
        logger.warning("No Zen profile found for userChrome installation")

    # Install native app
    hosts_dir = Path.home() / ".mozilla/native-messaging-hosts"
    lib_dir = Path.home() / ".local/lib/caelestia"
    manifest_dest = hosts_dir / "caelestiafox.json"
    app_dest = lib_dir / "caelestiafox"

    if confirm_overwrite(manifest_dest, config.noconfirm):
        console.print("[cyan]Installing CaelestiaFox native app manifest...[/cyan]")
        hosts_dir.mkdir(parents=True, exist_ok=True)

        # Copy and modify manifest
        manifest_source = config.script_dir / "zen/native_app/manifest.json"
        sh.cp(str(manifest_source), str(manifest_dest))
        sh.sed("-i", f"s|{{{{ \\$lib }}}}|{lib_dir}|g", str(manifest_dest))
        console.print("[green]✓[/green] Manifest installed")

    if confirm_overwrite(app_dest, config.noconfirm):
        console.print("[cyan]Installing CaelestiaFox native app...[/cyan]")
        lib_dir.mkdir(parents=True, exist_ok=True)
        create_symlink(config.script_dir / "zen/native_app/app.fish", app_dest, force=True)
        console.print("[green]✓[/green] Native app installed")

    console.print("\n[yellow]ℹ[/yellow] Please install the CaelestiaFox extension:")
    console.print("  [link]https://addons.mozilla.org/en-US/firefox/addon/caelestiafox[/link]\n")

    console.print("[green]✓[/green] Zen browser installation complete\n")
    logger.info("Zen browser installation complete")


def initialize_caelestia(config: InstallConfig) -> None:
    """Initialize Caelestia scheme and shell"""
    console.print("[cyan bold]:: Initializing Caelestia...[/cyan bold]")

    scheme_file = config.state_dir / "caelestia/scheme.json"

    if not scheme_file.exists():
        console.print("[cyan]Generating default color scheme...[/cyan]")
        logger.info("Generating default color scheme")

        try:
            sh.caelestia("scheme", "set", "-n", "shadotheme", _out=None)
            time.sleep(0.5)
            sh.hyprctl("reload", _out=None, _err=None)
            console.print("[green]✓[/green] Color scheme initialized")
        except ErrorReturnCode as e:
            console.print("[yellow]⚠[/yellow] Could not initialize color scheme")
            logger.warning("Failed to initialize color scheme", error=str(e))

    # Start shell daemon
    console.print("[cyan]Starting Caelestia shell daemon...[/cyan]")
    try:
        sh.caelestia("shell", "-d", _out=None, _bg=True)
        console.print("[green]✓[/green] Shell daemon started")
        logger.info("Shell daemon started")
    except ErrorReturnCode as e:
        console.print("[yellow]⚠[/yellow] Could not start shell daemon")
        logger.warning("Failed to start shell daemon", error=str(e))

    console.print()


# ============================================================================
# Main Command
# ============================================================================

@app.command()
def install(
    noconfirm: bool = typer.Option(
        False,
        "--noconfirm",
        help="Skip all confirmation prompts"
    ),
    spotify: bool = typer.Option(
        False,
        "--spotify",
        help="Install Spotify with Spicetify customization"
    ),
    vscode: VSCodeVariant | None = typer.Option(
        None,
        "--vscode",
        help="Install VSCode variant (code or codium)"
    ),
    discord: bool = typer.Option(
        False,
        "--discord",
        help="Install Discord with OpenAsar and Equicord"
    ),
    zen: bool = typer.Option(
        False,
        "--zen",
        help="Install Zen browser with CaelestiaFox"
    ),
    aur_helper: AURHelper = typer.Option(
        AURHelper.PARU,
        "--aur-helper",
        help="AUR helper to use for package installation"
    ),
) -> None:
    """
    Install Caelestia dotfiles and optional applications.

    This installer will:
    - Set up configuration symlinks for Hyprland, Fish, and other tools
    - Install an AUR helper if not present
    - Optionally install Spotify, VSCode/VSCodium, Discord, or Zen browser
    - Initialize the Caelestia color scheme and shell daemon
    """
    # Build configuration
    config = InstallConfig(
        noconfirm=noconfirm,
        spotify=spotify,
        vscode=vscode,
        discord=discord,
        zen=zen,
        aur_helper=aur_helper,
    )

    # Setup logging
    setup_logging(config)
    logger.info("Starting Caelestia installation", config=config.dict())

    try:
        # Print banner
        print_banner()

        # Prompt for backup
        prompt_for_backup(config)

        # Install AUR helper
        install_aur_helper(config)

        # Change to script directory
        import os
        os.chdir(config.script_dir)

        # Install metapackage
        install_metapackage(config)

        # Install core configs
        install_config_links(config)

        # Install optional applications
        if config.spotify:
            install_spotify(config)

        if config.vscode:
            install_vscode(config)

        if config.discord:
            install_discord(config)

        if config.zen:
            install_zen(config)

        # Initialize Caelestia
        initialize_caelestia(config)

        # Success!
        console.print(Panel(
            "[green bold]✓ Installation complete![/green bold]\n\n"
            "Your Caelestia environment is ready to use.\n"
            "Log out and log back in for all changes to take effect.",
            border_style="green",
            padding=(1, 2)
        ))
        logger.info("Installation completed successfully")

    except KeyboardInterrupt:
        console.print("\n[yellow]Installation cancelled by user[/yellow]")
        logger.warning("Installation cancelled by user")
        sys.exit(130)

    except Exception as e:
        console.print(f"\n[red bold]✗ Installation failed:[/red bold] {e}")
        logger.exception("Installation failed with exception")
        sys.exit(1)


# ============================================================================
# Entry Point
# ============================================================================

if __name__ == "__main__":
    app()
