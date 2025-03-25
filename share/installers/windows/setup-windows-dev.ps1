#Requires -RunAsAdministrator

function Test-CommandExists {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

function Set-ConfigFromGitHub {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigName,

        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]$GitHubUrl,

        [Parameter(Mandatory = $false)]
        [string]$RequiredCommand = "",

        [Parameter(Mandatory = $false)]
        [switch]$CreateDirectory = $false
    )

    Write-Host "Setting up $ConfigName settings..." -ForegroundColor Cyan

    # Check if required command exists
    if ($RequiredCommand -and !(Test-CommandExists $RequiredCommand)) {
        Write-Host "$ConfigName is not installed. Please install $ConfigName first." -ForegroundColor Red
        return $false
    }

    # Create config directory if it doesn't exist and CreateDirectory is true
    $configDir = Split-Path -Parent $ConfigPath
    if ($CreateDirectory -and !(Test-Path $configDir)) {
        try {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
            Write-Host "Created $ConfigName config directory" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to create $ConfigName config directory: $_" -ForegroundColor Red
            return $false
        }
    }

    # Create backup of existing config if it exists
    if (Test-Path $ConfigPath) {
        $backupPath = "$ConfigPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        try {
            Copy-Item -Path $ConfigPath -Destination $backupPath -Force
            Write-Host "Created backup of $ConfigName config at $backupPath" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to create backup of $ConfigName config: $_" -ForegroundColor Red
        }
    }

    # Download config from GitHub
    $tempConfigFile = "$env:TEMP\$(Split-Path -Leaf $ConfigPath)"
    Write-Host "Downloading $ConfigName config from GitHub..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $GitHubUrl -OutFile $tempConfigFile -UseBasicParsing
        Write-Host "$ConfigName config downloaded successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to download $ConfigName config: $_" -ForegroundColor Red
        return $false
    }

    # Copy downloaded config to config location
    try {
        Copy-Item -Path $tempConfigFile -Destination $ConfigPath -Force
        Write-Host "$ConfigName config applied successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to apply $ConfigName config: $_" -ForegroundColor Red
        return $false
    }
    finally {
        # Clean up temporary file
        if (Test-Path $tempConfigFile) {
            Remove-Item -Path $tempConfigFile -Force
        }
    }

    Write-Host "$ConfigName settings setup completed" -ForegroundColor Green
    return $true
}

function Set-VSCodeSettings {
    $vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
    $wslSettingsUrl = "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/extras/vscode/wsl-settings.json"

    Set-ConfigFromGitHub -ConfigName "VS Code WSL" -ConfigPath $vscodeSettingsPath -GitHubUrl $wslSettingsUrl -RequiredCommand "code"
}

function Set-WezTermSettings {
    $wezTermConfigFile = "$env:USERPROFILE\.config\wezterm\wezterm.lua"
    $wezTermConfigUrl = "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/wezterm/dot-config/wezterm/wezterm.lua"

    Set-ConfigFromGitHub -ConfigName "WezTerm" -ConfigPath $wezTermConfigFile -GitHubUrl $wezTermConfigUrl -RequiredCommand "wezterm" -CreateDirectory
}

function New-ConfigLink {
    param (
        [string]$sourcePath,
        [string]$targetPath
    )

    if (!(Test-Path $sourcePath)) {
        Write-Host "Source path $sourcePath does not exist. Skipping." -ForegroundColor Yellow
        return
    }

    $targetDir = Split-Path -Parent $targetPath
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    if (Test-Path $targetPath) {
        $backupPath = "$targetPath.bak"
        if (Test-Path $backupPath) {
            Remove-Item $backupPath -Recurse -Force
        }
        Write-Host "Backing up existing $targetPath to $backupPath" -ForegroundColor Yellow
        Move-Item $targetPath $backupPath -Force
    }

    try {
        New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
        Write-Host "Created symbolic link: $targetPath -> $sourcePath" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create symbolic link. Falling back to copy." -ForegroundColor Red
        Write-Host "Note: Run PowerShell as Administrator to create symbolic links." -ForegroundColor Yellow
        Copy-Item $sourcePath $targetPath -Recurse -Force
        Write-Host "Copied $sourcePath to $targetPath" -ForegroundColor Yellow
    }
}

