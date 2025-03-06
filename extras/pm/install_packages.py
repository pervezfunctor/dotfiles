import yaml
import subprocess
import argparse
import logging
import sys
from typing import Dict, List, NoReturn, Optional
from datetime import datetime

DEFAULT_COMMANDS: Dict[str, str] = {
    'apt': 'sudo apt-get -qq -y install',
    'brew': 'brew install -q',
    'pixi': 'pixi global install',
    'dnf': 'sudo dnf -q -y install',
    'zypper': 'sudo zypper --non-interactive --quiet install --auto-agree-with-licenses',
    'stow': 'stow -d $DOT_DIR -t $HOME --dotfiles -R',
    'pacman': 'sudo pacman -S --quiet --noconfirm',
    'flatpak': 'flatpak install -y --user',
    'flathub': 'flatpak install -y --user flathub',
    'cargo': 'cargo +stable install --locked',
    'pnpm': 'pnpm install -g',
    'go': 'go install'
}

UPDATE_COMMANDS: Dict[str, str] = {
    'apt': 'sudo apt-get -qq update && sudo apt-get -qq upgrade -y',
    'brew': 'brew update && brew upgrade',
    'pixi': 'pixi self update',
    'dnf': 'sudo dnf -q update -y && sudo dnf -q upgrade -y',
    'zypper': 'sudo zypper refresh && sudo zypper --non-interactive --quiet dup',
    'pacman': 'sudo pacman -Syu --noconfirm --quiet',
    'flatpak': 'flatpak update -y --user',
    'cargo': 'cargo install-update -a',
    'pnpm': 'pnpm update -g',
}

def setup_logging(verbose: bool) -> None:
    """Configure logging with both file and console handlers."""
    from pathlib import Path
    Path("logs").mkdir(exist_ok=True)

    timestamp: str = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file: str = f"logs/install_packages_{timestamp}.log"

    file_formatter: logging.Formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    console_formatter: logging.Formatter = logging.Formatter(
        '%(levelname)s: %(message)s'
    )

    file_handler: logging.FileHandler = logging.FileHandler(log_file)
    file_handler.setFormatter(file_formatter)
    file_handler.setLevel(logging.DEBUG)

    console_handler: logging.StreamHandler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(console_formatter)
    console_handler.setLevel(logging.INFO if not verbose else logging.DEBUG)

    root_logger: logging.Logger = logging.getLogger()
    root_logger.setLevel(logging.DEBUG)
    root_logger.addHandler(file_handler)
    root_logger.addHandler(console_handler)

def run_system_command(command: str, ignore_errors: bool = False) -> None:
    """Execute a system command and handle its output."""
    logger: logging.Logger = logging.getLogger(__name__)
    logger.info(f"Running: {command}")

    try:
        result: subprocess.CompletedProcess = subprocess.run(
            command,
            shell=True,
            check=not ignore_errors,
            capture_output=True,
            text=True
        )
        logger.debug(f"Command output: {result.stdout}")

        if result.returncode != 0:
            logger.warning(f"Command returned non-zero exit code: {result.returncode}")
            logger.debug(f"Error output: {result.stderr}")

    except subprocess.CalledProcessError as e:
        logger.error(f"Error running '{command}': {e}")
        logger.debug(f"Error output: {e.stderr}")
        if not ignore_errors:
            raise

def update_package_manager(command_key: str) -> None:
    """Update package manager if update command exists."""
    logger: logging.Logger = logging.getLogger(__name__)

    if command_key in UPDATE_COMMANDS:
        logger.info(f"Updating package manager: {command_key}")
        try:
            run_system_command(UPDATE_COMMANDS[command_key])
        except subprocess.CalledProcessError:
            logger.error(f"Failed to update package manager: {command_key}")
            raise

def run_command(command: str, packages: List[str], command_key: str, update: bool) -> None:
    """Execute command for each package in the list."""
    logger: logging.Logger = logging.getLogger(__name__)

    if update and command_key in UPDATE_COMMANDS:
        try:
            update_package_manager(command_key)
        except subprocess.CalledProcessError:
            logger.error("Package manager update failed, skipping installation")
            return

    for package in packages:
        full_command: str = f"{command} {package}"
        try:
            run_system_command(full_command)
        except subprocess.CalledProcessError:
            logger.error(f"Failed to install package: {package}")

def process_packages(yaml_file: str, update: bool) -> None:
    """Process the YAML file and execute commands."""
    logger: logging.Logger = logging.getLogger(__name__)

    try:
        logger.debug(f"Reading YAML file: {yaml_file}")
        with open(yaml_file, 'r') as f:
            packages: Dict[str, List[str]] = yaml.safe_load(f)

        for command_key, package_list in packages.items():
            if command_key in DEFAULT_COMMANDS:
                logger.info(f"Processing {command_key} packages: {package_list}")
                run_command(DEFAULT_COMMANDS[command_key], package_list, command_key, update)
            else:
                logger.warning(f"Unknown command '{command_key}', skipping...")

    except FileNotFoundError:
        logger.error(f"YAML file not found: {yaml_file}")
        sys.exit(1)
    except yaml.YAMLError as e:
        logger.error(f"Error parsing YAML file: {e}")
        sys.exit(1)
    except Exception as e:
        logger.exception(f"Unexpected error: {e}")
        sys.exit(1)

def main() -> None:
    """Main entry point of the script."""
    parser: argparse.ArgumentParser = argparse.ArgumentParser(
        description='Setup your computer using YAML definitions'
    )

    parser.add_argument('yaml_file', help='YAML file containing package definitions')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Enable verbose output')
    parser.add_argument('-u', '--update', action='store_true',
                       help='Update package managers before installation')
    args: argparse.Namespace = parser.parse_args()

    setup_logging(args.verbose)
    logger: logging.Logger = logging.getLogger(__name__)

    logger.info("Starting package installation")
    try:
        process_packages(args.yaml_file, args.update)
        logger.info("Installation completed successfully")
    except KeyboardInterrupt:
        logger.warning("Installation interrupted by user")
        sys.exit(1)

if __name__ == "__main__":
    main()
