# test_py

from collections.abc import Generator
from pathlib import Path
import sys
from typing import Any

from _pytest.capture import CaptureFixture
from _pytest.monkeypatch import MonkeyPatch
import pytest

from main import main
from pystow import get_ignore_patterns, replace_dot, should_ignore_file


def demonstrate_ignore_logic():
    """
    A function to create a temporary directory structure and test the logic.
    """
    # 1. Create a temporary directory structure for testing
    # /tmp/pystow_demo/
    # └── dotfiles/
    #     ├── .stowignore
    #     ├── dot-zshrc
    #     ├── dot-vimrc
    #     ├── README.md
    #     └── scripts/
    #         └── backup.sh

    print("--- Setting up test environment ---")

    # Use a temporary directory for a clean test
    import shutil
    import tempfile

    base_dir = Path(tempfile.gettempdir()) / "pystow_demo"
    if base_dir.exists():
        shutil.rmtree(base_dir)  # Clean up previous runs

    source_dir = base_dir / "dotfiles"
    source_dir.mkdir(parents=True)

    # Create a .stowignore file
    stowignore_content = """
    # This is a comment, it will be ignored.
    README.md

    # Ignore entire directories
    scripts
    """
    (source_dir / ".stowignore").write_text(stowignore_content)

    # Create some files and directories to check
    (source_dir / "dot-zshrc").touch()
    (source_dir / "dot-vimrc").touch()
    (source_dir / "README.md").touch()
    (source_dir / "scripts").mkdir()
    (source_dir / "scripts" / "backup.sh").touch()
    (
        source_dir / ".git"
    ).mkdir()  # This should be ignored by default list if .stowignore is missing

    print(f"Test directory created at: {source_dir}")
    print(f"Contents of .stowignore:\n{stowignore_content}\n")
    print("--- Running ignore checks ---")

    items_to_check = list(source_dir.iterdir())
    for item in sorted(items_to_check):
        is_ignored = should_ignore_file(item, source_dir=source_dir)
        status = "IGNORED" if is_ignored else "PROCESSED"
        print(f"Checking '{item.name}': {status}")

    # Demonstrate fallback to default ignores
    print("\n--- Testing fallback to default ignores ---")
    (source_dir / ".stowignore").unlink()  # Remove the ignore file

    # Clear the cache for get_ignore_patterns to force a re-evaluation
    get_ignore_patterns.cache_clear()

    print(".stowignore file removed.")
    for item in sorted(items_to_check):
        is_ignored = should_ignore_file(item, source_dir=source_dir)
        status = "IGNORED" if is_ignored else "PROCESSED"
        print(f"Checking '{item.name}': {status}")

    # Clean up the test directory
    shutil.rmtree(base_dir)
    print("\n--- Test environment cleaned up ---")


if __name__ == "__main__":
    demonstrate_ignore_logic()


@pytest.fixture
def fs_setup(tmp_path: Path) -> Generator[tuple[Path, Path]]:
    """
    A pytest fixture to create a temporary, clean file system structure for testing.
    - Creates a source and a target directory.
    - Yields the paths to the test function.
    - The `tmp_path` fixture is provided by pytest for temporary directories.
    """
    source_dir = tmp_path / "dotfiles"
    target_dir = tmp_path / "home"
    source_dir.mkdir()
    target_dir.mkdir()
    yield source_dir, target_dir


# --- Unit Tests for Helper Functions ---


@pytest.mark.parametrize(
    "input_name, expected_name",
    [
        ("dot-zshrc", ".zshrc"),
        ("dot-config", ".config"),
        ("bin", "bin"),
        ("nodot-prefix", "nodot-prefix"),
        ("", ""),
        ("dot-", "."),
    ],
)
def test_replace_dot(input_name: str, expected_name: str):
    """Tests the name mangling logic."""
    assert replace_dot(input_name) == expected_name


