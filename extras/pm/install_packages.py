#!/usr/bin/env python3
"""Package installer that supports multiple package managers."""

#! dependencies
#! pip install pyyaml typing-extensions pydantic
#! pip install --dev ruff mypy pyright

import argparse
import logging
import subprocess
import sys
from datetime import datetime
from enum import Enum
from typing import Dict, List, Union

import yaml
from pydantic import BaseModel, Field, ValidationError


class PackageManager(str, Enum):
    APT = "apt"
    BREW = "brew"
    PIXI = "pixi"
    DNF = "dnf"
    ZYPPER = "zypper"
    STOW = "stow"
    PACMAN = "pacman"
    FLATPAK = "flatpak"
    FLATHUB = "flathub"
    CARGO = "cargo"
    PNPM = "pnpm"
    GO = "go"
    PIP = "pip"
    NPM = "npm"


class CommandConfig(BaseModel):
    packages: List[str] = Field(default_factory=list)
    pre: List[str] = Field(default_factory=list)
    post: List[str] = Field(default_factory=list)


class PackageConfig(BaseModel):
    packages: Dict[PackageManager, Union[List[str], CommandConfig]]


DEFAULT_COMMANDS: Dict[PackageManager, str] = {
    PackageManager.APT: "sudo apt-get -qq -y install",
    PackageManager.BREW: "brew install -q",
    PackageManager.PIXI: "pixi global install",
    PackageManager.DNF: "sudo dnf -q -y install",
    PackageManager.ZYPPER: "sudo zypper --non-interactive --quiet install --auto-agree-with-licenses",
    PackageManager.STOW: "stow -d $DOT_DIR -t $HOME --dotfiles -R",
    PackageManager.PACMAN: "sudo pacman -S --quiet --noconfirm",
    PackageManager.FLATPAK: "flatpak install -y --user",
    PackageManager.FLATHUB: "flatpak install -y --user flathub",
    PackageManager.CARGO: "cargo +stable install --locked",
    PackageManager.PNPM: "pnpm install -g",
    PackageManager.GO: "go install",
    PackageManager.PIP: "pip install",
    PackageManager.NPM: "npm install -g",
}

UPDATE_COMMANDS: Dict[PackageManager, str] = {
    PackageManager.APT: "sudo apt-get -qq update && sudo apt-get -qq upgrade -y",
    PackageManager.BREW: "brew update && brew upgrade",
    PackageManager.PIXI: "pixi self update",
    PackageManager.DNF: "sudo dnf -q update -y && sudo dnf -q upgrade -y",
    PackageManager.ZYPPER: "sudo zypper refresh && sudo zypper --non-interactive --quiet dup",
    PackageManager.PACMAN: "sudo pacman -Syu --noconfirm --quiet",
    PackageManager.FLATPAK: "flatpak update -y --user",
    PackageManager.CARGO: "cargo install-update -a",
    PackageManager.PNPM: "pnpm update -g",
    PackageManager.PIP: "pip install --upgrade pip",
    PackageManager.NPM: "npm update -g",
}


def setup_logging(verbose: bool) -> None:
    """Configure logging with both file and console handlers."""
    from pathlib import Path

    Path("logs").mkdir(exist_ok=True)

    timestamp: str = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file: str = f"logs/install_packages_{timestamp}.log"

    file_formatter: logging.Formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    console_formatter: logging.Formatter = logging.Formatter("%(levelname)s: %(message)s")

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
            command, shell=True, check=not ignore_errors, capture_output=True, text=True
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


def run_hook_commands(commands: List[str], hook_type: str, command_key: str) -> None:
    """Execute hook commands and handle any errors."""
    logger: logging.Logger = logging.getLogger(__name__)

    if not commands:
        return

    logger.info(f"Running {hook_type} commands for {command_key}")
    for cmd in commands:
        try:
            run_system_command(cmd)
        except subprocess.CalledProcessError:
            logger.error(f"Failed to execute {hook_type} command for {command_key}: {cmd}")
            if hook_type == "pre":
                raise


def update_package_manager(package_manager: PackageManager) -> None:
    """Update package manager if update command exists."""
    logger: logging.Logger = logging.getLogger(__name__)

    if package_manager in UPDATE_COMMANDS:
        logger.info(f"Updating package manager: {package_manager}")
        try:
            run_system_command(UPDATE_COMMANDS[package_manager])
        except subprocess.CalledProcessError:
            logger.error(f"Failed to update package manager: {package_manager}")
            raise


def run_command(
    command: str, config: CommandConfig, package_manager: PackageManager, update: bool
) -> None:
    """Execute command for each package in the list."""
    logger: logging.Logger = logging.getLogger(__name__)

    if update and package_manager in UPDATE_COMMANDS:
        try:
            update_package_manager(package_manager)
        except subprocess.CalledProcessError:
            logger.error("Package manager update failed, skipping installation")
            return

    try:
        run_hook_commands(config.get("pre", []), "pre", str(package_manager))
    except subprocess.CalledProcessError:
        logger.error(f"Pre-install commands failed for {package_manager}, skipping installation")
        return

    packages = config.get("packages", [])
    for package in packages:
        full_command: str = f"{command} {package}"
        try:
            run_system_command(full_command)
        except subprocess.CalledProcessError:
            logger.error(f"Failed to install package: {package}")
            continue

    run_hook_commands(config.get("post", []), "post", str(package_manager))


def process_packages(yaml_file: str, update: bool) -> None:
    """Process the YAML file and execute commands."""
    logger: logging.Logger = logging.getLogger(__name__)

    try:
        logger.debug(f"Reading YAML file: {yaml_file}")
        with open(yaml_file, "r") as f:
            raw_config = yaml.safe_load(f)
            config = PackageConfig(packages=raw_config)

        for package_manager, command_config in config.packages.items():
            if isinstance(command_config, list):
                command_config = CommandConfig(packages=command_config)

            if package_manager not in DEFAULT_COMMANDS:
                logger.warning(f"No default command for '{package_manager}', skipping...")
                continue

            logger.info(f"Processing {package_manager} configuration")
            run_command(DEFAULT_COMMANDS[package_manager], command_config, package_manager, update)

    except ValidationError as e:
        logger.error(f"Invalid configuration: {e}")
        sys.exit(1)
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
        description="Setup your computer using YAML definitions"
    )

    parser.add_argument("yaml_file", help="YAML file containing package definitions")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
    parser.add_argument(
        "-u", "--update", action="store_true", help="Update package managers before installation"
    )
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
