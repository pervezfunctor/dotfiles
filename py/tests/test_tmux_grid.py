import asyncio
from collections.abc import Generator
import os
import shutil
import subprocess
from unittest.mock import AsyncMock, MagicMock, call, patch

import pytest

from tmux_grid import (
    TmuxError,
    TmuxIndices,
    WindowSpec,
    attach_session,
    destroy_session,
    detach_session,
    get_grid_size,
    session_ensure,
    tmux_grid,
    tmux_grid_from_file,
    tmux_windows,
    tmux_windows_from_file,
)


@pytest.fixture
def mock_subprocess() -> Generator[AsyncMock]:
    with patch("asyncio.create_subprocess_exec", new_callable=AsyncMock) as mock:
        process = AsyncMock()
        process.returncode = 0
        process.communicate.return_value = (b"", b"")
        mock.return_value = process
        yield mock


@pytest.fixture
def mock_shutil_which() -> Generator[MagicMock]:
    with patch("shutil.which") as mock:
        mock.return_value = "/usr/bin/tmux"
        yield mock


@pytest.fixture
def mock_execvp() -> Generator[MagicMock]:
    with patch("os.execvp") as mock:
        yield mock


@pytest.fixture
def mock_path_exists() -> Generator[AsyncMock]:
    with patch("anyio.Path.exists", new_callable=AsyncMock) as mock:
        mock.return_value = True
        yield mock


@pytest.fixture
def mock_path_is_file() -> Generator[AsyncMock]:
    with patch("anyio.Path.is_file", new_callable=AsyncMock) as mock:
        mock.return_value = True
        yield mock


@pytest.fixture
def mock_path_read_text() -> Generator[AsyncMock]:
    with patch("anyio.Path.read_text", new_callable=AsyncMock) as mock:
        yield mock


@pytest.mark.asyncio
async def test_session_ensure_empty_name() -> None:
    with pytest.raises(TmuxError, match="Session name cannot be empty"):
        await session_ensure("")


@pytest.mark.asyncio
async def test_session_ensure_creates_new(
    mock_subprocess: AsyncMock, mock_execvp: MagicMock
) -> None:
    # _has_session returns False (returncode 1)
    mock_subprocess.return_value.returncode = 1

    # Needs to fail _has_session first
    with patch("tmux_grid._has_session", new_callable=AsyncMock) as mock_has:
        mock_has.return_value = False
        res = await session_ensure("newsession")
        assert res is True
        mock_execvp.assert_not_called()


@pytest.mark.asyncio
async def test_session_ensure_force_recreate(mock_subprocess: AsyncMock) -> None:
    with (
        patch("tmux_grid._has_session", new_callable=AsyncMock) as mock_has,
        patch("tmux_grid._run_tmux", new_callable=AsyncMock) as mock_run,
    ):
        mock_has.return_value = True

        await session_ensure("oldsession", force=True)

        mock_run.assert_called_with("kill-session", "-t", "oldsession")


@pytest.mark.asyncio
async def test_session_ensure_attach_existing(
    mock_subprocess: AsyncMock, mock_execvp: MagicMock
) -> None:
    with (
        patch("tmux_grid._has_session", new_callable=AsyncMock) as mock_has,
        patch("sys.stdout.isatty", return_value=True),
    ):
        mock_has.return_value = True

        await session_ensure("existingsession", force=False)
        mock_execvp.assert_called_with(
            "tmux", ["tmux", "attach-session", "-t", "existingsession"]
        )


@pytest.mark.asyncio
async def test_attach_session_success(
    mock_subprocess: AsyncMock, mock_execvp: MagicMock
) -> None:
    with (
        patch("tmux_grid._has_session", new_callable=AsyncMock) as mock_has,
        patch("sys.stdout.isatty", return_value=True),
    ):
        mock_has.return_value = True
        await attach_session("mysession")
        mock_execvp.assert_called()


