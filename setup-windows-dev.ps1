#Requires -RunAsAdministrator

function Install-Chocolatey {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is already installed." -ForegroundColor Yellow
        return
    }

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    # refreshenv is not available until after installation and shell restart, so we manually update the path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
}

function Install-Scoop {
    Write-Host "Installing Scoop..." -ForegroundColor Cyan
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop is already installed." -ForegroundColor Yellow
        return
    }

    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Write-Host "Scoop installed successfully!" -ForegroundColor Green
}

function Install-Ubuntu24 {
    Write-Host "Installing Ubuntu 24.04 LTS..." -ForegroundColor Cyan

    # Check if WSL is installed
    if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
        Write-Host "WSL is not installed. Installing WSL first..." -ForegroundColor Yellow
        wsl --install
        return $true  # Restart needed after WSL installation
    }

    # Check if Ubuntu 24.04 is already installed
    # Use Out-String to convert the output to a string for better pattern matching
    $installedDistros = wsl --list | Out-String
    if ($installedDistros -match "Ubuntu-24.04" -or $installedDistros -match "Ubuntu 24.04") {
        Write-Host "Ubuntu 24.04 is already installed." -ForegroundColor Yellow
        return $false
    }

    # Check available distributions
    $availableDistros = wsl --list --online | Out-String

    # Look for Ubuntu 24.04 with flexible matching
    if ($availableDistros -match "Ubuntu-24.04" -or $availableDistros -match "Ubuntu 24.04") {
        Write-Host "Installing Ubuntu 24.04..." -ForegroundColor Cyan
        wsl --install -d Ubuntu-24.04
        Write-Host "Ubuntu 24.04 installed successfully!" -ForegroundColor Green
        return $false
    } else {
        # Fallback to latest Ubuntu if 24.04 is not available
        Write-Host "Ubuntu 24.04 not found in available distributions. Installing latest Ubuntu instead..." -ForegroundColor Yellow
        wsl --install -d Ubuntu
        Write-Host "Latest Ubuntu installed successfully!" -ForegroundColor Green
        return $false
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

        Write-Host "Multipass installed successfully!" -ForegroundColor Green
    }

    # Verify installation
    if (Get-Command multipass -ErrorAction SilentlyContinue) {
        Write-Host "Multipass is ready to use. Try 'multipass launch' to create your first instance." -ForegroundColor Cyan
    } else {
        Write-Host "Multipass installation may have failed. Please try installing manually." -ForegroundColor Yellow
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
    $restartNeeded = Install-Ubuntu24
    Install-Starship
    Configure-PSReadLine
    Install-DevTools
    Install-Multipass

    # Only offer to setup Multipass if no restart is needed
    if (!$restartNeeded) {
        $setupVM = Read-Host "Would you like to set up an Ubuntu 24.10 VM with your shell configuration? (y/n)"
        if ($setupVM -eq 'y') {
            Setup-MultipassUbuntu
        }
    }

    Write-Host "Setup complete!" -ForegroundColor Green

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
