#Requires -RunAsAdministrator

function Install-Chocolatey {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        refreshenv
        Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Chocolatey is already installed." -ForegroundColor Yellow
    }
}

function Install-Scoop {
    Write-Host "Installing Scoop..." -ForegroundColor Cyan
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Write-Host "Scoop installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Scoop is already installed." -ForegroundColor Yellow
    }
}

function Enable-WSL {
    Write-Host "Enabling WSL..." -ForegroundColor Cyan
    if (!(Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled') {
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        Write-Host "WSL features enabled. A system restart may be required." -ForegroundColor Yellow
        return $true
    } else {
        Write-Host "WSL is already enabled." -ForegroundColor Yellow
        return $false
    }
}

function Install-WSL2Kernel {
    Write-Host "Installing WSL2 kernel update..." -ForegroundColor Cyan
    $wslUpdateInstallerUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $wslUpdateInstallerPath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $wslUpdateInstallerUrl -OutFile $wslUpdateInstallerPath
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $wslUpdateInstallerPath, "/quiet" -Wait
    Remove-Item -Path $wslUpdateInstallerPath

    # Set WSL2 as default
    Write-Host "Setting WSL2 as default..." -ForegroundColor Cyan
    wsl --set-default-version 2
}

function Install-Ubuntu24 {
    Write-Host "Installing Ubuntu 24.04..." -ForegroundColor Cyan
    if (!(wsl -l | Select-String -Pattern "Ubuntu-24.04")) {
        # Check if Ubuntu 24.04 is available in the store
        $ubuntuAvailable = wsl --list --online | Select-String -Pattern "Ubuntu-24.04"

        if ($ubuntuAvailable) {
            wsl --install -d Ubuntu-24.04
        } else {
            # Fallback to manual download if not available in store
            Write-Host "Ubuntu 24.04 not found in WSL store. Downloading manually..." -ForegroundColor Yellow

            $ubuntuUrl = "https://cloud-images.ubuntu.com/wsl/noble/current/ubuntu-noble-wsl-amd64-wsl.rootfs.tar.gz"
            $ubuntuPath = "$env:TEMP\ubuntu-24.04.tar.gz"

            Invoke-WebRequest -Uri $ubuntuUrl -OutFile $ubuntuPath

            # Create directory for Ubuntu 24.04
            $ubuntuDir = "$env:LOCALAPPDATA\Ubuntu-24.04"
            if (!(Test-Path $ubuntuDir)) {
                New-Item -Path $ubuntuDir -ItemType Directory
            }

            # Import the distro
            wsl --import Ubuntu-24.04 $ubuntuDir $ubuntuPath

            # Clean up
            Remove-Item -Path $ubuntuPath
        }

        Write-Host "Ubuntu 24.04 installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Ubuntu 24.04 is already installed." -ForegroundColor Yellow
    }
}

function Install-WindowsSudo {
    Write-Host "Setting up Windows sudo..." -ForegroundColor Cyan

    # Check Windows version - sudo is only available on Windows 11 23H2 or newer
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $windowsVersion = [System.Version]($osInfo.Version)
    $isWindows11 = $windowsVersion.Major -ge 10 -and $osInfo.BuildNumber -ge 22000
    $isRecentEnough = $isWindows11 -and $osInfo.BuildNumber -ge 22621

    if ($isRecentEnough) {
        # Check if sudo is already available
        $sudoAvailable = Get-Command sudo -ErrorAction SilentlyContinue

        if ($sudoAvailable) {
            Write-Host "Windows sudo is already available." -ForegroundColor Yellow
        } else {
            # Install sudo via winget
            Write-Host "Installing sudo via winget..." -ForegroundColor Cyan
            winget install Microsoft.PowerShell.Sudo

            # Configure sudo to use gsudo as the implementation
            if (!(Get-Command gsudo -ErrorAction SilentlyContinue)) {
                Write-Host "Installing gsudo..." -ForegroundColor Cyan
                choco install gsudo -y
            }

            Write-Host "Windows sudo setup complete!" -ForegroundColor Green
        }
    } else {
        Write-Host "Windows sudo is only available on Windows 11 23H2 or newer." -ForegroundColor Yellow
        Write-Host "Installing gsudo as an alternative..." -ForegroundColor Cyan
        choco install gsudo -y
        Write-Host "You can use 'gsudo' instead of 'sudo' for elevated commands." -ForegroundColor Green
    }
}

function Install-Starship {
    Write-Host "Setting up Starship prompt..." -ForegroundColor Cyan

    if (!(Get-Command starship -ErrorAction SilentlyContinue)) {
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

        Add-Content -Path $PROFILE -Value $profileContent

        Write-Host "Starship prompt installed and configured!" -ForegroundColor Green
    } else {
        Write-Host "Starship is already installed." -ForegroundColor Yellow
    }
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

    Add-Content -Path $PROFILE -Value $psReadLineConfig

    Write-Host "PSReadLine configured for autosuggestions and syntax highlighting!" -ForegroundColor Green
}

function Install-DevTools {
    Write-Host "Installing development tools..." -ForegroundColor Cyan

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
    if (!(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe")) {
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

    # Create Ubuntu 24.10 VM with 4GB RAM and 20GB disk
    Write-Host "Creating Ubuntu 24.10 VM with 4GB RAM and 20GB disk..." -ForegroundColor Cyan
    multipass launch noble --name ubuntu-dev --memory 4G --disk 20G

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
    # $restartNeeded = Enable-WSL
    # Install-WSL2Kernel
    # Install-Ubuntu24
    # Install-WindowsSudo
    # Install-Starship
    # Configure-PSReadLine
    # Install-DevTools
    # Install-Multipass
    # Setup-MultipassUbuntu

    # Write-Host "Setup complete!" -ForegroundColor Green

    # if ($restartNeeded) {
    #     Write-Host "A system restart is required to complete WSL setup." -ForegroundColor Yellow
    #     $restart = Read-Host "Would you like to restart now? (y/n)"
    #     if ($restart -eq 'y') {
    #         Restart-Computer
    #     }
    # } else {
    #     Write-Host "To start Ubuntu, open a terminal and type: wsl -d Ubuntu-24.04" -ForegroundColor Cyan
    # }
}

Main
