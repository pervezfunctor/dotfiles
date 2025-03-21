#Requires -RunAsAdministrator

function Install-Chocolatey {

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    # refreshenv is not available until after installation and shell restart, so we manually update the path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
}

function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Scoop..." -ForegroundColor Cyan

    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

    Write-Host "Scoop installed successfully!" -ForegroundColor Green
}

function Install-WSL {
    if (Get-Command wsl -ErrorAction SilentlyContinue)) {
        return $false
    }

    Write-Host "WSL is not installed. Installing WSL first..." -ForegroundColor Yellow
    wsl --install
    return $true  # Restart needed after WSL installation
}

function Install-Ubuntu24 {
    if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
        Write-Host "WSL is not installed. Please install WSL first." -ForegroundColor Red
        return
    }

    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains "Ubuntu-24.04" -or $installedDistros -contains "Ubuntu 24.04") {
        Write-Host "Ubuntu 24.04 is already installed." -ForegroundColor Yellow
        return
    }

    $availableDistros = wsl --list --online --quiet

    if ($availableDistros -contains "Ubuntu-24.04" -or $availableDistros -contains "Ubuntu 24.04") {
        Write-Host "Installing Ubuntu 24.04..." -ForegroundColor Cyan
        wsl --install -d Ubuntu-24.04
        Write-Host "Ubuntu 24.04 installed successfully!" -ForegroundColor Green
        return
    } else {
        Write-Host "Ubuntu 24.04 not found in available distributions. Skipping..." -ForegroundColor Yellow
        return
    }
}

function Install-Starship {
    Write-Host "Setting up Starship prompt..." -ForegroundColor Cyan

    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Write-Host "Starship is already installed." -ForegroundColor Yellow
        return
    }
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Starship.Starship
    } else {
        Invoke-RestMethod -Uri https://starship.rs/install.ps1 | Invoke-Expression
    }

    $profileContent = @"
# Initialize Starship prompt
Invoke-Expression (&starship init powershell)
"@

    if (!(Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -Type File -Force
    }

    # Check if Starship initialization is already in the profile
    $currentProfile = Get-Content -Path $PROFILE -ErrorAction SilentlyContinue
    if ($currentProfile -notmatch "starship init") {
        Add-Content -Path $PROFILE -Value $profileContent
        Write-Host "Added Starship initialization to PowerShell profile." -ForegroundColor Green
    } else {
        Write-Host "Starship initialization already exists in PowerShell profile." -ForegroundColor Yellow
    }

    Write-Host "Starship prompt installed and configured!" -ForegroundColor Green
}

function Configure-PSReadLine {
    Write-Host "Setting up PSReadLine for autosuggestions and syntax highlighting..." -ForegroundColor Cyan

    # Install or update PSReadLine module
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Write-Host "Updating PSReadLine module..." -ForegroundColor Cyan
        Install-Module -Name PSReadLine -Force -SkipPublisherCheck
    } else {
        Write-Host "Installing PSReadLine module..." -ForegroundColor Cyan
        Install-Module -Name PSReadLine -Force -SkipPublisherCheck
    }

    # Configure PSReadLine settings in profile
    $psReadLineConfig = @"