@pytest.mark.asyncio
async def test_detach_session_success(mock_subprocess: AsyncMock) -> None:
    with patch.dict(os.environ, {"TMUX": "original"}):
        await detach_session()
        mock_subprocess.assert_called_with(
            "tmux",
            "detach-client",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )


@pytest.mark.asyncio
async def test_destroy_session_success(mock_subprocess: AsyncMock) -> None:
    with patch("tmux_grid._has_session", new_callable=AsyncMock) as mock_has:
        mock_has.return_value = True
        await destroy_session("killsession")
        mock_subprocess.assert_called_with(
            "tmux",
            "kill-session",
            "-t",
            "killsession",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )


@pytest.mark.asyncio
async def test_tmux_grid_flow(
    mock_subprocess: AsyncMock, mock_shutil_which: MagicMock, mock_execvp: MagicMock
) -> None:
    # Mock indices to be 0
    with (
        patch(
            "tmux_grid.TmuxIndices.resolve", new_callable=AsyncMock
        ) as mock_indices,
        patch("tmux_grid._has_session", new_callable=AsyncMock) as mock_has,
        patch("sys.stdout.isatty", return_value=True),
    ):
        mock_indices.return_value = TmuxIndices(0, 0)
        mock_has.return_value = False

        commands = ["cmd1", "cmd2"]
        await tmux_grid("gridsession", commands)

        # Verify call sequence
        # We can't easily check order with loose mocks,
        # but we can verify calls were made
        assert mock_subprocess.call_count >= 1

        # Check specific calls
        calls = mock_subprocess.call_args_list
        # Should create session
        assert (
            call(
                "tmux",
                "new-session",
                "-d",
                "-s",
                "gridsession",
                "-n",
                "grid-gridsession",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )

        # Should split window (since there are 2 commands)
        target = "gridsession:grid-gridsession"
        assert (
            call(
                "tmux",
                "split-window",
                "-t",
                target,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )

        # Should select tiled layout
        assert (
            call(
                "tmux",
                "select-layout",
                "-t",
                target,
                "tiled",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )

        # Should send commands
        # pane 0
        assert (
            call(
                "tmux",
                "send-keys",
                "-t",
                "gridsession:grid-gridsession.0",
                "cmd1",
                "C-m",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )
        # pane 1
        assert (
            call(
                "tmux",
                "send-keys",
                "-t",
                "gridsession:grid-gridsession.1",
                "cmd2",
                "C-m",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )

        # Should attach at the end
        mock_execvp.assert_called()


@pytest.mark.asyncio
async def test_tmux_grid_from_file_success(
    mock_path_exists: AsyncMock,
    mock_path_is_file: AsyncMock,
    mock_path_read_text: AsyncMock,
) -> None:
    mock_path_read_text.return_value = "cmd1\n#comment\ncmd2"
    with patch("tmux_grid.tmux_grid", new_callable=AsyncMock) as mock_grid:
        await tmux_grid_from_file("filesession", "cmds.txt")
        mock_grid.assert_called_with("filesession", ["cmd1", "cmd2"])


@pytest.mark.asyncio
async def test_tmux_windows_flow(
    mock_subprocess: AsyncMock, mock_shutil_which: MagicMock, mock_execvp: MagicMock
) -> None:
    with (
        patch(
            "tmux_grid.TmuxIndices.resolve", new_callable=AsyncMock
        ) as mock_indices,
        patch("tmux_grid._has_session", new_callable=AsyncMock) as mock_has,
        patch("sys.stdout.isatty", return_value=True),
    ):
        mock_indices.return_value = TmuxIndices(0, 0)
        mock_has.return_value = False

        windows = [
            WindowSpec(name="win1", command="cmd1"),
            WindowSpec(name="win2", command="cmd2"),
        ]
        await tmux_windows("winsession", windows)

        calls = mock_subprocess.call_args_list

        # 1. new-session (creates first window)
        assert (
            call(
                "tmux",
                "new-session",
                "-d",
                "-s",
                "winsession",
                "-n",
                "win1",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )

        # 2. send keys to first window
        assert (
            call(
                "tmux",
                "send-keys",
                "-t",
                "winsession:0",
                "cmd1",
                "C-m",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )

        # 3. new-window (second window)
        assert (
            call(
                "tmux",
                "new-window",
                "-t",
                "winsession:1",
                "-n",
                "win2",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )

        # 4. send keys to second window
        assert (
            call(
                "tmux",
                "send-keys",
                "-t",
                "winsession:1",
                "cmd2",
                "C-m",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            in calls
        )


@pytest.mark.asyncio
async def test_tmux_windows_from_file_success(
    mock_path_exists: AsyncMock,
    mock_path_is_file: AsyncMock,
    mock_path_read_text: AsyncMock,
) -> None:
    mock_path_read_text.return_value = "win1 cmd1\nwin2 cmd2 args"
    with patch("tmux_grid.tmux_windows", new_callable=AsyncMock) as mock_wins:
        await tmux_windows_from_file("filesession", "wins.txt")

        expected_specs = [
            WindowSpec(name="win1", command="cmd1"),
            WindowSpec(name="win2", command="cmd2 args"),
        ]
        mock_wins.assert_called_with("filesession", expected_specs)


@pytest.mark.asyncio
async def test_shutdown_handling(mock_subprocess: AsyncMock) -> None:
    # Simulate a shutdown signal being set during execution
    # This is hard to test deterministically without modifying the code
    # to check event more often, but we can try to mock the event check or
    # rely on asyncio.sleep
    pass
    # Placeholder, signal handling is tricky to test in unit tests
    # without complex structure


@pytest.mark.parametrize("n", range(1, 16))
def test_grid_balance(n: int) -> None:
    rows, cols = get_grid_size(n)
    assert rows * cols >= n
    assert 0 <= (rows - cols) <= 1


@pytest.mark.asyncio
@pytest.mark.parametrize("num_panes", range(1, 21))
async def test_tmux_grid_integration(num_panes: int) -> None:
    if not shutil.which("tmux"):
        pytest.skip("tmux not installed")

    session_name = f"pytest-integrated-grid-{num_panes}"
    # Cleanup any leftovers
    await asyncio.create_subprocess_exec(
        "tmux", "kill-session", "-t", session_name, stderr=asyncio.subprocess.DEVNULL
    )

    try:
        # Mock _attach to prevent os.execvp from taking over the test process
        with patch("tmux_grid._attach"):
            await tmux_grid(session_name, [f"echo {i}" for i in range(num_panes)])

        # Check the layout using tmux list-panes
        # -F prints pane coordinates
        proc = await asyncio.create_subprocess_exec(
            "tmux",
            "list-panes",
            "-t",
            session_name,
            "-F",
            "#{pane_left} #{pane_top}",
            stdout=asyncio.subprocess.PIPE,
        )
        stdout, stderr = await proc.communicate()
        print(f"DEBUG: list-panes stdout: {stdout.decode()!r}")
        if stderr:
            print(f"DEBUG: list-panes stderr: {stderr.decode()!r}")
        assert proc.returncode == 0

        lines = stdout.decode().strip().splitlines()
        assert len(lines) == num_panes

        lefts: set[int] = set()
        tops: set[int] = set()
        for line in lines:
            left, top = map(int, line.split())
            lefts.add(left)
            tops.add(top)

        expected_rows, expected_cols = get_grid_size(num_panes)
        # Unique left coordinates are columns
        # Unique top coordinates are rows
        assert len(lefts) == expected_cols
        assert len(tops) == expected_rows

    finally:
        await asyncio.create_subprocess_exec(
            "tmux",
            "kill-session",
            "-t",
            session_name,
            stderr=asyncio.subprocess.DEVNULL,
        )
