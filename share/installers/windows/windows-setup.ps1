#Requires -RunAsAdministrator

function Test-CommandExists {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

function Install-DevTools {
    Write-Host "Installing development tools..." -ForegroundColor Cyan

    if (-not (Test-CommandExists code)) {
        winget install --id Microsoft.VisualStudioCode -e
    }

    if (-not (Test-CommandExists git)) {
        winget install --id Git.Git -e
    }

    winget install --id wez.wezterm -e
    winget install --id GitHub.cli -e
    # winget install --id astral-sh.uv -e
    # winget install --id JesseDuffield.lazygit -e
    # winget install --id JesseDuffield.lazydocker -e
    # winget install --id dandavison.delta -e
    # winget install --id BurntSushi.ripgrep.MSVC -e
    # winget install --id junegunn.fzf -e
    # winget install --id sharkdp.fd -e
    # winget install --id sharkdp.bat -e

    Write-Host "Development tools installed successfully!" -ForegroundColor Green
}

function Set-CentOSStream10 {
    Write-Host "Setting up CentOS Stream 10..." -ForegroundColor Cyan

    # Prompt for username and password
    $username = Read-Host "Enter username for CentOS"
    $password = Read-Host "Enter password for $username" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    # Download and run the setup script directly in CentOS
    Write-Host "Running setup script in CentOS Stream 10..." -ForegroundColor Cyan

    wsl -d CentOS-Stream-10 -u root -- bash -c "curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/windows/setup-centos.sh | bash -s -- '$username' '$passwordText'"

    # Clean up the password from memory
    $passwordText = $null
    [System.GC]::Collect()

    # Get IP address to display in PowerShell - ensure it's properly trimmed
    $vmIP = wsl -d CentOS-Stream-10 -u root -- hostname -I
    $vmIP = $vmIP.Trim()

    # Verify we have a valid IP address
    if ([string]::IsNullOrWhiteSpace($vmIP) -or $vmIP -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}') {
        Write-Host "Warning: Could not determine a valid IP address for CentOS WSL. Using localhost instead." -ForegroundColor Yellow
        $vmIP = "127.0.0.1"
    }

    Write-Host "CentOS WSL IP address: $vmIP" -ForegroundColor Cyan

    # Setup SSH keys
    Write-Host "Setting up SSH key authentication..." -ForegroundColor Cyan

    # Generate SSH key if it doesn't exist
    if (-not (Test-Path "$env:USERPROFILE\.ssh\id_rsa")) {
        Write-Host "Generating SSH key..." -ForegroundColor Cyan
        ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'
    }

    # Copy SSH key to VM
    $pubKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
    wsl -d CentOS-Stream-10 -u root -- bash -c "mkdir -p /home/$username/.ssh && chmod 700 /home/$username/.ssh"
    wsl -d CentOS-Stream-10 -u root -- bash -c "echo '$pubKey' >> /home/$username/.ssh/authorized_keys"
    wsl -d CentOS-Stream-10 -u root -- bash -c "chmod 600 /home/$username/.ssh/authorized_keys"
    wsl -d CentOS-Stream-10 -u root -- bash -c "chown -R ${username}:${username} /home/$username/.ssh"

    # Add VM to SSH config
    $sshConfig = @"
Host centos-wsl
    HostName $vmIP
    User $username
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
"@

    if (-not (Test-Path "$env:USERPROFILE\.ssh\config")) {
        New-Item -Path "$env:USERPROFILE\.ssh\config" -ItemType File -Force | Out-Null
    }

    if (-not (Select-String -Path "$env:USERPROFILE\.ssh\config" -Pattern "Host centos-wsl" -Quiet)) {
        Add-Content -Path "$env:USERPROFILE\.ssh\config" -Value $sshConfig
    }

    Write-Host "CentOS Stream 10 setup complete!" -ForegroundColor Green
    Write-Host "To access your CentOS environment, use: wsl -d CentOS-Stream-10" -ForegroundColor Cyan
    Write-Host "You can also connect via SSH: ssh centos-wsl" -ForegroundColor Cyan
}

function Install-CentOSStream10 {
    if (!(Test-CommandExists wsl)) {
        Write-Host "WSL command does not exist. Older Windows version?. Quitting." -ForegroundColor Red
        return
    }

    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains "CentOS-Stream-10") {
        Write-Host "CentOS Stream 10 is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing CentOS Stream 10 on WSL..." -ForegroundColor Cyan

    $wslDir = "$env:LOCALAPPDATA\WSL\CentOS-Stream-10"
    New-Item -Path $wslDir -ItemType Directory -Force | Out-Null

    $tempDir = "$env:TEMP"
    $archivePath = "$tempDir\CentOS-Stream-Image-WSL-Base.x86_64-10-202501111101.tar.xz"

    $downloadUrl = "https://mirror.stream.centos.org/SIGs/10-stream/altimages/images/wsl/x86_64/CentOS-Stream-Image-WSL-Base.x86_64-10-202501111101.tar.xz"

    Write-Host "Downloading CentOS Stream 10 WSL image (this may take time)..." -ForegroundColor Cyan

    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing
        Write-Host "Download completed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        Write-Host "You can try downloading the file manually from:" -ForegroundColor Yellow
        Write-Host $downloadUrl -ForegroundColor Yellow
        Write-Host "Then place it at: $archivePath" -ForegroundColor Yellow
        return
    }
    $ProgressPreference = 'Continue'

    Write-Host "Importing CentOS Stream 10 to WSL..." -ForegroundColor Cyan
    wsl --import --version=2 CentOS-Stream-10 $wslDir $archivePath

    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item -Path $archivePath -Force

    Write-Host "CentOS Stream 10 installed successfully!" -ForegroundColor Green
    Write-Host "To start CentOS Stream 10, open a terminal and type: wsl -d CentOS-Stream-10" -ForegroundColor Cyan
}

function Main {
    Write-Host "Starting Windows development environment setup..." -ForegroundColor Green

    Install-DevTools

    Install-CentOSStream10
    Set-CentOSStream10

    Write-Host "Windows development environment setup complete!" -ForegroundColor Green
}

Main