# PSReadLine configuration for autosuggestions and syntax highlighting
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -Colors @{
    Command            = 'Cyan'
    Parameter          = 'DarkCyan'
    Operator           = 'DarkGreen'
    Variable           = 'DarkGreen'
    String             = 'DarkYellow'
    Number             = 'DarkGreen'
    Member             = 'DarkGreen'
    Type               = 'DarkYellow'
    Comment            = 'DarkGray'
    InlinePrediction   = 'DarkGray'
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
"@

    if (!(Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -Type File -Force
    }

    # Check if PSReadLine configuration already exists in the profile
    $currentProfile = Get-Content -Path $PROFILE -ErrorAction SilentlyContinue
    if ($currentProfile -notmatch "PSReadLine configuration") {
        Add-Content -Path $PROFILE -Value $psReadLineConfig
        Write-Host "Added PSReadLine configuration to PowerShell profile." -ForegroundColor Green
    } else {
        Write-Host "PSReadLine configuration already exists in PowerShell profile." -ForegroundColor Yellow
    }

    Write-Host "PSReadLine configured for autosuggestions and syntax highlighting!" -ForegroundColor Green
}


# Function to create symbolic links (similar to GNU stow)
function Create-ConfigLink {
    param (
        [string]$sourcePath,
        [string]$targetPath
    )

    if (!(Test-Path $sourcePath)) {
        Write-Host "Source path $sourcePath does not exist. Skipping." -ForegroundColor Yellow
        return
    }

    # Create target directory if it doesn't exist
    $targetDir = Split-Path -Parent $targetPath
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Remove existing target if it exists
    if (Test-Path $targetPath) {
        $backupPath = "$targetPath.bak"
        if (Test-Path $backupPath) {
            Remove-Item $backupPath -Recurse -Force
        }
        Write-Host "Backing up existing $targetPath to $backupPath" -ForegroundColor Yellow
        Move-Item $targetPath $backupPath -Force
    }

    # Create symbolic link
    try {
        New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
        Write-Host "Created symbolic link: $targetPath -> $sourcePath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create symbolic link. Falling back to copy." -ForegroundColor Red
        Write-Host "Note: Run PowerShell as Administrator to create symbolic links." -ForegroundColor Yellow
        Copy-Item $sourcePath $targetPath -Recurse -Force
        Write-Host "Copied $sourcePath to $targetPath" -ForegroundColor Yellow
    }
}

function Install-DevTools {
    Write-Host "Installing development tools..." -ForegroundColor Cyan

    # Check if winget is available
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Winget not found. Please install winget first to continue with dev tools installation." -ForegroundColor Yellow
        return
    }

    # Install Visual Studio Code
    Write-Host "Installing Visual Studio Code..." -ForegroundColor Cyan
    if (!(Get-Command code -ErrorAction SilentlyContinue)) {
        winget install Microsoft.VisualStudioCode
        Write-Host "Visual Studio Code installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Visual Studio Code is already installed." -ForegroundColor Yellow
    }

    # Install Firefox
    Write-Host "Installing Firefox..." -ForegroundColor Cyan
    if (!(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe") -and
        !(Test-Path "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe")) {
        winget install Mozilla.Firefox
        Write-Host "Firefox installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Firefox is already installed." -ForegroundColor Yellow
    }

    # Install Git
    Write-Host "Installing Git..." -ForegroundColor Cyan
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        winget install Git.Git
        Write-Host "Git installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Git is already installed." -ForegroundColor Yellow
    }

    # Install WezTerm
    Write-Host "Installing WezTerm..." -ForegroundColor Cyan
    if (!(Get-Command wezterm -ErrorAction SilentlyContinue)) {
        winget install wez.wezterm
        Write-Host "WezTerm installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "WezTerm is already installed." -ForegroundColor Yellow
    }

    # Install Docker Desktop
    if (!(Test-Path "C:\Program Files\Docker\Docker\Docker Desktop.exe")) {
        Write-Host "Installing Docker Desktop..." -ForegroundColor Cyan
        winget install Docker.DockerDesktop
        Write-Host "Docker Desktop installed successfully!" -ForegroundColor Green
        Write-Host "Make sure to enable the required WSL distro in Docker Desktop settings." -ForegroundColor Yellow
    } else {
        Write-Host "Docker Desktop is already installed." -ForegroundColor Yellow
    }

    # Install glazewm
    if (!(Get-Command glaze -ErrorAction SilentlyContinue)) {
        Write-Host "Installing glazewm..." -ForegroundColor Cyan
        winget install glazewm.glazewm
        Write-Host "glazewm installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "glazewm is already installed." -ForegroundColor Yellow
    }

    # Install telegram
    if (!(Get-Command telegram -ErrorAction SilentlyContinue)) {
        Write-Host "Installing telegram..." -ForegroundColor Cyan
        winget install Telegram.TelegramDesktop
        Write-Host "telegram installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "telegram is already installed." -ForegroundColor Yellow
    }

    # Install zoom
    if (!(Get-Command zoom -ErrorAction SilentlyContinue)) {
        Write-Host "Installing zoom..." -ForegroundColor Cyan
        winget install Zoom.Zoom
        Write-Host "zoom installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "zoom is already installed." -ForegroundColor Yellow
    }

    # Install ripgrep
    if (!(Get-Command rg -ErrorAction SilentlyContinue)) {
        Write-Host "Installing ripgrep..." -ForegroundColor Cyan
        winget install BurntSushi.ripgrep
        Write-Host "ripgrep installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "ripgrep is already installed." -ForegroundColor Yellow
    }

    # Install fzf
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "Installing fzf..." -ForegroundColor Cyan
        winget install junegunn.fzf
        Write-Host "fzf installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "fzf is already installed." -ForegroundColor Yellow
    }

    # Install fd
    if (!(Get-Command fd -ErrorAction SilentlyContinue)) {
        Write-Host "Installing fd..." -ForegroundColor Cyan
        winget install sharkdp.fd
        Write-Host "fd installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "fd is already installed." -ForegroundColor Yellow
    }

    # Install bat
    if (!(Get-Command bat -ErrorAction SilentlyContinue)) {
        Write-Host "Installing bat..." -ForegroundColor Cyan
        winget install sharkdp.bat
        Write-Host "bat installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "bat is already installed." -ForegroundColor Yellow
    }

    # Install gh
    if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "Installing gh..." -ForegroundColor Cyan
        winget install GitHub.cli
        Write-Host "gh installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "gh is already installed." -ForegroundColor Yellow
    }


    # Install delta
    if (!(Get-Command delta -ErrorAction SilentlyContinue)) {
        Write-Host "Installing delta..." -ForegroundColor Cyan
        winget install dandavison.delta
        Write-Host "delta installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "delta is already installed." -ForegroundColor Yellow
    }

    # Install uv
    if (!(Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Host "Installing uv..." -ForegroundColor Cyan
        winget install astral-sh.uv
        Write-Host "uv installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "uv is already installed." -ForegroundColor Yellow
    }

    # Install lazygit
    if (!(Get-Command lazygit -ErrorAction SilentlyContinue)) {
        Write-Host "Installing lazygit..." -ForegroundColor Cyan
        winget install jesseduffield.lazygit
        Write-Host "lazygit installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "lazygit is already installed." -ForegroundColor Yellow
    }

    # Install lazydocker
    if (!(Get-Command lazydocker -ErrorAction SilentlyContinue)) {
        Write-Host "Installing lazydocker..." -ForegroundColor Cyan
        winget install jesseduffield.lazydocker
        Write-Host "lazydocker installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "lazydocker is already installed." -ForegroundColor Yellow
    }

    # Install neovim
    if (!(Get-Command nvim -ErrorAction SilentlyContinue)) {
        Write-Host "Installing neovim..." -ForegroundColor Cyan
        winget install Neovim.Neovim
        Write-Host "neovim installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "neovim is already installed." -ForegroundColor Yellow
    }

    # Install emacs
    if (!(Get-Command emacs -ErrorAction SilentlyContinue)) {
        Write-Host "Installing emacs..." -ForegroundColor Cyan
        winget install GNU.Emacs
        Write-Host "emacs installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "emacs is already installed." -ForegroundColor Yellow
    }

    Write-Host "Development tools installed!" -ForegroundColor Green
}

