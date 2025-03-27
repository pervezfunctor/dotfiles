#Requires -RunAsAdministrator

$global:GitHubBaseUrl = "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main"

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

    winget install --id GitHub.cli -e

    # winget install --id wez.wezterm -e
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

    $username = Read-Host "Enter username for CentOS"
    $password = Read-Host "Enter password for $username" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    Write-Host "Running setup script in CentOS Stream 10..." -ForegroundColor Cyan

    wsl -d CentOS-Stream-10 -u root -- bash -c "curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/windows/setup-centos.sh | bash -s -- '$username' '$passwordText'"

    # Clean up the password from memory
    $passwordText = $null
    [System.GC]::Collect()

    Write-Host "CentOS Stream 10 setup complete!" -ForegroundColor Green
    Write-Host "To access your CentOS environment, use: wsl -d CentOS-Stream-10" -ForegroundColor Cyan
}

function Install-WSL {
    # Check if WSL is installed by looking at Windows features
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    if ($wslFeature.State -ne "Enabled") {
        Write-Host "WSL is not installed. Installing now..." -ForegroundColor Cyan
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        wsl --install --no-distribution
        return $true  # Restart needed
    }

    # If we get here, WSL is installed
    Write-Host "WSL is already installed." -ForegroundColor Yellow
    return $false  # No restart needed
}

function Install-CentOSStream10 {
    if (!(Test-CommandExists wsl)) {
        Write-Host "WSL command does not exist. Older Windows version? Quitting." -ForegroundColor Red
        return $false
    }

    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains "CentOS-Stream-10") {
        Write-Host "CentOS Stream 10 is already installed." -ForegroundColor Yellow
        return $false
    }

    Write-Host "Installing CentOS Stream 10 on WSL..." -ForegroundColor Cyan

    # Ensure WSL is fully stopped
    wsl --shutdown
    Start-Sleep -Seconds 2

    $wslDir = "$env:LOCALAPPDATA\WSL\CentOS-Stream-10"
    if (Test-Path $wslDir) {
        Write-Host "Removing existing WSL directory..." -ForegroundColor Yellow
        Remove-Item -Path $wslDir -Recurse -Force
    }
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
        return $false
    }
    $ProgressPreference = 'Continue'

    Write-Host "Importing CentOS Stream 10 to WSL..." -ForegroundColor Cyan

    try {
        # Run the import command and capture output
        $importOutput = & wsl --import CentOS-Stream-10 $wslDir $archivePath 2>&1
        Write-Host "Import command output: $importOutput" -ForegroundColor DarkCyan

        # Wait a moment for WSL to register the new distribution
        Start-Sleep -Seconds 5

        # Check if the distribution was installed
        $installedDistros = wsl --list --quiet
        if ($installedDistros -contains "CentOS-Stream-10") {
            Write-Host "CentOS Stream 10 installed successfully!" -ForegroundColor Green

            Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
            Remove-Item -Path $archivePath -Force

            # Test the distribution
            Write-Host "Testing CentOS Stream 10 installation..." -ForegroundColor Cyan
            $testOutput = & wsl -d CentOS-Stream-10 -- echo "WSL test successful"
            Write-Host "Test output: $testOutput" -ForegroundColor DarkCyan

            return $true
        }
        else {
            Write-Host "Import command completed but CentOS-Stream-10 is not in the list of installed distributions." -ForegroundColor Red
            Write-Host "Installed distributions:" -ForegroundColor Yellow
            wsl --list

            # Try a different approach - unregister and try again
            Write-Host "Trying alternative approach..." -ForegroundColor Yellow
            wsl --unregister CentOS-Stream-10 2>$null

            Write-Host "Retrying import with explicit path..." -ForegroundColor Cyan
            $fullWslDir = (Resolve-Path $wslDir).Path
            $fullArchivePath = (Resolve-Path $archivePath).Path

            $importCmd = "wsl --import CentOS-Stream-10 `"$fullWslDir`" `"$fullArchivePath`""
            Write-Host "Running: $importCmd" -ForegroundColor DarkCyan
            Invoke-Expression $importCmd

            Start-Sleep -Seconds 3
            $installedDistros = wsl --list --quiet
            if ($installedDistros -contains "CentOS-Stream-10") {
                Write-Host "CentOS Stream 10 installed successfully on second attempt!" -ForegroundColor Green
                Remove-Item -Path $archivePath -Force
                return $true
            }

            return $false
        }
    }
    catch {
        Write-Host "Error importing CentOS Stream 10: $_" -ForegroundColor Red
        Write-Host "The downloaded file is still available at: $archivePath" -ForegroundColor Cyan
        Write-Host "Try manually importing with: wsl --import CentOS-Stream-10 $wslDir $archivePath" -ForegroundColor Yellow
        return $false
    }
}

