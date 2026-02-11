#!/usr/bin/env python3

from __future__ import annotations

import asyncio
from collections.abc import Iterable
from dataclasses import dataclass
import os
import shutil
import signal
import sys
from typing import Annotated, NoReturn, Protocol

import anyio
from pydantic import BaseModel, Field
import structlog
import typer

log: structlog.stdlib.BoundLogger = structlog.get_logger()

_shutdown_event: asyncio.Event | None = None


def get_grid_size(n: int) -> tuple[int, int]:
    """
    Calculate grid rows and columns such that rows * cols >= n
    and rows - cols <= 1 and rows >= cols.
    """
    if n <= 0:
        return 0, 0
    import math

    cols = int(math.sqrt(n))
    rows = cols
    if rows * cols < n:
        rows += 1
    if rows * cols < n:
        cols += 1
    return rows, cols


class TmuxError(Exception):
    pass


class ShutdownError(Exception):
    """Raised when a shutdown signal is received."""


def _setup_signal_handlers() -> asyncio.Event:
    """Set up signal handlers for graceful shutdown."""
    global _shutdown_event
    if _shutdown_event is None:
        _shutdown_event = asyncio.Event()

    loop = asyncio.get_running_loop()

    def handle_shutdown(sig: int) -> None:
        sig_name = signal.Signals(sig).name
        log.info("Received shutdown signal", signal=sig_name)
        if _shutdown_event is not None:
            _shutdown_event.set()

    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, lambda s=sig: handle_shutdown(s))

    return _shutdown_event


def _require_tmux() -> None:
    if not shutil.which("tmux"):
        raise TmuxError("tmux is not installed. Please install it first.")


