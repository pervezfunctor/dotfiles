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
        Write-Error "winget command not found. Please install the Windows Package Manager (App Installer)."
        return
    }

    Write-Verbose "Installing/Updating development tools using winget..."

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
        Write-Verbose "Processing package: $packageId"
        winget install --id $packageId -e --accept-source-agreements

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install/update package '$packageId'. winget exited with code $LASTEXITCODE."
        }
        else {
            Write-Verbose "Package '$packageId' processed successfully."
        }
    }
}

function Install-WSL {
    # Check if WSL is installed by looking at Windows features
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    if ($wslFeature.State -ne "Enabled") {
        Write-Information "WSL is not installed. Installing now..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

        wsl --install --no-distribution
        return $true  # Restart needed
    }

    Write-Information "Updating WSL..."
    wsl --update

    Write-Warning "WSL is installed."
    return $false  # No restart needed
}

function Install-CentOSWSL {
    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains "CentOS-Stream-10") {
        Write-Warning "CentOS Stream 10 is already installed."
        return $false
    }

    Write-Information "Installing CentOS Stream 10 on WSL..."

    $wslDir = "$env:LOCALAPPDATA\WSL\CentOS-Stream-10"
    New-Item -Path $wslDir -ItemType Directory -Force | Out-Null

    $tempDir = "$env:TEMP"
    $archivePath = "$tempDir\CentOS-Stream-Image-WSL-Base.x86_64-10-202501111101.tar.xz"

    $downloadUrl = "https://mirror.stream.centos.org/SIGs/10-stream/altimages/images/wsl/x86_64/CentOS-Stream-Image-WSL-Base.x86_64-10-202501111101.tar.xz"

    Write-Information "Downloading CentOS Stream 10 WSL image (this may take time)..."

    $ProgressPreference = 'SilentlyContinue'
    try {
        if (Test-Path $archivePath) {
            Write-Warning "CentOS Stream 10 WSL image already downloaded."
        }
        else {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing
            if ($LASTEXITCODE -ne 0 -or !(Test-Path $archivePath)) {
                Write-Error "CentOS download failed."
                return $false
            }
            Write-Verbose "Download completed successfully!"
        }
    }
    catch {
        Write-Error "Download failed: $_"
        Write-Warning "You can try downloading the file manually from:"
        Write-Warning $downloadUrl
        Write-Warning "Then place it at: $archivePath"
        return $false
    }
    $ProgressPreference = 'Continue'

    Write-Information "Importing CentOS Stream 10 to WSL..."
    wsl --import --version=2 CentOS-Stream-10 $wslDir $archivePath

    if ($LASTEXITCODE -ne 0) {
        Write-Error "CentOS import failed."
        return $false
    }

    Write-Information "Cleaning up temporary files..."
    Remove-Item -Path $archivePath -Force

    Write-Verbose "CentOS Stream 10 installed successfully!"
    Write-Information "Reboot your computer. Then to start CentOS Stream 10, open a terminal and type: wsl -d CentOS-Stream-10"
}

function Initialize-CentOSStream10 {
    Write-Information "Setting up CentOS Stream 10..."

    $username = Read-Host "Enter username for CentOS"
    $password = Read-Host "Enter password for $username" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    Write-Information "Running setup script in CentOS Stream 10..."

    wsl -d CentOS-Stream-10 -u root -- bash -c "curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/windows/setup-centos.sh | bash -s -- '$username' '$passwordText'"

    # Clean up the password from memory
    $passwordText = $null
    [System.GC]::Collect()

    Write-Verbose "CentOS Stream 10 setup complete!"
    Write-Information "To access your CentOS environment, use: wsl -d CentOS-Stream-10"
}

function Install-NerdFonts {
    Write-Information "Installing Nerd Fonts using Chocolatey..."

    if (-not (Test-CommandExists choco)) {
        Write-Information "Installing Chocolatey package manager..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    if (-not (Test-CommandExists choco)) {
        Write-Error "Chocolatey is not installed. Cannot install Nerd Fonts."
        return
    }

    choco install nerd-fonts-jetbrainsmono -y
    choco install nerd-fonts-cascadiacode -y

    Write-Verbose "Nerd Fonts installed successfully!"
}

function Backup-ConfigFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (!(Test-Path $FilePath)) {
        Write-Warning "$FilePath does not exist. No backup needed."
        return $false
    }

    try {
        $item = Get-Item -Path $FilePath -Force -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to get item properties for $FilePath`: $_"
        return $false
    }

    if ($item.LinkType -eq "SymbolicLink") {
        Write-Warning "$FilePath is a symbolic link. No backup needed."
        return $false
    }

    $backupPath = "$FilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    try {
        Copy-Item -Path $FilePath -Destination $backupPath -Recurse -Force -ErrorAction Stop
        Write-Verbose "Created backup of ${FilePath} at ${backupPath}"
        return $true
    }
    catch {
        Write-Error "Failed to backup ${FilePath}: $_"
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
        Write-Verbose "No directory path specified in '$ConfigPath'. Assuming current directory."
        return $true
    }

    if (Test-Path $configDir -PathType Container) {
        Write-Verbose "Directory '$configDir' already exists."
        return $true
    }

    try {
        New-Item -Path $configDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-Verbose "Created directory at $configDir"
        return $true
    }
    catch {
        Write-Error "Failed to create directory at ${configDir}: $_"
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

    Write-Verbose "Setting up ${ConfigPath} settings..."

    if (!(New-ConfigDirectory -ConfigPath $ConfigPath -Verbose:$VerbosePreference)) {
        return $false
    }

    if (!(Backup-ConfigFile -FilePath $ConfigPath -Verbose:$VerbosePreference)) {
        Write-Warning "Backup for $ConfigPath failed or was skipped. Overwriting existing file if it exists."
    }

    try {
        Write-Verbose "Downloading ${ConfigPath} from ${GitHubUrl}..."
        $content = Invoke-WebRequest -Uri $GitHubUrl -UseBasicParsing -ErrorAction Stop | Select-Object -ExpandProperty Content

        Write-Verbose "Applying configuration to ${ConfigPath}..."
        Set-Content -Path $ConfigPath -Value $content -Force -ErrorAction Stop
        Write-Verbose "Applied ${ConfigPath} configuration successfully"
        return $true
    }
    catch {
        Write-Error "Failed to download or apply ${ConfigPath} configuration from ${GitHubUrl}: $_"
        return $false
    }
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
    Write-Information "Installing VS Code extensions..."

    $extensionsUrl = "$global:GitHubBaseUrl/extras/vscode/extensions/wsl"

    try {
        Write-Information "Downloading VS Code extensions list from GitHub..."
        $extensionsList = Invoke-WebRequest -Uri $extensionsUrl -UseBasicParsing | Select-Object -ExpandProperty Content

        $extensionsList -split "`n" | ForEach-Object {
            $extension = $_.Trim()
            if ($extension -match '\S' -and -not $extension.StartsWith('#')) {
                Write-Information "Installing extension: $extension"
                code --install-extension $extension
            }
        }

        Write-Verbose "VS Code extensions installed successfully!"
    }
    catch {
        Write-Error "Failed to download VS Code extensions list: $_"
        Write-Warning "Extensions URL: $extensionsUrl"
    }
}

function Main {
    Write-Verbose "Starting Windows development environment setup..."

    if (Install-WSL) {
        Write-Warning "Please restart your computer to complete WSL installation."
        Write-Warning "After restart, run this script again to continue the setup."
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

    Write-Verbose "Windows development environment setup complete!"
}

Main