function Install-Chocolatey {
    if (Test-CommandExists choco) {
        Write-Host "Chocolatey is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    # refreshenv is not available until after installation and shell restart, so we manually update the path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
}

function Install-Scoop {
    if (Test-CommandExists scoop) {
        Write-Host "Scoop is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Scoop..." -ForegroundColor Cyan

    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

    Write-Host "Scoop installed successfully!" -ForegroundColor Green
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

function Install-Ubuntu24 {
    if (!(Test-CommandExists wsl)) {
        Write-Host "WSL is not installed. Please install WSL first." -ForegroundColor Red
        return
    }

    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains "Ubuntu-24.04") {
        Write-Host "Ubuntu 24.04 is already installed." -ForegroundColor Yellow
        return
    }

    $availableDistros = wsl --list --online --quiet

    if ($availableDistros -contains "Ubuntu-24.04") {
        Write-Host "Installing Ubuntu 24.04..." -ForegroundColor Cyan
        wsl --install -d Ubuntu-24.04
        Write-Host "Ubuntu 24.04 installed successfully!" -ForegroundColor Green
        return
    }
    else {
        Write-Host "Ubuntu 24.04 not found in available distributions. Skipping..." -ForegroundColor Yellow
        return
    }
}

function Install-NerdFonts {
    Write-Host "Installing Nerd Fonts..." -ForegroundColor Cyan

    # Check if scoop is installed, install it if not
    if (-not (Test-CommandExists scoop)) {
        Write-Host "Installing Scoop package manager..." -ForegroundColor Cyan
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    # Add the nerd-fonts bucket if not already added
    scoop bucket add nerd-fonts

    # Install popular Nerd Fonts
    scoop install nerd-fonts/JetBrainsMono-NF
    scoop install nerd-fonts/CascadiaCode-NF

    Write-Host "Nerd Fonts installed successfully!" -ForegroundColor Green
}

function Install-Starship {
    if (Test-CommandExists starship) {
        Write-Host "Starship is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Setting up Starship prompt..." -ForegroundColor Cyan
    winget install --id Starship.Starship
    Write-Host "Starship prompt installed successfully!" -ForegroundColor Green

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
    }
    else {
        Write-Host "Starship initialization already exists in PowerShell profile." -ForegroundColor Yellow
    }

    Write-Host "Starship prompt installed and configured!" -ForegroundColor Green
}

function Set-PSReadLine {
    Write-Host "Setting up PSReadLine for autosuggestions and syntax highlighting..." -ForegroundColor Cyan

    # Install or update PSReadLine module
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Write-Host "Updating PSReadLine module..." -ForegroundColor Cyan
        Install-Module -Name PSReadLine -Force -SkipPublisherCheck
    }
    else {
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
    }
    else {
        Write-Host "PSReadLine configuration already exists in PowerShell profile." -ForegroundColor Yellow
    }

    Write-Host "PSReadLine configured for autosuggestions and syntax highlighting!" -ForegroundColor Green
}

function Install-DevTools {
    Write-Host "Installing development tools..." -ForegroundColor Cyan

    # Install 7-Zip
    if (!(Test-Path "C:\Program Files\7-Zip\7z.exe")) {
        Write-Host "Installing 7-Zip..." -ForegroundColor Cyan
        winget install --id 7zip.7zip -e
        Write-Host "7-Zip installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "7-Zip is already installed." -ForegroundColor Yellow
    }

    # Install Visual Studio Code
    if (!(Test-CommandExists code)) {
        Write-Host "Installing Visual Studio Code..." -ForegroundColor Cyan
        winget install --id Microsoft.VisualStudioCode -e
        Write-Host "Visual Studio Code installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Visual Studio Code is already installed." -ForegroundColor Yellow
    }

    # Install Firefox
    if (!(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe") -and
        !(Test-Path "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe")) {
        Write-Host "Installing Firefox..." -ForegroundColor Cyan
        winget install --id Mozilla.Firefox -e
        Write-Host "Firefox installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Firefox is already installed." -ForegroundColor Yellow
    }

    # Install Git
    if (!(Test-CommandExists git)) {
        Write-Host "Installing Git..." -ForegroundColor Cyan
        winget install --id Git.Git -e
        Write-Host "Git installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Git is already installed." -ForegroundColor Yellow
    }

    # Install WezTerm
    if (!(Test-CommandExists wezterm)) {
        Write-Host "Installing WezTerm..." -ForegroundColor Cyan
        winget install --id wez.wezterm -e
        Write-Host "WezTerm installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "WezTerm is already installed." -ForegroundColor Yellow
    }

    # Install Docker Desktop
    if (!(Test-Path "C:\Program Files\Docker\Docker\Docker Desktop.exe")) {
        Write-Host "Installing Docker Desktop..." -ForegroundColor Cyan
        winget install --id Docker.DockerDesktop -e
        Write-Host "Docker Desktop installed successfully!" -ForegroundColor Green
        Write-Host "Make sure to enable the required WSL distro in Docker Desktop settings." -ForegroundColor Yellow
    }
    else {
        Write-Host "Docker Desktop is already installed." -ForegroundColor Yellow
    }

    # Install glazewm
    if (!(Test-CommandExists glazewm)) {
        Write-Host "Installing glazewm..." -ForegroundColor Cyan
        winget install --id glazewm.glazewm -e
        Write-Host "glazewm installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "glazewm is already installed." -ForegroundColor Yellow
    }

    # Install telegram
    if (!(Test-Path "C:\Users\Pervez Iqbal\AppData\Roaming\Telegram Desktop")) {
        Write-Host "Installing telegram..." -ForegroundColor Cyan
        winget install --id Telegram.TelegramDesktop -e
        Write-Host "telegram installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "telegram is already installed." -ForegroundColor Yellow
    }

    # Install zoom
    if (!(Test-Path "C:\Program Files\Zoom\bin\Zoom.exe")) {
        Write-Host "Installing zoom..." -ForegroundColor Cyan
        winget install --id Zoom.Zoom -e
        Write-Host "zoom installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "zoom is already installed." -ForegroundColor Yellow
    }

    # Install ripgrep
    if (!(Test-CommandExists rg)) {
        Write-Host "Installing ripgrep..." -ForegroundColor Cyan
        winget install --id BurntSushi.ripgrep -e
        Write-Host "ripgrep installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "ripgrep is already installed." -ForegroundColor Yellow
    }

    # Install fzf
    if (!(Test-CommandExists fzf)) {
        Write-Host "Installing fzf..." -ForegroundColor Cyan
        winget install --id junegunn.fzf -e
        Write-Host "fzf installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "fzf is already installed." -ForegroundColor Yellow
    }

    # Install fd
    if (!(Test-CommandExists fd)) {
        Write-Host "Installing fd..." -ForegroundColor Cyan
        winget install --id sharkdp.fd -e
        Write-Host "fd installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "fd is already installed." -ForegroundColor Yellow
    }

    # Install bat
    if (!(Test-CommandExists bat)) {
        Write-Host "Installing bat..." -ForegroundColor Cyan
        winget install --id sharkdp.bat -e
        Write-Host "bat installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "bat is already installed." -ForegroundColor Yellow
    }

    # Install gh
    if (!(Test-CommandExists gh)) {
        Write-Host "Installing gh..." -ForegroundColor Cyan
        winget install --id GitHub.cli -e
        Write-Host "gh installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "gh is already installed." -ForegroundColor Yellow
    }

    # Install delta
    if (!(Test-CommandExists delta)) {
        Write-Host "Installing delta..." -ForegroundColor Cyan
        winget install --id dandavison.delta -e
        Write-Host "delta installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "delta is already installed." -ForegroundColor Yellow
    }

    # Install uv
    if (!(Test-CommandExists uv)) {
        Write-Host "Installing uv..." -ForegroundColor Cyan
        winget install --id astral-sh.uv -e
        Write-Host "uv installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "uv is already installed." -ForegroundColor Yellow
    }

    # Install lazygit
    if (!(Test-CommandExists lazygit)) {
        Write-Host "Installing lazygit..." -ForegroundColor Cyan
        winget install --id jesseduffield.lazygit -e
        Write-Host "lazygit installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "lazygit is already installed." -ForegroundColor Yellow
    }

    # Install lazydocker
    if (!(Test-CommandExists lazydocker)) {
        Write-Host "Installing lazydocker..." -ForegroundColor Cyan
        winget install --id jesseduffield.lazydocker -e
        Write-Host "lazydocker installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "lazydocker is already installed." -ForegroundColor Yellow
    }

    # Install neovim
    if (!(Test-CommandExists nvim)) {
        Write-Host "Installing neovim..." -ForegroundColor Cyan
        winget install --id Neovim.Neovim -e
        Write-Host "neovim installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "neovim is already installed." -ForegroundColor Yellow
    }

    # Install emacs
    if (!(Test-Path "C:\Program Files\GNU Emacs")) {
        Write-Host "Installing emacs..." -ForegroundColor Cyan
        winget install GNU.Emacs
        Write-Host "emacs installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "emacs is already installed." -ForegroundColor Yellow
    }

    Write-Host "Development tools installed!" -ForegroundColor Green
}

function Initialize-Dotfiles {
    # Clone dotfiles if not already present, else update
    if (Test-Path "$env:USERPROFILE\ilm") {
        Write-Host "Dotfiles already present. Updating..." -ForegroundColor Cyan

        # pull only if git repo is clean
        if ($null -eq (git status --porcelain)) {
            Set-Location "$env:USERPROFILE\ilm"
            git pull --rebase
        }

        Write-Host "Dotfiles updated successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Cloning dotfiles..." -ForegroundColor Cyan
        git clone https://github.com/pervezfunctor/dotfiles.git "$env:USERPROFILE\ilm"
        Write-Host "Dotfiles cloned successfully!" -ForegroundColor Green
    }

    Write-Host "Setting up WezTerm config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath "$env:USERPROFILE\ilm\wezterm\dot-config\wezterm" -targetPath "$env:USERPROFILE\.config\wezterm"

    Write-Host "Setting up Neovim config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath "$env:USERPROFILE\ilm\nvim\dot-config\nvim" -targetPath "$env:LOCALAPPDATA\nvim"

    Write-Host "Setting up Emacs config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath "$env:USERPROFILE\ilm\emacs-slim\dot-emacs" -targetPath "$env:USERPROFILE\.emacs"
}

function Install-MultipassVM {
    Write-Host "Setting up Ubuntu 24.10 VM in Multipass..." -ForegroundColor Cyan

    $vmExists = multipass list | Select-String "ubuntu-ilm"
    if ($vmExists) {
        Write-Host "Ubuntu VM 'ubuntu-ilm' already exists. Skipping..." -ForegroundColor Yellow
        return
    }

    Write-Host "Creating Ubuntu 24.10 VM with 16GB RAM and 20GB disk..." -ForegroundColor Cyan
    multipass launch oracular --name ubuntu-ilm --memory 16G --disk 20G

    Start-Sleep -Seconds 5

    Write-Host "Running shell installer script..." -ForegroundColor Cyan
    multipass exec ubuntu-ilm -- bash -c "curl -sSL https://dub.sh/aPKPT8V | bash -s -- shell"

    Write-Host "Ubuntu 24.10 VM setup complete!" -ForegroundColor Green
    multipass info ubuntu-ilm

    Write-Host "To access your VM, use: multipass shell ubuntu-ilm" -ForegroundColor Cyan
    Write-Host "To stop your VM, use: multipass stop ubuntu-ilm" -ForegroundColor Cyan
    Write-Host "To start your VM again, use: multipass start ubuntu-ilm" -ForegroundColor Cyan
}

function Install-Multipass {
    Write-Host "Installing Multipass..." -ForegroundColor Cyan

    if (Test-CommandExists multipass) {
        Write-Host "Multipass is already installed." -ForegroundColor Yellow
    }
    else {
        Write-Host "Installing Multipass via winget..." -ForegroundColor Cyan
        winget install Canonical.Multipass
        Write-Host "Multipass installed successfully!" -ForegroundColor Green

        # Refresh PATH to ensure multipass command is available
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    if (!(Test-CommandExists multipass)) {
        Write-Host "Multipass is not available in PATH. Please restart PowerShell or your computer and run this script again." -ForegroundColor Yellow
        return
    }

    Install-MultipassVM
}

function Set-MultipassSSH {
    param (
        [string]$VMName = "ubuntu-ilm"
    )

    Write-Host "Setting up SSH access to Multipass VM '$VMName'..." -ForegroundColor Cyan

    multipass info $VMName 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "VM '$VMName' does not exist. Please create it first." -ForegroundColor Red
        return
    }

    # Get VM IP address
    $vmIP = (multipass info $VMName | Select-String "IPv4").ToString().Split(":")[1].Trim()
    if (-not $vmIP) {
        Write-Host "Could not determine IP address for VM '$VMName'." -ForegroundColor Red
        return
    }

    # Ensure SSH server is installed and configured in the VM
    multipass exec $VMName -- bash -c "sudo apt update && sudo apt install -y openssh-server"
    multipass exec $VMName -- bash -c "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config"
    multipass exec $VMName -- bash -c "sudo systemctl restart ssh"

    # Generate SSH key if it doesn't exist
    if (-not (Test-Path "$env:USERPROFILE\.ssh\id_rsa")) {
        Write-Host "Generating SSH key..." -ForegroundColor Cyan
        ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'
    }

    # Copy SSH key to VM
    $pubKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
    multipass exec $VMName -- bash -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    multipass exec $VMName -- bash -c "echo '$pubKey' >> ~/.ssh/authorized_keys"
    multipass exec $VMName -- bash -c "chmod 600 ~/.ssh/authorized_keys"

    # Add VM to SSH config
    $sshConfig = @"
Host $VMName
    HostName $vmIP
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
"@

    if (-not (Test-Path "$env:USERPROFILE\.ssh\config")) {
        New-Item -Path "$env:USERPROFILE\.ssh\config" -ItemType File -Force | Out-Null
    }

    if (-not (Select-String -Path "$env:USERPROFILE\.ssh\config" -Pattern "Host $VMName" -Quiet)) {
        Add-Content -Path "$env:USERPROFILE\.ssh\config" -Value $sshConfig
    }

    Write-Host "SSH access to Multipass VM '$VMName' has been set up." -ForegroundColor Green
    Write-Host "You can now connect using: ssh $VMName" -ForegroundColor Cyan
}

function Install-CppTools {
    Write-Host "Installing C++ development tools..." -ForegroundColor Cyan

    # Install Visual Studio Build Tools (minimal C++ toolchain)
    if (!(Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2022")) {
        Write-Host "Installing Visual Studio Build Tools..." -ForegroundColor Cyan
        winget install Microsoft.VisualStudio.2022.BuildTools --silent --override "--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
        Write-Host "Visual Studio Build Tools installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Visual Studio Build Tools already installed." -ForegroundColor Yellow
    }

    # Install CMake
    if (!(Test-CommandExists cmake)) {
        Write-Host "Installing CMake..." -ForegroundColor Cyan
        winget install Kitware.CMake
        Write-Host "CMake installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "CMake is already installed." -ForegroundColor Yellow
    }

    # Install Clang/LLVM
    if (!(Test-CommandExists clang)) {
        Write-Host "Installing LLVM/Clang..." -ForegroundColor Cyan
        winget install LLVM.LLVM
        Write-Host "LLVM/Clang installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "LLVM/Clang is already installed." -ForegroundColor Yellow
    }

    # Install Ninja build system
    if (!(Test-CommandExists ninja)) {
        Write-Host "Installing Ninja build system..." -ForegroundColor Cyan
        winget install Ninja-build.Ninja
        Write-Host "Ninja build system installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Ninja build system is already installed." -ForegroundColor Yellow
    }

    Write-Host "C++ development tools installed!" -ForegroundColor Green
}

function Set-PowerShellConfig {
    $psConfigFile = "$env:USERPROFILE\ilm\powershell\Microsoft.PowerShell_profile.ps1"
    $psProfilePath = $PROFILE

    Write-Host "Setting up PowerShell config..." -ForegroundColor Cyan

    # Create profile directory if it doesn't exist
    $profileDir = Split-Path -Parent $psProfilePath
    if (!(Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }

    # Use New-ConfigLink to create a symbolic link
    New-ConfigLink -sourcePath $psConfigFile -targetPath $psProfilePath

    Write-Host "PowerShell config setup completed" -ForegroundColor Green
}

function Install-Nushell {
    Write-Host "Installing Nushell..." -ForegroundColor Cyan

    # Check if Nushell is already installed
    if (Test-CommandExists nu) {
        Write-Host "Nushell is already installed." -ForegroundColor Yellow
    }
    else {
        # Install Nushell using winget
        Write-Host "Installing Nushell via winget..." -ForegroundColor Cyan
        winget install --id Nushell.Nushell -e

        # Update PATH to ensure nu command is available
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # Verify installation
        if (Test-CommandExists nu) {
            Write-Host "Nushell installed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "Failed to install Nushell. Please check your installation." -ForegroundColor Red
            return
        }
    }

    # Set up Nushell configuration using New-ConfigLink
    Write-Host "Setting up Nushell config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath "$env:USERPROFILE\ilm\nushell\dot-config\nushell" -targetPath "$env:APPDATA\nushell"

    # Add Nushell to Windows Terminal profiles
    $wtConfigPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    if (Test-Path $wtConfigPath) {
        Write-Host "Adding Nushell to Windows Terminal profiles..." -ForegroundColor Cyan

        $wtConfig = Get-Content -Path $wtConfigPath -Raw | ConvertFrom-Json

        # Check if Nushell profile already exists
        $nuProfile = $wtConfig.profiles.list | Where-Object { $_.commandline -like "*nu.exe*" }

        if ($null -eq $nuProfile) {
            # Create new Nushell profile
            $nuProfileObj = [PSCustomObject]@{
                name              = "Nushell"
                commandline       = "nu.exe"
                icon              = "$env:USERPROFILE\AppData\Local\Programs\Nushell\nu.ico"
                startingDirectory = "%USERPROFILE%"
            }

            # Add to profiles list
            $wtConfig.profiles.list += $nuProfileObj

            # Save updated config
            $wtConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $wtConfigPath
            Write-Host "Nushell profile added to Windows Terminal!" -ForegroundColor Green
        }
        else {
            Write-Host "Nushell profile already exists in Windows Terminal." -ForegroundColor Yellow
        }
    }

    # # Add option to set as default shell
    # $setAsDefault = Read-Host "Would you like to set Nushell as your default shell in Windows Terminal? (y/n)"
    # if ($setAsDefault -eq 'y') {
    #     if (Test-Path $wtConfigPath) {
    #         $wtConfig = Get-Content -Path $wtConfigPath -Raw | ConvertFrom-Json
    #         $nuProfile = $wtConfig.profiles.list | Where-Object { $_.commandline -like "*nu.exe*" }

    #         if ($null -ne $nuProfile) {
    #             $nuGuid = $nuProfile.guid
    #             $wtConfig.defaultProfile = $nuGuid
    #             $wtConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $wtConfigPath
    #             Write-Host "Nushell set as default shell in Windows Terminal!" -ForegroundColor Green
    #         }
    #     }
    # }

    Write-Host "Nushell installation and configuration complete!" -ForegroundColor Green
    Write-Host "To start Nushell, open a terminal and type: nu" -ForegroundColor Cyan
}

function Update-Windows {
    Write-Host "Checking for Windows updates..." -ForegroundColor Cyan

    # Check if PSWindowsUpdate module is installed
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Cyan
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
        Write-Host "PSWindowsUpdate module installed successfully!" -ForegroundColor Green
    }

    # Import the module
    Import-Module PSWindowsUpdate

    # Get available updates
    $updates = Get-WindowsUpdate

    if ($updates.Count -eq 0) {
        Write-Host "No Windows updates available. System is up to date." -ForegroundColor Green
        return
    }

    Write-Host "Found $($updates.Count) Windows updates available." -ForegroundColor Yellow

    # Check if any updates require a reboot
    $rebootRequired = $updates | Where-Object { $_.RebootRequired -eq $true }

    if (!$rebootRequired) {
        # No reboot required, install all updates
        Write-Host "Installing Windows updates. This may take some time..." -ForegroundColor Cyan
        Install-WindowsUpdate -AcceptAll -AutoReboot:$false
        Write-Host "Windows updates installed successfully!" -ForegroundColor Green
        return
    }

    Write-Host "Some updates require a system reboot." -ForegroundColor Yellow
    $rebootChoice = Read-Host "Would you like to: (1) Install updates and reboot now, (2) Install updates that don't require reboot, or (3) Skip updates?"

    switch ($rebootChoice) {
        "1" {
            # Save script path to run after reboot
            $scriptPath = $MyInvocation.MyCommand.Path
            if ($scriptPath) {
                # Create a scheduled task to resume script after reboot
                $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""
                $trigger = New-ScheduledTaskTrigger -AtLogOn
                Register-ScheduledTask -TaskName "ResumeSetupScript" -Action $action -Trigger $trigger -RunLevel Highest -Force

                Write-Host "Setup will continue automatically after reboot." -ForegroundColor Green
                Install-WindowsUpdate -AcceptAll -AutoReboot
                # Script will end here as system reboots
            }
            else {
                Write-Host "Cannot determine script path. Installing updates with auto-reboot, but you'll need to restart the script manually." -ForegroundColor Yellow
                Install-WindowsUpdate -AcceptAll -AutoReboot
            }
        }
        "2" {
            Write-Host "Installing updates that don't require reboot..." -ForegroundColor Cyan
            Install-WindowsUpdate -AcceptAll -AutoReboot:$false -IgnoreReboot
            Write-Host "Non-reboot updates installed. Some updates were skipped." -ForegroundColor Yellow
        }
        default {
            Write-Host "Skipping Windows updates installation." -ForegroundColor Yellow
        }
    }
}

function Install-Signal {
    Write-Host "Installing Signal messaging app..." -ForegroundColor Cyan

    # Check if Signal is already installed
    if (Test-Path "$env:LOCALAPPDATA\Programs\signal-desktop\Signal.exe") {
        Write-Host "Signal is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Signal via winget..." -ForegroundColor Cyan
    winget install --id OpenWhisperSystems.Signal -e
    Write-Host "Signal installed successfully!" -ForegroundColor Green
}

function Set-CentOSStream10 {
    Write-Host "Setting up CentOS Stream 10..." -ForegroundColor Cyan

    # Prompt for username and password
    $username = Read-Host "Enter username for CentOS"
    $password = Read-Host "Enter password for $username" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    # Download the setup-centos.sh script from GitHub
    $scriptUrl = "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/installers/windows/setup-centos.sh"
    $scriptContent = $null

    Write-Host "Downloading setup script from GitHub..." -ForegroundColor Cyan
    try {
        $scriptContent = Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing | Select-Object -ExpandProperty Content
    }
    catch {
        Write-Host "Failed to download setup script: $_" -ForegroundColor Red
        return
    }

    # Write the script content to a temporary file
    $tempScriptPath = "$env:TEMP\setup-centos.sh"
    Set-Content -Path $tempScriptPath -Value $scriptContent -Encoding UTF8

    # Set the correct permissions for the script
    wsl -d CentOS-Stream-10 -u root bash -c "chmod +x /tmp/setup-centos.sh"

    # Execute the script with the username and password
    Write-Host "Running setup script in CentOS Stream 10..." -ForegroundColor Cyan
    wsl -d CentOS-Stream-10 -u root /tmp/setup-centos.sh "$username" "$passwordText"

    # Clean up the password from memory
    $passwordText = $null
    [System.GC]::Collect()

    # Get IP address to display in PowerShell
    $vmIP = wsl -d CentOS-Stream-10 -u root hostname -I
    $vmIP = $vmIP.Trim()

    # Setup SSH keys
    Write-Host "Setting up SSH key authentication..." -ForegroundColor Cyan

    # Generate SSH key if it doesn't exist
    if (-not (Test-Path "$env:USERPROFILE\.ssh\id_rsa")) {
        Write-Host "Generating SSH key..." -ForegroundColor Cyan
        ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'
    }

    # Copy SSH key to VM
    $pubKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
    wsl -d CentOS-Stream-10 -u root bash -c "mkdir -p /home/$username/.ssh && chmod 700 /home/$username/.ssh"
    wsl -d CentOS-Stream-10 -u root bash -c "echo '$pubKey' >> /home/$username/.ssh/authorized_keys"
    wsl -d CentOS-Stream-10 -u root bash -c "chmod 600 /home/$username/.ssh/authorized_keys"
    wsl -d CentOS-Stream-10 -u root bash -c "chown -R ${username}:${username} /home/$username/.ssh"

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


function Install-JetBrainsMonoNerdFont {
    Write-Host "Installing JetBrains Mono Nerd Font..." -ForegroundColor Cyan

    # Check if font is already installed
    $fontsFolderPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    if (Test-Path "$fontsFolderPath\JetBrainsMonoNerdFont-Regular.ttf") {
        Write-Host "JetBrains Mono Nerd Font is already installed." -ForegroundColor Yellow
        return
    }

    # Create temporary directory for download
    $tempDir = "$env:TEMP\nerd-fonts"
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

    # Download JetBrains Mono Nerd Font
    $downloadUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
    $zipPath = "$tempDir\JetBrainsMono.zip"

    Write-Host "Downloading JetBrains Mono Nerd Font (this may take time)..." -ForegroundColor Cyan
    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
        Write-Host "Download completed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        return
    }
    $ProgressPreference = 'Continue'

    # Extract the zip file
    Write-Host "Extracting font files..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

    # Install fonts
    Write-Host "Installing fonts..." -ForegroundColor Cyan
    $fontFiles = Get-ChildItem -Path $tempDir -Filter "*.ttf"

    foreach ($fontFile in $fontFiles) {
        $fontDestination = "$fontsFolderPath\$($fontFile.Name)"
        Copy-Item -Path $fontFile.FullName -Destination $fontDestination -Force

        # Register the font
        $fontRegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontName = $fontFile.BaseName + " (TrueType)"
        New-ItemProperty -Path $fontRegistryPath -Name $fontName -Value $fontDestination -Force | Out-Null
    }

    # Clean up
    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item -Path $tempDir -Recurse -Force

    Write-Host "JetBrains Mono Nerd Font installed successfully!" -ForegroundColor Green
}

function Set-VSCodeSettings {
    Write-Host "Setting up VSCode settings..." -ForegroundColor Cyan

    $dotfilesDir = "$env:USERPROFILE\ilm"
    $vscodeSettingsDir = "$env:APPDATA\Code\User"
    $extensionsFile = "$dotfilesDir\extras\vscode\extensions\common"
    $settingsFile = "$dotfilesDir\extras\vscode\settings.json"

    if (!(Test-CommandExists code)) {
        Write-Host "VS Code is not installed. Please install VS Code first." -ForegroundColor Red
        return
    }

    if (!(Test-Path $vscodeSettingsDir)) {
        try {
            New-Item -Path $vscodeSettingsDir -ItemType Directory -Force | Out-Null
            Write-Host "Created VS Code settings directory" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to create VS Code settings directory: $_" -ForegroundColor Red
            return
        }
    }

    if (Test-Path $extensionsFile) {
        Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan
        try {
            Get-Content -Path $extensionsFile | ForEach-Object {
                if ($_ -and !($_.StartsWith('#'))) {
                    Write-Host "Installing extension: $_" -ForegroundColor Yellow
                    code --install-extension $_ --force
                }
            }
        }
        catch {
            Write-Host "Failed to install some extensions: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Extensions file not found at $extensionsFile" -ForegroundColor Red
    }

    if (Test-Path $settingsFile) {
        try {
            Write-Host "Copying VS Code settings..." -ForegroundColor Cyan
            Copy-Item -Path $settingsFile -Destination "$vscodeSettingsDir\settings.json" -Force
            Write-Host "VS Code settings copied successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to copy settings file: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Settings file not found at $settingsFile" -ForegroundColor Red
    }

    Write-Host "VS Code setup completed" -ForegroundColor Green
}

function Set-CapsLockAsControl {
    Write-Host "Remapping Caps Lock to Control key..." -ForegroundColor Cyan

    $regFilePath = "$env:USERPROFILE\ilm\share\installers\windows\caps2ctrl.reg"

    if (Test-Path $regFilePath) {
        # Silent import of registry file
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s", "`"$regFilePath`"" -Wait
        Write-Host "Caps Lock remapped to Control key. A system restart is required." -ForegroundColor Green
    }
    else {
        Write-Host "Registry file not found at: $regFilePath" -ForegroundColor Red
    }
}

function Install-VSCodeExtensions {
    Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan

    $extensionsFile = "$env:USERPROFILE\ilm\extras\vscode\extensions\wsl"

    if (Test-Path $extensionsFile) {
        Get-Content $extensionsFile | ForEach-Object {
            if ($_ -match '\S') {
                Write-Host "Installing extension: $_" -ForegroundColor DarkCyan
                code --install-extension $_
            }
        }
        Write-Host "VS Code extensions installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Extensions file not found at: $extensionsFile" -ForegroundColor Red
    }
}

function Main {
    Write-Host "Starting Windows development environment setup..." -ForegroundColor Green

    Update-Windows
    Install-Chocolatey
    Install-Scoop

    Install-DevTools
    Initialize-Dotfiles

    Install-JetBrainsMonoNerdFont
    Install-Starship
    Set-PowerShellConfig
    Install-Nushell

    Install-CppTools
    Set-VSCodeSettings
    Install-VSCodeExtensions

    Install-Signal

    Install-Multipass
    Install-WSL
    Install-Ubuntu24
    Install-CentOSStream10
    Set-CentOSStream10
    Set-MultipassSSH

    Set-CapsLockAsControl

    Write-Host "Windows development environment setup complete!" -ForegroundColor Green
}

Main