Setup-Dotfiles {
    # Clone dotfiles if not already present, else update
    if (Test-Path "$env:USERPROFILE\.ilm") {
        Write-Host "Dotfiles already present. Updating..." -ForegroundColor Cyan
        Set-Location "$env:USERPROFILE\.ilm"
        # pull only if git repo is clean
        if ((git status --porcelain) -eq $null) {
            git pull --rebase
        }
        Write-Host "Dotfiles updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "Cloning dotfiles..." -ForegroundColor Cyan
        git clone https://github.com/pervezfunctor/dotfiles.git "$env:USERPROFILE\.ilm"
        Write-Host "Dotfiles cloned successfully!" -ForegroundColor Green
    }

    # Setup WezTerm config
    Write-Host "Setting up WezTerm config..." -ForegroundColor Cyan
    Create-ConfigLink -sourcePath "$env:USERPROFILE\.ilm\wezterm\dot-config\wezterm.lua" -targetPath "$env:USERPROFILE\.config\wezterm"

    # Setup Neovim config
    Write-Host "Setting up Neovim config..." -ForegroundColor Cyan
    Create-ConfigLink -sourcePath "$env:USERPROFILE\.ilm\nvim\dot-config\nvim" -targetPath "$env:LOCALAPPDATA\nvim"

    # Setup Emacs config
    Write-Host "Setting up Emacs config..." -ForegroundColor Cyan
    Create-ConfigLink -sourcePath "$env:USERPROFILE\.ilm\emacs-slim\dot-emacs" -targetPath "$env:APPDATA\.emacs"

}

