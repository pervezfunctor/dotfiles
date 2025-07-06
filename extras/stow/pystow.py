#!/usr/bin/env python3

import argparse
from datetime import datetime
import functools
import os
from pathlib import Path
import sys

DEFAULT_IGNORES: set[str] = {
    ".git",
    ".gitignore",
    ".DS_Store",
    "README.md",
    ".stowignore",
}


@functools.cache
def get_ignore_patterns(start_dir: Path) -> set[str]:
    """
    Finds a .stowignore file by searching from start_dir up to its ancestors.

    If found, it parses the file and returns a set of ignore patterns.
    If not found, it returns the DEFAULT_IGNORES set.

    The results are cached, so the file system is only searched once per
    unique start_dir path during the script's execution.

    Args:
        start_dir: The directory to begin the search from.

    Returns:
        A set of strings, where each string is a filename/dirname to ignore.
    """
    current_dir = start_dir.resolve()

    while True:
        ignore_file_path = current_dir / ".stowignore"
        if ignore_file_path.is_file():
            try:
                with ignore_file_path.open("r", encoding="utf-8") as f:
                    lines = f.read().splitlines()

                patterns = {
                    line.strip()
                    for line in lines
                    if line.strip() and not line.strip().startswith("#")
                }
                patterns.add(".stowignore")
                return patterns
            except OSError as e:
                print(f"Warning: Found '{ignore_file_path}' but could not read it: {e}")
                return DEFAULT_IGNORES

        if current_dir.parent == current_dir:
            break

        current_dir = current_dir.parent

    return DEFAULT_IGNORES


def should_ignore_file(item_path: Path, source_dir: Path) -> bool:
    """
    Determines if a file or directory should be ignored based on .stowignore rules.

    This function checks if the base name of the item_path (e.g., 'dot-zshrc')
    exists in the ignore patterns loaded from the relevant .stowignore file or
    the default list.

    Args:
        item_path: The path to the file or directory being considered.
        source_dir: The root directory of the stow operation, which serves
                    as the starting point for finding .stowignore.

    Returns:
        True if the item should be ignored, False otherwise.
    """
    ignore_patterns = get_ignore_patterns(source_dir)

    return item_path.name in ignore_patterns


IGNORED_ITEMS: set[str] = {".git", ".gitignore", ".DS_Store", "README.md"}


def replace_dot(name: str) -> str:
    """
    Transforms a source name to its target equivalent.
    Replaces a "dot-" prefix with a single "."

    Examples:
      "dot-zshrc" -> ".zshrc"
      "dot-config" -> ".config"
      "bin" -> "bin"
    """
    if name.startswith("dot-"):
        return "." + name[4:]
    return name


def create_backup(target_path: Path, dry_run: bool, verbose: bool) -> None:
    """
    Moves a file or directory to a timestamped backup location.
    """
    timestamp = datetime.now().strftime("%Y-%m-%dT%H%M%S")
    backup_path = Path(f"{target_path}.bak.{timestamp}")

    action = "Would move" if dry_run else "Moving"
    print(f"  - {action} existing target [ {target_path} ] to [ {backup_path} ]")

    if not dry_run:
        try:
            target_path.rename(backup_path)
        except OSError as e:
            print(
                f"Error: Could not create backup for '{target_path}'. {e}",
                file=sys.stderr,
            )
            raise


def link_package(
    package_path: Path, target_dir: Path, force: bool, dry_run: bool, verbose: bool
) -> None:
    """
    Processes a single package (file or directory) from the source directory,
    handling name mangling, conflict resolution, and symlinking.
    """
    if package_path.name in IGNORED_ITEMS:
        if verbose:
            print(f"Ignoring [ {package_path.name} ]")
        return

    mangled_name = replace_dot(package_path.name)
    target_path = target_dir / mangled_name

    print(f"Processing [ {package_path.name} ] -> [ {target_path} ]")

    if target_path.exists():
        if target_path.is_symlink() and target_path.resolve() == package_path.resolve():
            print("  - Correct link already exists. Skipping.")
            return

        if not force:
            print(
                f"Error: Target '{target_path}' already exists. Use --force to overwrite.",  # noqa: E501
                file=sys.stderr,
            )
            raise FileExistsError(f"Target conflict at {target_path}")

        print(f"  - Conflict found at [ {target_path} ]")
        create_backup(target_path, dry_run, verbose)

    action = "Would link" if dry_run else "Linking"
    print(f"  - {action} [ {package_path} ] -> [ {target_path} ]")

    if not dry_run:
        try:
            target_path.parent.mkdir(parents=True, exist_ok=True)

            os.symlink(package_path, target_path)
        except OSError as e:
            print(
                f"Error: Could not create symlink for '{package_path}'. {e}",
                file=sys.stderr,
            )
            raise


def stow() -> None:
    """
    Main function to parse arguments and orchestrate the stowing process.
    """
    parser = argparse.ArgumentParser(
        description="A simple stow-like utility to link dotfiles.",
        formatter_class=argparse.RawTextHelpFormatter,
        epilog="""
Example Usage:
  # Stow files from '~/dotfiles' into your home directory ('~')
  python pystow.py ~/dotfiles ~

  # Do a dry run to see what would happen
  python pystow.py --dry-run ~/dotfiles ~

  # Forcefully replace existing files/directories, backing them up first
  python pystow.py --force ~/dotfiles ~
""",
    )
    parser.add_argument(
        "source_dir",
        type=Path,
        help="The source directory containing your dotfiles (e.g., 'dot-zshrc').",
    )
    parser.add_argument(
        "target_dir",
        type=Path,
        help="The target directory where symlinks will be created (e.g., your home '~').",  # noqa: E501
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="If a target file/dir exists, move it to a .bak file before linking.",
    )
    parser.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        help="Show what would be done without making any changes.",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Enable verbose output."
    )

    args = parser.parse_args()

    if not args.source_dir.is_dir():
        print(
            f"Error: Source directory not found at '{args.source_dir}'", file=sys.stderr
        )
        sys.exit(1)

    if not args.target_dir.is_dir():
        print(
            f"Error: Target directory not found at '{args.target_dir}'", file=sys.stderr
        )
        sys.exit(1)

    source_dir = args.source_dir.resolve()
    target_dir = args.target_dir.resolve()

    if source_dir == target_dir:
        print(
            "Error: Source and target directories cannot be the same.", file=sys.stderr
        )
        sys.exit(1)

    if args.dry_run:
        print("--- DRY RUN MODE: No changes will be made. ---")

    print(f"Source: {source_dir}")
    print(f"Target: {target_dir}\n")

    packages_to_link: list[Path] = list(source_dir.iterdir())

    if not packages_to_link:
        print("Source directory is empty. Nothing to do.")
        sys.exit(0)

    try:
        for package_path in sorted(packages_to_link):
            link_package(
                package_path, target_dir, args.force, args.dry_run, args.verbose
            )
    except (FileExistsError, OSError) as e:
        print(f"\nOperation failed: {e}", file=sys.stderr)
        sys.exit(1)

    print("\n✨ Done.")


if __name__ == "__main__":
    stow()
