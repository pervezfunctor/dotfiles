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
    if (-not (Test-CommandExists winget)) {
        Write-Host "winget command not found. Please install the Windows Package Manager (App Installer)." -ForegroundColor Red
        return
    }

    Write-Host "Installing/Updating development tools using winget..." -ForegroundColor Cyan

    $packages = @(
        "Microsoft.VisualStudioCode"
        "Git.Git"
        "GitHub.cli"
        "dandavison.delta"
        "wez.wezterm"
        "astral-sh.uv"
        "BurntSushi.ripgrep.MSVC"
        "junegunn.fzf"
    )

    foreach ($packageId in $packages) {
        Write-Host "Processing package: $packageId" -ForegroundColor Cyan
        winget install --id $packageId -e --accept-source-agreements

        if (($LASTEXITCODE -ne 0) -and ($LASTEXITCODE -ne -1978335189)) {
            Write-Host "Failed to install/update package '$packageId'. winget exited with code $LASTEXITCODE." -ForegroundColor Red
        }
        else {
            Write-Host "Package '$packageId' processed successfully." -ForegroundColor Cyan
        }
    }
}

function Initialize-WSLDistro {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DistroName,

        [Parameter(Mandatory = $true)]
        [string]$Username,

        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$Password
    )

    Write-Host "Running setup script in $DistroName..." -ForegroundColor Cyan

    # Extract the base distro type (centos, ubuntu, debian, opensuse)
    $distroType = $DistroName
    if ($DistroName -match "^(CentOS|Ubuntu|Debian|openSUSE)") {
        $distroType = $matches[1].ToLower()
    }

    wsl -d $DistroName -u root -- bash -c "curl -sSL $global:GitHubBaseUrl/windows/setup-distro.sh | bash -s -- '$Username' '$Password' '$distroType'"

    # Clean up the password from memory
    $Password = $null
    [System.GC]::Collect()

    Write-Host "$DistroName setup complete!" -ForegroundColor Green
    Write-Host "To access your $DistroName environment, use: wsl -d $DistroName" -ForegroundColor Cyan
}

function Install-WSL {
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    if ($wslFeature.State -ne "Enabled") {
        Write-Host "WSL is not installed. Installing now..." -ForegroundColor Cyan
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

        wsl --install --no-distribution
        return $true
    }

    Write-Host "Updating WSL..." -ForegroundColor Cyan
    wsl --update | Out-Null

    Write-Host "WSL is installed." -ForegroundColor Cyan
    return $false
}

function Install-CentOSWSL {
    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains "CentOS-Stream-10") {
        Write-Host "CentOS Stream 10 is already installed." -ForegroundColor Cyan
        return $false
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
        if (Test-Path $archivePath) {
            Remove-Item -Path $archivePath -Force
        }

        Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing
        if ($LASTEXITCODE -ne 0 -or !(Test-Path $archivePath)) {
            Write-Host "CentOS download failed." -ForegroundColor Red
            return $false
        }
        Write-Host "Download completed successfully!" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        Write-Host "You can try downloading the file manually from:" -ForegroundColor Cyan
        Write-Host $downloadUrl -ForegroundColor Cyan
        Write-Host "Then place it at: $archivePath" -ForegroundColor Cyan
        return $false
    }
    $ProgressPreference = 'Continue'

    Write-Host "Importing CentOS Stream 10 to WSL..." -ForegroundColor Cyan
    wsl --import --version=2 CentOS-Stream-10 $wslDir $archivePath

    if ($LASTEXITCODE -ne 0) {
        Write-Host "CentOS import failed." -ForegroundColor Red
        return $false
    }

    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item -Path $archivePath -Force

    Write-Host "CentOS Stream 10 installed successfully!" -ForegroundColor Cyan
}

function Initialize-CentOSStream10 {
    Write-Host "Setting up CentOS Stream 10..." -ForegroundColor Cyan

    $username = Read-Host "Enter username for CentOS"
    $password = Read-Host "Enter password for $username" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    Write-Host "Running setup script in CentOS Stream 10..." -ForegroundColor Cyan

    wsl -d CentOS-Stream-10 -u root -- bash -c "curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/windows/setup-centos.sh | bash -s -- '$username' '$passwordText'"

    # Clean up the password from memory
    $passwordText = $null
    [System.GC]::Collect()

    Write-Host "CentOS Stream 10 setup complete!" -ForegroundColor Cyan
    Write-Host "To access your CentOS environment, use: wsl -d CentOS-Stream-10" -ForegroundColor Green
}

