import asyncio
import subprocess


async def run_tmux(cmd: list[str]) -> str:
    proc = await asyncio.create_subprocess_exec(
        "tmux", *cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = await proc.communicate()
    print(f"Command: {' '.join(cmd)}")
    print(f"Return Code: {proc.returncode}")
    print(f"Stdout: {stdout.decode()!r}")
    print(f"Stderr: {stderr.decode()!r}")
    return stdout.decode().strip()

async def main():
    print("Checking global options...")
    base_idx = await run_tmux(["show-options", "-gqv", "base-index"])
    pane_base_idx = await run_tmux(["show-options", "-gqv", "pane-base-index"])
    print(f"Global base-index: {base_idx!r}")
    print(f"Global pane-base-index: {pane_base_idx!r}")

    session_name = "repro-session"
    print(f"\nCreating session {session_name}...")
    # Clean up if exists
    await run_tmux(["kill-session", "-t", session_name])
    
    await run_tmux(["new-session", "-d", "-s", session_name, "-n", "window1"])
    
    print("\nChecking session options...")
    sess_base_idx = await run_tmux(
        ["show-options", "-t", session_name, "-qv", "base-index"]
    )
    sess_pane_base_idx = await run_tmux(
        ["show-options", "-t", session_name, "-qv", "pane-base-index"]
    )
    print(f"Session base-index: {sess_base_idx!r}")
    print(f"Session pane-base-index: {sess_pane_base_idx!r}")

    print("\nListing panes...")
    panes = await run_tmux(["list-panes", "-t", session_name, "-F", "#{pane_index}"])
    print(f"Panes: {panes!r}")
    
    target = f"{session_name}:window1.{sess_pane_base_idx}"
    print(f"\nSending keys to target: {target}")
    await run_tmux(["send-keys", "-t", target, "echo hello", "C-m"])

    # Clean up
    await run_tmux(["kill-session", "-t", session_name])

if __name__ == "__main__":
    asyncio.run(main())