function Install-NerdFonts {
    Write-Host "Installing Nerd Fonts using Chocolatey..." -ForegroundColor Cyan

    # Check if chocolatey is installed, install it if not
    if (-not (Test-CommandExists choco)) {
        Write-Host "Installing Chocolatey package manager..." -ForegroundColor Cyan
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    # Install Nerd Fonts
    choco install nerd-fonts-jetbrainsmono -y
    choco install nerd-fonts-cascadiacode -y

    Write-Host "Nerd Fonts installed successfully!" -ForegroundColor Green
}


function Backup-ConfigFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (!(Test-Path $FilePath)) {
        Write-Host "$FilePath does not exist. No backup needed." -ForegroundColor Yellow
        return $false
    }

    $item = Get-Item -Path $FilePath -Force
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "$FilePath is a symbolic link. No backup needed." -ForegroundColor Yellow
        return $false
    }

    $backupPath = "$FilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    try {
        # Check if it's a directory
        if (Test-Path -Path $FilePath -PathType Container) {
            Copy-Item -Path $FilePath -Destination $backupPath -Force -Recurse
        }
        else {
            Copy-Item -Path $FilePath -Destination $backupPath -Force
        }
        Write-Host "Created backup of ${FilePath} at ${backupPath}" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to backup ${FilePath}: $_" -ForegroundColor Red
        return $false
    }
}
function New-Directory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path $Path) {
        return $true
    }

    try {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Host "Created directory at $Path" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to create directory at ${Path}: $_" -ForegroundColor Red
        return $false
    }
}

function New-ConfigDirectory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )

    $configDir = Split-Path -Parent $ConfigPath

    return New-Directory -Path $configDir
}

function Get-AndApplyConfig {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )

    try {
        Write-Host "Downloading $ConfigPath from $GitHubUrl..." -ForegroundColor Cyan
        $content = Invoke-WebRequest -Uri $GitHubUrl -UseBasicParsing | Select-Object -ExpandProperty Content

        Set-Content -Path $ConfigPath -Value $content -Force
        Write-Host "Applied $ConfigPath configuration successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to download or apply $ConfigPath configuration: $_" -ForegroundColor Red
        return $false
    }
}

function Copy-ConfigFromGitHub {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]$GitHubUrl
    )

    Write-Host "Setting up ${ConfigPath} settings..." -ForegroundColor Cyan

    if (!(New-ConfigDirectory -ConfigPath $ConfigPath)) {
        Write-Host "Failed to create ${ConfigPath} config directory. Skipping..." -ForegroundColor Yellow
        return $false
    }

    Backup-ConfigFile -FilePath $ConfigPath

    try {
        Write-Host "Downloading ${ConfigPath} from ${GithubUrl}..." -ForegroundColor Cyan
        $content = Invoke-WebRequest -Uri ${GithubUrl} -UseBasicParsing | Select-Object -ExpandProperty Content

        Set-Content -Path $ConfigPath -Value $content -Force
        Write-Host "Applied ${ConfigPath} configuration successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to download or apply ${ConfigPath} configuration: $_" -ForegroundColor Red
        return $false
    }

    Write-Host "${ConfigPath} setup completed" -ForegroundColor Green
    return $true
}

function Set-VSCodeSettings {
    $vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
    $wslSettingsUrl = "$global:GitHubBaseUrl/extras/vscode/wsl-settings.json"

    Copy-ConfigFromGitHub -ConfigPath $vscodeSettingsPath -GithubUrl $wslSettingsUrl
}

function Set-WezTermSettings {
    $wezTermConfigFile = "$env:USERPROFILE\.config\wezterm\wezterm.lua"
    $wezTermConfigUrl = "$global:GitHubBaseUrl/wezterm/dot-config/wezterm/wezterm.lua"

    Copy-ConfigFromGitHub -ConfigPath $wezTermConfigFile -GithubUrl $wezTermConfigUrl
}

function Install-VSCodeExtensions {
    Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan

    $extensionsUrl = "$global:GitHubBaseUrl/extras/vscode/extensions/wsl"

    try {
        Write-Host "Downloading VS Code extensions list from GitHub..." -ForegroundColor Cyan
        $extensionsList = Invoke-WebRequest -Uri $extensionsUrl -UseBasicParsing | Select-Object -ExpandProperty Content

        $extensionsList -split "`n" | ForEach-Object {
            $extension = $_.Trim()
            if ($extension -match '\S' -and -not $extension.StartsWith('#')) {
                Write-Host "Installing extension: $extension" -ForegroundColor DarkCyan
                code --install-extension $extension
            }
        }

        Write-Host "VS Code extensions installed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to download VS Code extensions list: $_" -ForegroundColor Red
        Write-Host "Extensions URL: $extensionsUrl" -ForegroundColor Yellow
    }
}

function Main {
    Write-Host "Starting Windows development environment setup..." -ForegroundColor Green

    if (Install-WSL) {
        Write-Host "Please restart your computer to complete WSL installation." -ForegroundColor Yellow
        Write-Host "After restart, run this script again to continue the setup." -ForegroundColor Yellow
        return
    }

    Write-Host "Fizz Buzz"

    # Install-DevTools
    # Install-NerdFonts

    if (Install-CentOSStream10) {
        Set-CentOSStream10
    }

    # Install-VSCodeExtensions
    # Set-VSCodeSettings

    Write-Host "Windows development environment setup complete!" -ForegroundColor Green
}

Main