function Install-NerdFonts {
    Write-Host "Installing Nerd Fonts using Chocolatey..." -ForegroundColor Cyan

    if (-not (Test-CommandExists choco)) {
        Write-Host "Installing Chocolatey package manager..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    if (-not (Test-CommandExists choco)) {
        Write-Host "Chocolatey is not installed. Cannot install Nerd Fonts." -ForegroundColor Red
        return
    }

    choco install nerd-fonts-jetbrainsmono -y
    choco install nerd-fonts-cascadiacode -y

    Write-Host "Nerd Fonts installed successfully!" -ForegroundColor Cyan
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

    try {
        $item = Get-Item -Path $FilePath -Force -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to get item properties for $FilePath`: $_" -ForegroundColor Red
        return $false
    }

    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "$FilePath is a symbolic link. No backup needed." -ForegroundColor Yellow
        return $false
    }

    $backupPath = "$FilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    try {
        Copy-Item -Path $FilePath -Destination $backupPath -Recurse -Force -ErrorAction Stop
        Write-Host "Created backup of ${FilePath} at ${backupPath}" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to backup ${FilePath}: $_" -ForegroundColor Red
        return $false
    }
}

function New-ConfigDirectory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )

    $configDir = Split-Path -Parent $ConfigPath
    if ([string]::IsNullOrEmpty($configDir)) {
        Write-Host "No directory path specified in '$ConfigPath'. Assuming current directory." -ForegroundColor Yellow
        return $true
    }

    if (Test-Path $configDir -PathType Container) {
        Write-Host "Directory '$configDir' already exists." -ForegroundColor Yellow
        return $true
    }

    try {
        New-Item -Path $configDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-Host "Created directory at $configDir" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to create directory at ${configDir}: $_" -ForegroundColor Red
        return $false
    }
}

function Copy-ConfigFromGitHub {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter(Mandatory = $true)]
        [ValidatePattern('^https?://.+')]
        [string]$GitHubUrl
    )

    Write-Host "Setting up ${ConfigPath} settings..." -ForegroundColor Cyan

    if (!(New-ConfigDirectory -ConfigPath $ConfigPath)) {
        Write-Host "Failed to create ${ConfigPath} config directory. Skipping..." -ForegroundColor Yellow
        return $false
    }

    if (!(Backup-ConfigFile -FilePath $ConfigPath)) {
        Write-Host "Backup for $ConfigPath failed or was skipped. Overwriting existing file if it exists." -ForegroundColor Yellow
    }

    try {
        Write-Host "Downloading ${ConfigPath} from ${GitHubUrl}..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $GitHubUrl -OutFile $ConfigPath -UseBasicParsing -ErrorAction Stop

        Write-Host "Applied ${ConfigPath} configuration successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to download or apply ${ConfigPath} configuration from ${GitHubUrl}: $_" -ForegroundColor Red
        return $false
    }
}

function Set-VSCodeSettings {
    $vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
    $wslSettingsUrl = "$global:GitHubBaseUrl/extras/vscode/wsl-settings.json"

    Copy-ConfigFromGitHub -ConfigPath $vscodeSettingsPath -GithubUrl $wslSettingsUrl | Out-Null
}

function Set-WezTermSettings {
    $wezTermConfigFile = "$env:USERPROFILE\.config\wezterm\wezterm.lua"
    $wezTermConfigUrl = "$global:GitHubBaseUrl/wezterm/dot-config/wezterm/wezterm.lua"

    Copy-ConfigFromGitHub -ConfigPath $wezTermConfigFile -GithubUrl $wezTermConfigUrl | Out-Null
}

function Install-VSCodeExtensions {
    Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan

    $extensionsUrl = "$global:GitHubBaseUrl/extras/vscode/extensions/wsl"

    try {
        Write-Host "Downloading VS Code extensions list from GitHub..."
        $extensionsList = Invoke-WebRequest -Uri $extensionsUrl -UseBasicParsing | Select-Object -ExpandProperty Content

        $extensionsList -split "`n" | ForEach-Object {
            $extension = $_.Trim()
            if ($extension -match '\S' -and -not $extension.StartsWith('#')) {
                Write-Host "Installing extension: $extension"
                code --install-extension $extension
            }
        }

        Write-Host "VS Code extensions installed successfully!" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Failed to download VS Code extensions list: $_" -ForegroundColor Red
        Write-Host "Extensions URL: $extensionsUrl" -ForegroundColor Yellow
    }
}

function Main {
    Write-Host "Starting Windows development environment setup..." -ForegroundColor Cyan

    if (Install-WSL) {
        Write-Host "Please restart your computer to complete WSL installation." -ForegroundColor Yellow
        Write-Host "After restart, run this script again to continue the setup." -ForegroundColor Yellow
        return
    }

    Install-DevTools
    Install-NerdFonts

    if (Install-CentOSWSL) {
        Initialize-CentOSStream10
    }

    Install-VSCodeExtensions
    Set-VSCodeSettings
    Set-WezTermSettings

    Write-Host "Windows development environment setup complete!" -ForegroundColor Cyan
}

Main