def test_ignore_logic_with_stowignore_file(fs_setup: tuple[Path, Path]):
    """Tests that a .stowignore file is correctly read and used."""
    source_dir, _ = fs_setup

    # Create a .stowignore file
    stowignore_content = "# Ignore me\nREADME.md\n\nbuild/"
    (source_dir / ".stowignore").write_text(stowignore_content)

    # Create files to check
    (source_dir / "README.md").touch()
    (source_dir / "dot-vimrc").touch()
    (source_dir / "build").mkdir()

    # Clear the cache to ensure the file is re-read for this test
    get_ignore_patterns.cache_clear()

    assert should_ignore_file(source_dir / "README.md", source_dir) is True
    assert should_ignore_file(source_dir / "build", source_dir) is True
    assert (
        should_ignore_file(source_dir / ".stowignore", source_dir) is True
    )  # Should always ignore itself
    assert should_ignore_file(source_dir / "dot-vimrc", source_dir) is False


def test_ignore_logic_with_default_ignores(fs_setup: tuple[Path, Path]):
    """Tests that default ignore patterns are used when .stowignore is absent."""
    source_dir, _ = fs_setup

    # Create files that match default ignores
    (source_dir / ".git").mkdir()
    (source_dir / "dot-zshrc").touch()

    # Clear the cache
    get_ignore_patterns.cache_clear()

    assert should_ignore_file(source_dir / ".git", source_dir) is True
    assert should_ignore_file(source_dir / "dot-zshrc", source_dir) is False


# --- Integration Tests for Main Script Logic ---


def run_pystow(
    monkeypatch: MonkeyPatch, capsys: CaptureFixture[str], args: list[str]
) -> tuple[int | None | Any, str, str]:
    """Helper to run the main function with mocked sys.argv and capture output."""
    full_args = ["py"] + args
    monkeypatch.setattr(sys, "argv", full_args)

    exit_code = 0
    try:
        main()
    except SystemExit as e:
        exit_code = e.code

    captured = capsys.readouterr()
    return exit_code, captured.out, captured.err


def test_stow_simple_file(
    fs_setup: tuple[Path, Path], monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
):
    """Test basic linking of a single file."""
    source_dir, target_dir = fs_setup
    (source_dir / "profile").touch()

    exit_code, out, err = run_pystow(
        monkeypatch, capsys, [str(source_dir), str(target_dir)]
    )

    target_file = target_dir / "profile"
    assert exit_code == 0
    assert "Linking" in out
    assert "✨ Done." in out
    assert err == ""
    assert target_file.is_symlink()
    assert target_file.resolve() == (source_dir / "profile").resolve()


def test_stow_with_name_mangling(
    fs_setup: tuple[Path, Path], monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
):
    """Test linking a file that needs name mangling (dot-vimrc -> .vimrc)."""
    source_dir, target_dir = fs_setup
    (source_dir / "dot-vimrc").touch()

    exit_code, out, _ = run_pystow(
        monkeypatch, capsys, [str(source_dir), str(target_dir)]
    )

    target_file = target_dir / ".vimrc"
    assert exit_code == 0
    assert "Processing [ dot-vimrc ] -> [ " in out
    assert target_file.is_symlink()
    assert target_file.resolve() == (source_dir / "dot-vimrc").resolve()


def test_stow_directory(
    fs_setup: tuple[Path, Path], monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
):
    """Test linking a whole directory."""
    source_dir, target_dir = fs_setup
    (source_dir / "dot-config").mkdir()
    (source_dir / "dot-config" / "nvim").mkdir()

    exit_code, out, _ = run_pystow(
        monkeypatch, capsys, [str(source_dir), str(target_dir)]
    )

    target_folder = target_dir / ".config"
    assert exit_code == 0
    assert "Processing [ dot-config ]" in out
    assert target_folder.is_symlink()
    assert (target_folder / "nvim").exists()  # Check content of symlinked dir
    assert target_folder.resolve() == (source_dir / "dot-config").resolve()


