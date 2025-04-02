# One-liner to download and run the Windows setup script
# Run this in PowerShell with admin privileges:
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/pervezfunctor/dotfiles/refs/heads/main/share/installers/windows/windows-setup-dev.ps1'))