async def _run_tmux(
    *args: str, check: bool = True
) -> tuple[bytes, bytes, int]:
    proc = await asyncio.create_subprocess_exec(
        "tmux",
        *args,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    stdout, stderr = await proc.communicate()
    if proc.returncode is None:
        raise TmuxError("tmux command failed: no return code")
    return stdout, stderr, proc.returncode


async def _has_session(name: str) -> bool:
    _, _, returncode = await _run_tmux("has-session", "-t", name, check=False)
    return returncode == 0


async def _get_tmux_option(option: str, default: int) -> int:
    stdout, _, _ = await _run_tmux("show-options", "-gqv", option, check=False)
    value = stdout.decode().strip()
    if not value:
        return default
    try:
        return int(value)
    except ValueError:
        return default


@dataclass(frozen=True)
class TmuxIndices:
    window: int
    pane: int

    @classmethod
    async def resolve(cls) -> TmuxIndices:
        return cls(
            window=await _get_tmux_option("base-index", 0),
            pane=await _get_tmux_option("pane-base-index", 0),
        )


async def session_ensure(name: str, *, force: bool = False) -> bool:
    if not name:
        raise TmuxError("Session name cannot be empty.")

    if not await _has_session(name):
        return True

    if force:
        log.info("Session exists, recreating", session=name)
        await _run_tmux("kill-session", "-t", name)
        return True

    log.info("Session already exists, attaching", session=name)
    _attach(name)


def _attach(name: str) -> NoReturn:
    if sys.stdout.isatty():
        os.execvp("tmux", ["tmux", "attach-session", "-t", name])
    else:
        log.info("Use tmux attach to connect", session=name)
        sys.exit(0)


async def attach_session(name: str) -> None:
    if not name:
        raise TmuxError("Session name cannot be empty.")
    if not await _has_session(name):
        raise TmuxError(f"Session '{name}' does not exist.")
    log.info("Attaching to session", session=name)
    _attach(name)


async def detach_session() -> None:
    if not os.environ.get("TMUX"):
        raise TmuxError("Not currently in a tmux session.")
    log.info("Detaching from tmux session")
    await _run_tmux("detach-client")


async def destroy_session(name: str) -> None:
    if not name:
        raise TmuxError("Session name cannot be empty.")
    if not await _has_session(name):
        log.warning("Session does not exist", session=name)
        return
    log.info("Destroying session", session=name)
    await _run_tmux("kill-session", "-t", name)
    log.info("Session destroyed", session=name)


async def tmux_grid(session_name: str, commands: list[str]) -> None:
    _require_tmux()
    shutdown_event = _setup_signal_handlers()

    if not session_name:
        raise TmuxError("Session name cannot be empty.")
    if not commands:
        raise TmuxError("At least one command is required.")

    if await _has_session(session_name):
        log.info("Session already exists, attaching", session=session_name)
        _attach(session_name)

    num_cmds = len(commands)
    rows, cols = get_grid_size(num_cmds)

    log.info(
        "Creating new tmux session",
        session=session_name,
        panes=num_cmds,
        grid=f"{rows}x{cols}",
    )

    win_name = f"grid-{session_name}"
    try:
        await _run_tmux("new-session", "-d", "-s", session_name, "-n", win_name)

        idx = await TmuxIndices.resolve()
        window_target = f"{session_name}:{win_name}"
        for _ in range(1, num_cmds):
            if shutdown_event.is_set():
                log.info(
                    "Shutdown requested, cleaning up session", session=session_name
                )
                await _run_tmux("kill-session", "-t", session_name, check=False)
                raise ShutdownError("Interrupted during session creation")
            await _run_tmux("split-window", "-t", window_target)
            await _run_tmux("select-layout", "-t", window_target, "tiled")

        for i, cmd in enumerate(commands):
            if shutdown_event.is_set():
                log.info(
                    "Shutdown requested, cleaning up session", session=session_name
                )
                await _run_tmux("kill-session", "-t", session_name, check=False)
                raise ShutdownError("Interrupted during command execution")
            pane_target = f"{window_target}.{idx.pane + i}"
            await _run_tmux("send-keys", "-t", pane_target, cmd, "C-m")
            await asyncio.sleep(0.05)

        _attach(session_name)
    except (asyncio.CancelledError, KeyboardInterrupt):
        log.info("Operation cancelled, cleaning up session", session=session_name)
        await _run_tmux("kill-session", "-t", session_name, check=False)
        raise


async def tmux_grid_from_file(session_name: str, file_path: str) -> None:
    path = anyio.Path(file_path)
    if not await path.exists():
        raise TmuxError(f"File '{file_path}' does not exist.")
    if not (await path.is_file()):
        raise TmuxError(f"Path '{file_path}' is not a file.")

    try:
        content = await path.read_text(encoding="utf-8")
    except OSError as e:
        raise TmuxError(f"Failed to read file '{file_path}': {e}") from e

    commands = [
        stripped
        for line in content.splitlines()
        if (stripped := line.strip()) and not stripped.startswith("#")
    ]

    if not commands:
        raise TmuxError(f"No valid commands found in '{file_path}'.")

    await tmux_grid(session_name, commands)


class WindowSpec(BaseModel):
    name: str = Field(..., min_length=1)
    command: str


async def tmux_windows(session_name: str, windows: list[WindowSpec]) -> None:
    _require_tmux()
    shutdown_event = _setup_signal_handlers()

    if not session_name:
        raise TmuxError("Session name cannot be empty.")
    if not windows:
        raise TmuxError("At least one window specification is required.")

    if await _has_session(session_name):
        log.info("Session already exists", session=session_name)
        _attach(session_name)

    idx = await TmuxIndices.resolve()
    log.info("Creating new tmux session", session=session_name, windows=len(windows))

    try:
        await _run_tmux("new-session", "-d", "-s", session_name, "-n", windows[0].name)
        await _run_tmux(
            "send-keys", "-t", f"{session_name}:{idx.window}", windows[0].command, "C-m"
        )

        for i, win in enumerate(windows[1:], start=1):
            if shutdown_event.is_set():
                log.info(
                    "Shutdown requested, cleaning up session", session=session_name
                )
                await _run_tmux("kill-session", "-t", session_name, check=False)
                raise ShutdownError("Interrupted during window creation")
            win_idx = idx.window + i
            await _run_tmux(
                "new-window", "-t", f"{session_name}:{win_idx}", "-n", win.name
            )
            await _run_tmux(
                "send-keys", "-t", f"{session_name}:{win_idx}", win.command, "C-m"
            )

        _attach(session_name)
    except (asyncio.CancelledError, KeyboardInterrupt):
        log.info("Operation cancelled, cleaning up session", session=session_name)
        await _run_tmux("kill-session", "-t", session_name, check=False)
        raise


async def tmux_windows_from_file(session_name: str, file_path: str) -> None:
    path = anyio.Path(file_path)
    if not await path.exists():
        raise TmuxError(f"File '{file_path}' does not exist.")
    if not (await path.is_file()):
        raise TmuxError(f"Path '{file_path}' is not a file.")

    try:
        content = await path.read_text(encoding="utf-8")
    except OSError as e:
        raise TmuxError(f"Failed to read file '{file_path}': {e}") from e

    specs = [
        WindowSpec(name=parts[0], command=parts[1])
        for line in content.splitlines()
        if (stripped := line.strip()) and not stripped.startswith("#")
        if (parts := stripped.split(maxsplit=1)) and len(parts) == 2
    ]

    if not specs:
        raise TmuxError(f"No valid name-command pairs found in '{file_path}'.")

    await tmux_windows(session_name, specs)


class CommandFactory(Protocol):
    def __call__(self, vm_name: str) -> str: ...


def generate_names(prefix: str, distros: Iterable[str]) -> list[str]:
    return [f"{distro}-{prefix}" for distro in distros]


def create_commands(
    vt: str,
    prefix: str,
    distros: Iterable[str],
    command_factory: dict[str, CommandFactory],
) -> list[str]:
    factory = command_factory.get(vt)
    if factory is None:
        raise TmuxError(f"No command factory registered for vt '{vt}'.")
    names = generate_names(prefix, distros)
    return [factory(n) for n in names]


app = typer.Typer(
    name="tmux-grid",
    help="Create tmux sessions with tiled pane grids or named windows.",
    add_completion=False,
)

_SessionName = Annotated[str, typer.Argument(help="Tmux session name.")]


@app.command()
def grid(
    session_name: _SessionName,
    commands: Annotated[
        list[str], typer.Argument(help="Commands to run in each pane.")
    ],
) -> None:
    try:
        asyncio.run(tmux_grid(session_name, commands))
    except (ShutdownError, KeyboardInterrupt):
        log.info("Gracefully shutting down")
        raise typer.Exit(code=130) from None


@app.command("grid-file")
def grid_file(
    session_name: _SessionName,
    file: Annotated[
        str, typer.Argument(help="Path to file containing commands (one per line).")
    ],
) -> None:
    try:
        asyncio.run(tmux_grid_from_file(session_name, file))
    except (ShutdownError, KeyboardInterrupt):
        log.info("Gracefully shutting down")
        raise typer.Exit(code=130) from None


@app.command()
def windows(
    session_name: _SessionName,
    pairs: Annotated[
        list[str],
        typer.Argument(
            help="Alternating name command pairs: name1 cmd1 name2 cmd2 ..."
        ),
    ],
) -> None:
    if len(pairs) % 2 != 0:
        log.error("Window pairs must be even: name1 cmd1 name2 cmd2 ...")
        raise typer.Exit(code=1)
    specs = [
        WindowSpec(name=pairs[i], command=pairs[i + 1]) for i in range(0, len(pairs), 2)
    ]
    try:
        asyncio.run(tmux_windows(session_name, specs))
    except (ShutdownError, KeyboardInterrupt):
        log.info("Gracefully shutting down")
        raise typer.Exit(code=130) from None


@app.command("windows-file")
def windows_file(
    session_name: _SessionName,
    file: Annotated[
        str, typer.Argument(help="Path to file with 'name command' lines.")
    ],
) -> None:
    try:
        asyncio.run(tmux_windows_from_file(session_name, file))
    except (ShutdownError, KeyboardInterrupt):
        log.info("Gracefully shutting down")
        raise typer.Exit(code=130) from None


@app.command()
def attach(session_name: _SessionName) -> None:
    asyncio.run(attach_session(session_name))


@app.command()
def detach() -> None:
    asyncio.run(detach_session())


@app.command()
def destroy(session_name: _SessionName) -> None:
    asyncio.run(destroy_session(session_name))


if __name__ == "__main__":
    app()