def test_stow_conflict_no_force_fails(
    fs_setup: tuple[Path, Path], monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
):
    """Test that the script fails if a target file exists and --force is not used."""
    source_dir, target_dir = fs_setup
    (source_dir / "dot-zshrc").touch()

    # Create a conflicting file in the target directory
    conflicting_file = target_dir / ".zshrc"
    conflicting_file.write_text("original content")

    exit_code, _, err = run_pystow(
        monkeypatch, capsys, [str(source_dir), str(target_dir)]
    )

    assert exit_code != 0
    assert "Error: Target '.zshrc' already exists." in err
    assert "Operation failed" in err
    assert not conflicting_file.is_symlink()  # Ensure original file is untouched
    assert conflicting_file.read_text() == "original content"


def test_stow_conflict_with_force_backs_up(
    fs_setup: tuple[Path, Path], monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
):
    """Test that --force correctly backs up an existing file before linking."""
    source_dir, target_dir = fs_setup
    (source_dir / "dot-zshrc").touch()

    # Create a conflicting file
    conflicting_file = target_dir / ".zshrc"
    conflicting_file.write_text("original content")

    exit_code, out, err = run_pystow(
        monkeypatch, capsys, ["--force", str(source_dir), str(target_dir)]
    )

    assert exit_code == 0
    assert err == ""
    assert "Conflict found" in out
    assert "Moving existing target" in out

    # Check that the new symlink is correct
    assert conflicting_file.is_symlink()
    assert conflicting_file.resolve() == (source_dir / "dot-zshrc").resolve()

    # Find the backup file (it has a timestamp, so we search for it)
    backups = list(target_dir.glob(".zshrc.bak.*"))
    assert len(backups) == 1
    assert backups[0].is_file()
    assert backups[0].read_text() == "original content"


def test_dry_run_makes_no_changes(
    fs_setup: tuple[Path, Path], monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
):
    """Test that --dry-run shows what would happen but doesn't change the filesystem."""
    source_dir, target_dir = fs_setup
    (source_dir / "dot-bashrc").touch()
    (target_dir / ".bashrc").write_text("existing file")  # Create a conflict

    args = ["--dry-run", "--force", str(source_dir), str(target_dir)]
    exit_code, out, err = run_pystow(monkeypatch, capsys, args)

    assert exit_code == 0
    assert err == ""
    assert "--- DRY RUN MODE ---" in out
    assert "Would move existing target" in out
    assert "Would link" in out

    # Assert that NO changes were made
    target_file = target_dir / ".bashrc"
    assert not target_file.is_symlink()
    assert target_file.read_text() == "existing file"
    assert len(list(target_dir.glob(".bashrc.bak.*"))) == 0


def test_idempotency_correct_link_exists(
    fs_setup: tuple[Path, Path], monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
):
    """Test that if the correct link already exists, the script does nothing."""
    source_dir, target_dir = fs_setup
    source_file = source_dir / "profile"
    source_file.touch()

    # Create the correct symlink beforehand
    target_file = target_dir / "profile"
    target_file.symlink_to(source_file)

    exit_code, out, _ = run_pystow(
        monkeypatch, capsys, [str(source_dir), str(target_dir)]
    )

    assert exit_code == 0
    assert "Correct link already exists. Skipping." in out
    assert "Linking" not in out  # Ensure it didn't try to re-link


def test_invalid_args_nonexistent_dir(
    tmp_path: Path, monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
):
    """Test that the script exits gracefully if a directory does not exist."""
    non_existent_dir = tmp_path / "nonexistent"

    # Test non-existent source
    exit_code, _, err = run_pystow(
        monkeypatch, capsys, [str(non_existent_dir), str(tmp_path)]
    )
    assert exit_code != 0
    assert "Source directory not found" in err

    # Test non-existent target
    (tmp_path / "source").mkdir()
    exit_code, _, err = run_pystow(
        monkeypatch, capsys, [str(tmp_path / "source"), str(non_existent_dir)]
    )
    assert exit_code != 0
    assert "Target directory not found" in err