function Install-Multipass {
    Write-Host "Installing Multipass..." -ForegroundColor Cyan

    # Check if Multipass is already installed
    if (Get-Command multipass -ErrorAction SilentlyContinue) {
        Write-Host "Multipass is already installed." -ForegroundColor Yellow
        return
    }

    # Install Multipass using winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Installing Multipass via winget..." -ForegroundColor Cyan
        winget install Canonical.Multipass
        Write-Host "Multipass installed successfully!" -ForegroundColor Green
    } else {
        # Fallback to direct download if winget is not available
        Write-Host "Installing Multipass via direct download..." -ForegroundColor Cyan
        $multipassUrl = "https://github.com/canonical/multipass/releases/latest/download/multipass-windows-installer.exe"
        $installerPath = "$env:TEMP\multipass-installer.exe"

        Invoke-WebRequest -Uri $multipassUrl -OutFile $installerPath
        Start-Process -FilePath $installerPath -Wait

        Remove-Item $installerPath -Force

        Write-Host "Multipass installed successfully!" -ForegroundColor
    # Verify installation
    if (Get-Command multipass -ErrorAction SilentlyContinue) {
    Write-Host
        "Multipass is ready to use. Try 'multipass launch' to create your first instance." -ForegroundColor Cyan
    } else {
        Write-Host "Multipass installation may have failed. Please try iGreen
    }

    nstalling manually." -ForegroundColor Yellow
    }
}

function Setup-MultipassUbuntu {
    Write-Host "Setting up Ubuntu 24.10 VM in Multipass..." -ForegroundColor Cyan

    # Check if Multipass is installed
    if (!(Get-Command multipass -ErrorAction SilentlyContinue)) {
        Write-Host "Multipass is not installed. Please run Install-Multipass first." -ForegroundColor Red
        return
    }

    # Check if VM already exists
    $vmExists = multipass list | Select-String "ubuntu-dev"
    if ($vmExists) {
        Write-Host "Ubuntu VM 'ubuntu-dev' already exists." -ForegroundColor Yellow
        $recreate = Read-Host "Would you like to delete and recreate it? (y/n)"
        if ($recreate -eq 'y') {
            Write-Host "Deleting existing VM..." -ForegroundColor Cyan
            multipass stop ubuntu-dev
            multipass delete ubuntu-dev
            multipass purge
        } else {
            Write-Host "Using existing VM." -ForegroundColor Cyan
            return
        }
    }

    Write-Host "Creating Ubuntu 24.10 VM with 16GB RAM and 40GB disk..." -ForegroundColor Cyan
    multipass launch noble --name ubuntu-dev --memory 16G --disk 40G

    # Wait for VM to be ready
    Start-Sleep -Seconds 5

    # Clone your dotfiles repository
    Write-Host "Cloning dotfiles repository..." -ForegroundColor Cyan
    multipass exec ubuntu-dev -- bash -c "sudo apt update && sudo apt install -y git curl"
    multipass exec ubuntu-dev -- bash -c "git clone https://github.com/pervezfunctor/dotfiles.git ~/.ilm"

    # Run shell installer script
    Write-Host "Running shell installer script..." -ForegroundColor Cyan
    multipass exec ubuntu-dev -- bash -c "cd ~/.ilm && bash -c '$(curl -sSL https://dub.sh/aPKPT8V)' -- shell"

    # Show information about the VM
    Write-Host "Ubuntu 24.10 VM setup complete!" -ForegroundColor Green
    multipass info ubuntu-dev

    Write-Host "To access your VM, use: multipass shell ubuntu-dev" -ForegroundColor Cyan
    Write-Host "To stop your VM, use: multipass stop ubuntu-dev" -ForegroundColor Cyan
    Write-Host "To start your VM again, use: multipass start ubuntu-dev" -ForegroundColor Cyan
}

function Main {
    Write-Host "Starting Windows development environment setup..." -ForegroundColor Green

    Install-Chocolatey
    Install-Scoop


    Install-Starship
    Configure-PSReadLine

    Install-DevTools

    $restartNeeded = Install-WSL
    Install-Ubuntu24

    Install-Multipass

    Setup-MultipassUbuntu

    Install-DockerDesktop

    if ($restartNeeded) {
        Write-Host "A system restart is required to complete WSL setup." -ForegroundColor Yellow
        $restart = Read-Host "Would you like to restart now? (y/n)"
        if ($restart -eq 'y') {
            Restart-Computer
        }
    } else {
        Write-Host "To start Ubuntu in WSL, open a terminal and type: wsl" -ForegroundColor Cyan
    }
}

Main
