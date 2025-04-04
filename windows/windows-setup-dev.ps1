<#
.SYNOPSIS
Windows development environment setup script.

.DESCRIPTION
This script automates the setup of a Windows development environment with various components.

.PARAMETER ListComponents
Lists all available components that can be installed.

.PARAMETER Components
Specifies which components to install. Can be component names like "wsl", "devtools", "nerd-fonts", etc.
Multiple components can be specified separated by commas.

.EXAMPLE
.\windows-setup-dev.ps1 -ListComponents
Lists all available components.

.EXAMPLE
.\windows-setup-dev.ps1 -Components wsl,devtools,nerd-fonts
Installs the specified components without showing the interactive menu.

.EXAMPLE
.\windows-setup-dev.ps1
Runs in fully interactive mode with no pre-selections.
#>

param(
    [switch]$ListComponents,
    [string[]]$Components = @()
)

# Set execution policy for the current process only
$originalPolicy = Get-ExecutionPolicy -Scope Process
if ($originalPolicy -ne "RemoteSigned" -and $originalPolicy -ne "Unrestricted") {
    Write-Host "Setting execution policy to RemoteSigned for current session..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
    Write-Host "Execution policy set to RemoteSigned for this session." -ForegroundColor Green
}

$global:GitHubBaseUrl = "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main"
$global:DotDir = "$env:USERPROFILE\ilm"
$global:WinDir = "$global:DotDir\windows"

function Test-CommandExists {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

function Restart-PC {
    $restart = Read-Host "A restart is required to complete installation. Would you like to restart now? (y/n)"
    if ($restart -eq 'y' -or $restart -eq 'Y') {
        Write-Host "Restarting computer. Please run this script again after restart to continue setup." -ForegroundColor Cyan
        Start-Sleep -Seconds 5
        $global:LASTEXITCODE = 0
        Restart-Computer
    }

    Write-Host "Please restart your computer manually and run this script again to continue setup." -ForegroundColor Yellow
    exit 0
}

function Backup-ConfigFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (!(Test-Path $FilePath)) {
        Write-Host "$FilePath does not exist. No backup needed." -ForegroundColor Yellow
        return
    }

    $item = Get-Item -Path $FilePath -Force
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "$FilePath is a symbolic link. No backup needed." -ForegroundColor Yellow
        return
    }

    $backupPath = "$FilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    try {
        Copy-Item -Path $FilePath -Destination $backupPath -Force -Recurse
        Write-Host "Created backup of ${FilePath} at ${backupPath}" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to backup ${FilePath}: $_" -ForegroundColor Red
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

    try {
        Backup-ConfigFile -FilePath $ConfigPath
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

function New-ConfigLink {
    param (
        [string]$sourcePath,
        [string]$targetPath
    )

    if (!(Test-Path $sourcePath)) {
        Write-Host "Source path $sourcePath does not exist. Skipping." -ForegroundColor Red
        return
    }

    if (Test-Path $targetPath) {
        Backup-ConfigFile -FilePath $targetPath
        Remove-Item -Path $targetPath -Force -Recurse -Confirm:$false
    }
    else {
        $targetDir = Split-Path -Parent $targetPath
        New-Directory -Path $targetDir
    }

    try {
        New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
        Write-Host "Created symbolic link: $targetPath -> $sourcePath" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create symbolic link. Skipping." -ForegroundColor Red
    }
}

function Copy-SSHKeyToWSL {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Distribution,

        [Parameter(Mandatory = $true)]
        [string]$Username
    )

    if (!(Test-Path "$env:USERPROFILE\.ssh\id_rsa.pub")) {
        Write-Host "SSH public key not found at $env:USERPROFILE\.ssh\id_rsa.pub" -ForegroundColor Red
        return $false
    }

    Write-Host "Copying SSH key to $Distribution for user $Username..." -ForegroundColor Cyan

    $pubKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
    wsl -d $Distribution -u root bash -c "mkdir -p /home/$Username/.ssh && chmod 700 /home/$Username/.ssh"
    wsl -d $Distribution -u root bash -c "grep -q $pubKey /home/$Username/.ssh/authorized_keys || echo '$pubKey' >> /home/$Username/.ssh/authorized_keys"
    wsl -d $Distribution -u root bash -c "chmod 600 /home/$Username/.ssh/authorized_keys"
    wsl -d $Distribution -u root bash -c "chown -R ${Username}:${Username} /home/$Username/.ssh"

    Write-Host "SSH key copied successfully to $Distribution" -ForegroundColor Green
}

function Update-Windows {
    Write-Host "Checking for Windows updates..." -ForegroundColor Cyan

    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser

        Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Cyan
        $originalPolicy = Get-ExecutionPolicy -Scope CurrentUser
        try {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
            Write-Host "PSWindowsUpdate module installed successfully!" -ForegroundColor Green
        }
        finally {
            Set-ExecutionPolicy -ExecutionPolicy $originalPolicy -Scope CurrentUser -Force
        }
    }

    Import-Module PSWindowsUpdate

    $updates = Get-WindowsUpdate

    if ($updates.Count -eq 0) {
        Write-Host "No Windows updates available. System is up to date." -ForegroundColor Green
        return
    }

    Write-Host "Found $($updates.Count) Windows updates available." -ForegroundColor Yellow

    $rebootRequired = $updates | Where-Object { $_.RebootRequired -eq $true }

    if (!$rebootRequired) {
        Write-Host "Installing Windows updates. This may take some time..." -ForegroundColor Cyan
        Install-WindowsUpdate -AcceptAll -AutoReboot:$false
        Write-Host "Windows updates installed successfully!" -ForegroundColor Green
        return
    }

    Write-Host "Some updates require a system reboot." -ForegroundColor Yellow
    $rebootChoice = Read-Host "Would you like to: (1) Install updates and reboot now, (2) Install updates that don't require reboot, or (3) Skip updates?"

    switch ($rebootChoice) {
        "1" {
            Write-Host "Installing updates with automatic reboot..." -ForegroundColor Cyan
            Write-Host "Please run this script again manually after the system reboots." -ForegroundColor Yellow
            Install-WindowsUpdate -AcceptAll -AutoReboot
            Write-Host "Windows updates installed successfully! System will now reboot." -ForegroundColor Green
            exit 0
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

function Initialize-SSHKey {
    Write-Host "Initializing SSH key..." -ForegroundColor Cyan

    New-Directory -Path "$env:USERPROFILE\.ssh" | Out-Null

    if (Test-Path "$env:USERPROFILE\.ssh\id_rsa") {
        Write-Host "SSH key already exists." -ForegroundColor Yellow
        return
    }

    if (!(Test-CommandExists ssh-keygen)) {
        Write-Host "ssh-keygen not found. Please install OpenSSH client." -ForegroundColor Red
        return
    }

    Write-Host "Generating new SSH key..." -ForegroundColor Cyan
    ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'
    Write-Host "SSH key generated successfully!" -ForegroundColor Green
}

function Install-Chocolatey {
    if (Test-CommandExists choco) {
        Write-Host "Chocolatey is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan

    $originalPolicy = Get-ExecutionPolicy -Scope Process
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        # refreshenv is not available until after installation and shell restart, so we manually update the path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        if (Test-CommandExists choco) {
            Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "Chocolatey installation may have succeeded, but the command is not available in this session." -ForegroundColor Yellow
            Write-Host "You may need to restart your PowerShell session." -ForegroundColor Yellow
        }
    }
    finally {
        Set-ExecutionPolicy -ExecutionPolicy $originalPolicy -Scope Process -Force
    }
}

function Install-Scoop {
    if (Test-CommandExists scoop) {
        Write-Host "Scoop is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Scoop..." -ForegroundColor Cyan

    $originalPolicy = Get-ExecutionPolicy -Scope Process
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

        if (Test-CommandExists scoop) {
            Write-Host "Scoop installed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "Scoop installation may have succeeded, but the command is not available in this session." -ForegroundColor Yellow
            Write-Host "You may need to restart your PowerShell session." -ForegroundColor Yellow
        }
    }
    finally {
        Set-ExecutionPolicy -ExecutionPolicy $originalPolicy -Scope Process -Force
    }
}

function Install-VSCode {
    if ((Test-CommandExists code)) {
        Write-Host "Visual Studio Code is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Visual Studio Code..." -ForegroundColor Cyan
    winget install --id Microsoft.VisualStudioCode -e
    Write-Host "Visual Studio Code installed successfully!" -ForegroundColor Green
}

function Install-Git {
    if ((Test-CommandExists git)) {
        Write-Host "Git is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Git..." -ForegroundColor Cyan
    winget install --id Git.Git -e

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-CommandExists git) {
        Write-Host "Git installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Git installation completed, but git command not found in PATH." -ForegroundColor Yellow
        Write-Host "You may need to restart your PowerShell session." -ForegroundColor Yellow
    }
}

function Install-DevTools {
    Write-Host "Installing development tools..." -ForegroundColor Cyan

    if (!(Test-CommandExists nu)) {
        Write-Host "Installing Nushell via winget..." -ForegroundColor Cyan
        winget install --id Nushell.Nushell -e

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        if (Test-CommandExists nu) {
            Write-Host "Nushell installed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "Failed to install Nushell. Please check your installation." -ForegroundColor Red
            return
        }
    }
    else {
        Write-Host "Nushell is already installed." -ForegroundColor Yellow
    }

    if (!(Test-Path "C:\Program Files\7-Zip\7z.exe")) {
        Write-Host "Installing 7-Zip..." -ForegroundColor Cyan
        winget install --id 7zip.7zip -e
        Write-Host "7-Zip installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "7-Zip is already installed." -ForegroundColor Yellow
    }

    if (!(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe") -and
        !(Test-Path "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe")) {
        Write-Host "Installing Firefox..." -ForegroundColor Cyan
        winget install --id Mozilla.Firefox -e
        Write-Host "Firefox installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Firefox is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists wezterm)) {
        Write-Host "Installing WezTerm..." -ForegroundColor Cyan
        winget install --id wez.wezterm -e
        Write-Host "WezTerm installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "WezTerm is already installed." -ForegroundColor Yellow
    }

    if (!(Test-Path "C:\Program Files\Docker\Docker\Docker Desktop.exe")) {
        Write-Host "Installing Docker Desktop..." -ForegroundColor Cyan
        winget install --id Docker.DockerDesktop -e
        Write-Host "Docker Desktop installed successfully!" -ForegroundColor Green
        Write-Host "Make sure to enable the required WSL distro in Docker Desktop settings." -ForegroundColor Yellow
    }
    else {
        Write-Host "Docker Desktop is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists rg)) {
        Write-Host "Installing ripgrep..." -ForegroundColor Cyan
        winget install --id BurntSushi.ripgrep -e
        Write-Host "ripgrep installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "ripgrep is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists fzf)) {
        Write-Host "Installing fzf..." -ForegroundColor Cyan
        winget install --id junegunn.fzf -e
        Write-Host "fzf installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "fzf is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists fd)) {
        Write-Host "Installing fd..." -ForegroundColor Cyan
        winget install --id sharkdp.fd -e
        Write-Host "fd installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "fd is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists bat)) {
        Write-Host "Installing bat..." -ForegroundColor Cyan
        winget install --id sharkdp.bat -e
        Write-Host "bat installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "bat is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists gh)) {
        Write-Host "Installing gh..." -ForegroundColor Cyan
        winget install --id GitHub.cli -e
        Write-Host "gh installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "gh is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists delta)) {
        Write-Host "Installing delta..." -ForegroundColor Cyan
        winget install --id dandavison.delta -e
        Write-Host "delta installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "delta is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists uv)) {
        Write-Host "Installing uv..." -ForegroundColor Cyan
        winget install --id astral-sh.uv -e
        Write-Host "uv installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "uv is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists lazygit)) {
        Write-Host "Installing lazygit..." -ForegroundColor Cyan
        winget install --id jesseduffield.lazygit -e
        Write-Host "lazygit installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "lazygit is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists lazydocker)) {
        Write-Host "Installing lazydocker..." -ForegroundColor Cyan
        winget install --id jesseduffield.lazydocker -e
        Write-Host "lazydocker installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "lazydocker is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists nvim)) {
        Write-Host "Installing neovim..." -ForegroundColor Cyan
        winget install --id Neovim.Neovim -e
        Write-Host "neovim installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "neovim is already installed." -ForegroundColor Yellow
    }

    if (!(Test-Path "C:\Program Files\GNU Emacs")) {
        Write-Host "Installing emacs..." -ForegroundColor Cyan
        winget install GNU.Emacs
        Write-Host "emacs installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "emacs is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists starship)) {

        Write-Host "Setting up Starship prompt..." -ForegroundColor Cyan
        winget install --id Starship.Starship
        Write-Host "Starship prompt installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Starship is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists zoxide)) {
        Write-Host "Installing zoxide..." -ForegroundColor Cyan
        winget install --id ajeetdsouza.zoxide -e
        Write-Host "zoxide installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "zoxide is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists carapace)) {
        Write-Host "Installing carapace..." -ForegroundColor Cyan
        winget install --id rsteube.Carapace -e
        Write-Host "carapace installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "carapace is already installed." -ForegroundColor Yellow
    }

    Write-Host "Development tools installed!" -ForegroundColor Green
}

function Install-CppTools {
    Write-Host "Installing C++ development tools..." -ForegroundColor Cyan

    if (!(Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2022")) {
        Write-Host "Installing Visual Studio Build Tools..." -ForegroundColor Cyan
        winget install Microsoft.VisualStudio.2022.BuildTools --silent --override "--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
        Write-Host "Visual Studio Build Tools installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Visual Studio Build Tools already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists cmake)) {
        Write-Host "Installing CMake..." -ForegroundColor Cyan
        winget install Kitware.CMake
        Write-Host "CMake installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "CMake is already installed." -ForegroundColor Yellow
    }

    if (!(Test-CommandExists clang)) {
        Write-Host "Installing LLVM/Clang..." -ForegroundColor Cyan
        winget install LLVM.LLVM
        Write-Host "LLVM/Clang installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "LLVM/Clang is already installed." -ForegroundColor Yellow
    }

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

function Install-Apps {

    if (!(Test-CommandExists glazewm)) {
        Write-Host "Installing glazewm..." -ForegroundColor Cyan
        winget install --id glazewm.glazewm -e
        Write-Host "glazewm installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "glazewm is already installed." -ForegroundColor Yellow
    }

    if (!(Test-Path "C:\Users\Pervez Iqbal\AppData\Roaming\Telegram Desktop")) {
        Write-Host "Installing telegram..." -ForegroundColor Cyan
        winget install --id Telegram.TelegramDesktop -e
        Write-Host "telegram installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "telegram is already installed." -ForegroundColor Yellow
    }

    if (!(Test-Path "C:\Program Files\Zoom\bin\Zoom.exe")) {
        Write-Host "Installing zoom..." -ForegroundColor Cyan
        winget install --id Zoom.Zoom -e
        Write-Host "zoom installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "zoom is already installed." -ForegroundColor Yellow
    }

    if (Test-Path "$env:LOCALAPPDATA\Programs\signal-desktop\Signal.exe") {
        Write-Host "Signal is already installed." -ForegroundColor Yellow
    }
    else {
        Write-Host "Signal is not installed. Installing..." -ForegroundColor Cyan
        winget install --id OpenWhisperSystems.Signal -e
        Write-Host "Signal installed successfully!" -ForegroundColor Green
    }
}

function Install-Multipass {
    Write-Host "Installing Multipass..." -ForegroundColor Cyan

    if (Test-CommandExists multipass) {
        Write-Host "Multipass is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Installing Multipass via winget..." -ForegroundColor Cyan
    winget install --id Canonical.Multipass -e

    Write-Host "Multipass installed successfully!" -ForegroundColor Green
    Write-Host "A system restart is required before using Multipass." -ForegroundColor Yellow

    Restart-PC
}

function Install-MultipassVM {
    Write-Host "Setting up Ubuntu 24.10 VM in Multipass..." -ForegroundColor Cyan

    if (multipass list | Select-String "ubuntu-ilm") {
        Write-Host "Ubuntu VM 'ubuntu-ilm' already exists. Skipping..." -ForegroundColor Yellow
        return
    }

    multipass find | Out-Null

    Start-Sleep -Seconds 5

    Write-Host "Creating Ubuntu 24.10 VM with 8GB RAM and 20GB disk..." -ForegroundColor Cyan
    multipass launch oracular --name ubuntu-ilm --memory 8G --disk 20G

    Start-Sleep -Seconds 5

    Write-Host "Running shell installer script..." -ForegroundColor Cyan
    multipass exec ubuntu-ilm -- bash -c "curl -sSL https://dub.sh/aPKPT8V | bash -s -- shell"

    Write-Host "Ubuntu 24.10 VM setup complete!" -ForegroundColor Green
    multipass info ubuntu-ilm

    Write-Host "To access your VM, use: multipass shell ubuntu-ilm" -ForegroundColor Cyan
}

function Install-SSHServerInMutlipassVM {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName
    )

    Write-Host "Configuring SSH server on $VMName..." -ForegroundColor Cyan

    # Ensure SSH server is installed and configured in the VM
    multipass exec $VMName -- bash -c "sudo apt update && sudo apt install -y openssh-server"
    multipass exec $VMName -- bash -c "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config"
    # multipass exec $VMName -- bash -c "sudo sed -i 's/#UseLogin no/UseLogin yes/' /etc/ssh/sshd_config"
    # multipass exec $VMName -- bash -c "echo 'PermitUserEnvironment yes' | sudo tee -a /etc/ssh/sshd_config"

    # Restart SSH service to apply changes
    multipass exec $VMName -- bash -c "sudo systemctl restart ssh"

    Write-Host "SSH server configured successfully on $VMName" -ForegroundColor Green
}

function Copy-SSHKeyToMultipassVM {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName
    )

    Write-Host "Copying SSH key to $VMName..." -ForegroundColor Cyan

    try {
        $pubKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" -ErrorAction Stop
        multipass exec $VMName -- bash -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
        multipass exec $VMName -- bash -c "echo '$pubKey' >> ~/.ssh/authorized_keys"
        multipass exec $VMName -- bash -c "chmod 600 ~/.ssh/authorized_keys"
    }
    catch {
        Write-Host "Failed to copy SSH key: $_" -ForegroundColor Red
        return $false
    }

    Write-Host "SSH key copied successfully to $VMName" -ForegroundColor Green
}

function Initialize-MultipassVMSSH {
    param (
        [string]$VMName = "ubuntu-ilm"
    )

    Write-Host "Setting up SSH access to Multipass VM '$VMName'..." -ForegroundColor Cyan

    multipass info $VMName 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "VM '$VMName' does not exist. Please create it first." -ForegroundColor Red
        return
    }

    Install-SSHServerInMutlipassVM -VMName $VMName
    Copy-SSHKeyToMultipassVM -VMName $VMName

    Write-Host "SSH access to Multipass VM '$VMName' has been set up." -ForegroundColor Green
    Write-Host "You can now connect using: ssh $VMName" -ForegroundColor Cyan
}


function Install-HyperV-WSL {
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    $restartNeeded = $false

    if ($wslFeature.State -ne "Enabled") {
        Write-Host "WSL is not installed. Installing now..." -ForegroundColor Cyan

        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop

        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

        wsl --install --no-distribution

        $restartNeeded = $true
    }
    else {
        Write-Host "WSL is already installed." -ForegroundColor Yellow
        Write-Host "Updating WSL..." -ForegroundColor Cyan
        $result = wsl --update
        if ($result -and $result.RestartNeeded) {
            Write-Host "WSL update requires a restart." -ForegroundColor Red
            $restartNeeded = $true
        }
    }

    $features = @(
        "Microsoft-Hyper-V-All",
        "Containers",
        "HypervisorPlatform"
    )

    Write-Host "Enabling Hyper-V and WSL features..." -ForegroundColor Cyan

    foreach ($feature in $features) {
        $featureStatus = Get-WindowsOptionalFeature -Online -FeatureName $feature
        if ($featureStatus.State -ne "Enabled") {
            Write-Host "Enabling $feature..." -ForegroundColor Yellow
            $result = Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue

            if ($result -and $result.RestartNeeded) {
                Write-Host "$feature requires a restart." -ForegroundColor Red
                $restartNeeded = $true
            }
        }
        else {
            Write-Host "$feature is already enabled." -ForegroundColor Green
        }
    }

    if ($restartNeeded) {
        Restart-PC
    }
    else {
        Write-Host "All features enabled successfully." -ForegroundColor Green
    }
}

function Install-WSLDistro {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DistroName
    )

    if (!(Test-CommandExists wsl)) {
        Write-Host "WSL is not installed. Please install WSL first." -ForegroundColor Red
        return
    }

    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains $DistroName) {
        Write-Host "$DistroName is already installed." -ForegroundColor Yellow
        return
    }

    try {
        Write-Host "Installing $DistroName..." -ForegroundColor Cyan
        wsl --install -d $DistroName
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$DistroName installed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "$DistroName installation failed. It may not be available." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "$DistroName not found in available distributions. Skipping..." -ForegroundColor Yellow
    }
}

function Initialize-CentOSWSL {
    Write-Host "Setting up CentOS Stream 10..." -ForegroundColor Cyan

    $username = Read-Host "Enter username for CentOS"
    $password = Read-Host "Enter password for $username" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    try {
        Write-Host "Running setup script in CentOS Stream 10..." -ForegroundColor Cyan
        wsl -d CentOS-Stream-10 -u root -- bash -c "curl -sSL $global:GitHubBaseUrl/windows/setup-centos.sh | bash -s -- '$username' '$passwordText'"
    }
    finally {
        $passwordText = $null
        [System.GC]::Collect()
    }

    Write-Host "CentOS Stream 10 setup complete!" -ForegroundColor Green
    Write-Host "To access your CentOS environment, use: wsl -d CentOS-Stream-10" -ForegroundColor Cyan
}

function Install-NixOSWSL {
    Write-Host "Installing NixOS on WSL..." -ForegroundColor Cyan

    if (!(Test-CommandExists wsl)) {
        Write-Host "WSL command does not exist. Please install WSL first." -ForegroundColor Red
        return
    }

    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains "NixOS") {
        Write-Host "NixOS is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Downloading NixOS WSL image (this may take time)..." -ForegroundColor Cyan

    $tempDir = "$env:TEMP"
    $wslFile = "$tempDir\nixos.wsl"
    $downloadUrl = "https://github.com/nix-community/NixOS-WSL/releases/download/2411.6.0/nixos.wsl"

    $ProgressPreference = 'SilentlyContinue'
    try {
        if (Test-Path $wslFile) {
            Write-Host "NixOS WSL image already downloaded." -ForegroundColor Cyan
        }
        else {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $wslFile -UseBasicParsing
            Write-Host "Download completed successfully!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        Write-Host "You can try downloading the file manually from:" -ForegroundColor Yellow
        Write-Host $downloadUrl -ForegroundColor Yellow
        Write-Host "Then place it at: $wslFile" -ForegroundColor Yellow
        return
    }
    $ProgressPreference = 'Continue'

    Write-Host "Installing NixOS from .wsl file..." -ForegroundColor Cyan
    wsl --install --from-file $wslFile

    if ($LASTEXITCODE -ne 0) {
        Write-Host "NixOS installation failed." -ForegroundColor Red
        return
    }

    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item -Path $wslFile -Force

    Write-Host "Updating NixOS to the latest version..." -ForegroundColor Cyan
    wsl -d NixOS -u root -- bash -c "nix-channel --update && nixos-rebuild switch"

    Write-Host "NixOS installed successfully!" -ForegroundColor Green
    Write-Host "To start NixOS, open a terminal and type: wsl -d NixOS" -ForegroundColor Cyan

    Write-Host "Running shell setup script..." -ForegroundColor Cyan
    wsl -d NixOS -u root -- bash -c 'bash -c "$(curl -sSL https://dub.sh/aPKPT8V 2>/dev/null || wget -qO- https://dub.sh/aPKPT8V 2>/dev/null)" -- shell'

    Write-Host "nixos setup completed!" -ForegroundColor Green
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

function Set-CapsLockAsControl {
    Write-Host "Remapping Caps Lock to Control key..." -ForegroundColor Cyan

    $regFilePath = "$global:WinDir\caps2ctrl.reg"

    if (Test-Path $regFilePath) {
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s", "`"$regFilePath`"" -Wait
        Write-Host "Caps Lock remapped to Control key. A system restart is required." -ForegroundColor Green
    }
    else {
        Write-Host "Registry file not found at: $regFilePath" -ForegroundColor Red
    }
}

function Install-VSCodeExtensions {
    Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan

    $extensionsFile = "$global:DotDir\extras\vscode\extensions\wsl"

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

function Install-NerdFontsWithScoop {
    Write-Host "Installing Nerd Fonts..." -ForegroundColor Cyan

    if (-not (Test-CommandExists scoop)) {
        Write-Host "Installing Scoop package manager..." -ForegroundColor Cyan
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    scoop bucket add nerd-fonts

    scoop install nerd-fonts/JetBrainsMono-NF
    scoop install nerd-fonts/CascadiaCode-NF

    Write-Host "Nerd Fonts installed successfully!" -ForegroundColor Green
}

function Install-NerdFonts {
    if (-not (Test-CommandExists choco)) {
        Write-Host "Chocolatey is not installed. Cannot install Nerd Fonts." -ForegroundColor Red
        return
    }

    Write-Host "Installing Nerd Fonts ..." -ForegroundColor Cyan
    choco install nerd-fonts-JetBrainsMono -y
    Write-Host "Nerd Fonts installation completed!" -ForegroundColor Green
}

function Get-Dotfiles {
    Install-Git

    if (!(Test-CommandExists git)) {
        Write-Host "Git is not installed. Cannot clone dotfiles." -ForegroundColor Red
        return
    }

    if (Test-Path "$global:DotDir") {
        Write-Host "Dotfiles already present. Updating..." -ForegroundColor Cyan

        if ($null -eq (git status --porcelain)) {
            Set-Location "$global:DotDir"
            git pull --rebase
        }

        Write-Host "Dotfiles updated successfully!" -ForegroundColor Green
        return $true
    }

    Write-Host "Cloning dotfiles..." -ForegroundColor Cyan
    git clone https://github.com/pervezfunctor/dotfiles.git "$global:DotDir"

    if ($LASTEXITCODE -ne 0 -or !(Test-Path "$global:DotDir")) {
        Write-Host "Failed to clone dotfiles. Exiting..." -ForegroundColor Red
        return $false
    }

    Write-Host "Dotfiles cloned successfully!" -ForegroundColor Green
    return $true
}

function Install-PowerShellModules {
    Write-Host "Installing essential PowerShell modules..." -ForegroundColor Cyan

    $modules = @(
        "PSReadLine",
        "posh-git",
        "Terminal-Icons"
    )

    foreach ($module in $modules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing $module for Windows PowerShell..." -ForegroundColor Yellow
            Install-Module -Name $module -Scope CurrentUser -Force -SkipPublisherCheck
        }
    }

    if (Test-CommandExists pwsh) {
        foreach ($module in $modules) {
            Write-Host "Installing $module for PowerShell 7..." -ForegroundColor Yellow
            pwsh -Command "if (!(Get-Module -ListAvailable -Name $module)) { Install-Module -Name $module -Scope CurrentUser -Force }"
        }
    }
    else {
        Write-Host "PowerShell 7 not found. Skipping module installation for PowerShell 7." -ForegroundColor Yellow
        Write-Host "Consider installing PowerShell 7 for better features and performance." -ForegroundColor Yellow
    }

    Write-Host "PowerShell modules installed successfully!" -ForegroundColor Green
}

function Initialize-PowerShell {
    Write-Host "Setting up PowerShell profiles for both Windows PowerShell and PowerShell 7..." -ForegroundColor Cyan

    $ps5ProfilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    $ps7ProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"


    Backup-ConfigFile -FilePath $ps5ProfilePath
    Backup-ConfigFile -FilePath $ps7ProfilePath


    $sourceProfilePath = "$global:DotDir\powershell\Microsoft.PowerShell_profile.ps1"

    if (Test-Path $sourceProfilePath) {
        New-ConfigLink -sourcePath $sourceProfilePath -targetPath $ps5ProfilePath
        New-ConfigLink -sourcePath $sourceProfilePath -targetPath $ps7ProfilePath

        Write-Host "PowerShell profiles configured for both PowerShell 5.x and 7.x" -ForegroundColor Green
    }
    else {
        Write-Host "Source PowerShell profile not found at: $sourceProfilePath" -ForegroundColor Red
    }

    Install-PowerShellModules
}

function Initialize-Dotfiles {
    if (!Get-Dotfiles) {
        Write-Host "Failed to clone dotfiles. Exiting..." -ForegroundColor Red
        return
    }

    Write-Host "Setting up WezTerm config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath "$global:DotDir\wezterm\dot-config\wezterm" -targetPath "$env:USERPROFILE\.config\wezterm"

    Write-Host "Setting up Neovim config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath "$global:DotDir\nvim\dot-config\nvim" -targetPath "$env:LOCALAPPDATA\nvim"

    Write-Host "Setting up Emacs config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath "$global:DotDir\emacs-slim\dot-emacs" -targetPath "$env:USERPROFILE\.emacs"

    Write-Host "Setting up Nushell config..." -ForegroundColor Cyan
    $null = Backup-ConfigFile -FilePath "$env:APPDATA\nushell"
    New-ConfigLink -sourcePath "$global:DotDir\nushell\dot-config\nushell" -targetPath "$env:APPDATA\nushell"

    Write-Host "Setting up PowerShell config..." -ForegroundColor Cyan
    $psConfigFile = "$global:DotDir\powershell\Microsoft.PowerShell_profile.ps1"
    $psProfilePath = $PROFILE
    $null = New-ConfigDirectory -ConfigPath $psProfilePath

    $originalUserPolicy = Get-ExecutionPolicy -Scope CurrentUser
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "PowerShell execution policy set to RemoteSigned for current user" -ForegroundColor Green
        New-ConfigLink -sourcePath $psConfigFile -targetPath $psProfilePath
        Write-Host "PowerShell profile linked successfully. You may need to restart PowerShell." -ForegroundColor Green
    }
    finally {
        Set-ExecutionPolicy -ExecutionPolicy $originalUserPolicy -Scope CurrentUser -Force
    }

    Write-Host "Setting up VS Code config..." -ForegroundColor Cyan
    $vscodeSettingsSource = "$global:DotDir\extras\vscode\wsl-settings.json"
    $vscodeSettingsTarget = "$env:APPDATA\Code\User\settings.json"

    if (Test-Path $vscodeSettingsSource) {
        $null = Backup-ConfigFile -FilePath $vscodeSettingsTarget
        $null = New-ConfigDirectory -ConfigPath $vscodeSettingsTarget
        Copy-Item -Path $vscodeSettingsSource -Destination $vscodeSettingsTarget -Force
        Write-Host "VS Code settings copied successfully" -ForegroundColor Green
    }
    else {
        Write-Host "VS Code settings source file not found at: $vscodeSettingsSource" -ForegroundColor Red
    }
}

function Initialize-NushellProfile {
    $wtConfigPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"

    if (!(Test-Path $wtConfigPath)) {
        Write-Host "Windows Terminal settings file not found at: $wtConfigPath" -ForegroundColor Red
        return $false
    }

    Write-Host "Adding Nushell to Windows Terminal profiles..." -ForegroundColor Cyan

    try {
        $wtConfig = Get-Content -Path $wtConfigPath -Raw | ConvertFrom-Json

        $nuProfile = $wtConfig.profiles.list | Where-Object { $_.commandline -like "*nu.exe*" }

        if ($nuProfile) {
            Write-Host "Nushell profile already exists in Windows Terminal." -ForegroundColor Yellow
            return $true
        }

        $nuProfileObj = [PSCustomObject]@{
            name              = "Nushell"
            commandline       = "nu.exe"
            icon              = "$env:USERPROFILE\AppData\Local\Programs\Nushell\nu.ico"
            startingDirectory = "%USERPROFILE%"
            guid              = [guid]::NewGuid().ToString()
        }

        $wtConfig.profiles.list += $nuProfileObj

        $wtConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $wtConfigPath
        Write-Host "Nushell profile added to Windows Terminal!" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "Failed to update Windows Terminal settings: $_" -ForegroundColor Red
        return $false
    }
}

function Set-NushellProfileAsDefault {
    $wtConfigPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"

    if (!(Test-Path $wtConfigPath)) {
        Write-Host "Windows Terminal settings file not found at: $wtConfigPath" -ForegroundColor Red
        return $false
    }

    $setAsDefault = Read-Host "Would you like to set Nushell as your default shell in Windows Terminal? (y/n)"
    if ($setAsDefault -ne 'y') {
        Write-Host "Skipping setting Nushell as default shell." -ForegroundColor Yellow
        return $true
    }

    try {
        $wtConfig = Get-Content -Path $wtConfigPath -Raw | ConvertFrom-Json
        $nuProfile = $wtConfig.profiles.list | Where-Object { $_.commandline -like "*nu.exe*" }

        if ($null -eq $nuProfile) {
            Write-Host "Nushell profile not found in Windows Terminal." -ForegroundColor Red
            return $false
        }

        $wtConfig.defaultProfile = $nuProfile.guid
        $wtConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $wtConfigPath
        Write-Host "Nushell set as default shell in Windows Terminal!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to set Nushell as default: $_" -ForegroundColor Red
        return $false
    }
}

function Copy-ConfigFromDotfiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    Write-Host "Setting up ${TargetPath} from dotfiles..." -ForegroundColor Cyan

    if (!(Test-Path $SourcePath)) {
        Write-Host "Source path $SourcePath does not exist. Skipping..." -ForegroundColor Yellow
        return $false
    }

    if (!(New-ConfigDirectory -ConfigPath $TargetPath)) {
        Write-Host "Failed to create ${TargetPath} config directory. Skipping..." -ForegroundColor Yellow
        return $false
    }

    Backup-ConfigFile -FilePath $TargetPath

    try {
        Copy-Item -Path $SourcePath -Destination $TargetPath -Force
        Write-Host "Applied ${TargetPath} configuration successfully from ${SourcePath}" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to copy or apply ${TargetPath} configuration: $_" -ForegroundColor Red
        return $false
    }

    Write-Host "${TargetPath} setup completed" -ForegroundColor Green
    return $true
}

# Define available components with preserved order
$availableComponents = [ordered]@{
    "windows-update" = "Update Windows"
    "wsl"            = "Install Hyper-V and WSL"
    "multipass"      = "Install Multipass"

    "nerd-fonts"     = "Install Nerd Fonts"
    "capslock"       = "Set CapsLock as Control"
    "vscode"         = "Install VS Code"
    "devtools"       = "Install Development Tools"
    "dotfiles"       = "Initialize Dotfiles"
    "apps"           = "Install Applications"

    "multipass-vm"   = "Install Multipass VM"
    "wsl-ubuntu"     = "Install Ubuntu WSL"
    "wsl-debian"     = "Install Debian WSL"
    "wsl-opensuse"   = "Install openSUSE WSL"
    "wsl-centos"     = "Install CentOS WSL"
    "wsl-nixos"      = "Install NixOS WSL"
    # "scoop"          = "Install Scoop"
    "all"            = "Install All Components"
}

function Debug-Variable {
    param(
        [string]$Name,
        [object]$Value
    )
    Write-Host "DEBUG: $Name = $($Value | ConvertTo-Json -Compress)" -ForegroundColor Magenta
}

function Show-Menu {
    param (
        [string]$Title = "Select components to install",
        [string[]]$PreSelected = @()
    )

    Write-Host "`n$Title" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan

    $menuItems = [ordered]@{}
    $selectedItems = [ordered]@{}
    $index = 1

    foreach ($key in $availableComponents.Keys | Where-Object { $_ -ne "all" }) {
        $menuItems[$index.ToString()] = $key
        $isSelected = $false

        if ($PreSelected -contains $key) {
            $isSelected = $true
            Write-Host "Preselecting item: $key" -ForegroundColor Magenta
        }

        $selectedItems[$index.ToString()] = $isSelected
        $index++
    }

    $done = $false
    while (-not $done) {
        Clear-Host
        Write-Host "`n$Title" -ForegroundColor Cyan
        Write-Host "=======================================" -ForegroundColor Cyan

        for ($i = 1; $i -le $menuItems.Count; $i++) {
            $key = $menuItems[$i.ToString()]
            $selected = $selectedItems[$i.ToString()]
            $marker = if ($selected) { "[X]" } else { "[ ]" }
            Write-Host "$marker [$i] $($availableComponents[$key])" -ForegroundColor $(if ($selected) { "Green" } else { "Yellow" })
        }

        Write-Host "`nCommands:" -ForegroundColor Cyan
        Write-Host "  number(s) - Toggle selection (comma/space separated)" -ForegroundColor Gray
        Write-Host "  a - Select all items" -ForegroundColor Gray
        Write-Host "  n - Deselect all items" -ForegroundColor Gray
        Write-Host "  d - Done, proceed with selected items" -ForegroundColor Gray
        Write-Host "  q - Quit without installing" -ForegroundColor Gray
        Write-Host "=======================================" -ForegroundColor Cyan

        $choice = Read-Host "Enter command"

        switch -Regex ($choice) {
            '^\d+(\s*[,]\s*\d+|\s+\d+)*$' {
                $numbers = $choice -split '[,\s]+' | Where-Object { $_ -match '^\d+$' }
                foreach ($num in $numbers) {
                    if ([int]$num -ge 1 -and [int]$num -le $menuItems.Count) {
                        $selectedItems[$num] = -not $selectedItems[$num]
                    }
                }
            }

            '^a$' {
                for ($i = 1; $i -le $menuItems.Count; $i++) {
                    $selectedItems[$i.ToString()] = $true
                }
            }

            '^n$' {
                for ($i = 1; $i -le $menuItems.Count; $i++) {
                    $selectedItems[$i.ToString()] = $false
                }
            }

            '^d$|^$' {
                $done = $true
            }

            '^q$' {
                return @()
            }
        }
    }

    $selections = @()
    for ($i = 1; $i -le $menuItems.Count; $i++) {
        if ($selectedItems[$i.ToString()]) {
            $selections += $menuItems[$i.ToString()]
        }
    }

    return $selections
}

function Install-SelectedComponents {
    param (
        [string[]]$ComponentList
    )

    if ($ComponentList -contains "all") {
        $ComponentList = $availableComponents.Keys | Where-Object { $_ -ne "all" }
    }

    foreach ($component in $ComponentList) {
        Write-Host "`nProcessing component: $component ($($availableComponents[$component]))" -ForegroundColor Cyan

        Initialize-SSHKey
        switch ($component) {
            "windows-update" { Update-Windows }
            "wsl" { Install-HyperV-WSL }
            "multipass" { Install-Multipass }

            "nerd-fonts" { Install-Chocolatey; Install-NerdFonts }
            "capslock" { Set-CapsLockAsControl }
            "devtools" { Install-Git; Install-DevTools; Install-CppTools; Install-PowerShell }
            "vscode" { Install-Git; Install-VSCode; Install-VSCodeExtensions }
            "dotfiles" { Install-Git ; Initialize-Dotfiles; Initialize-NushellProfile }
            "apps" { Install-Apps }

            "multipass-vm" { Install-MultipassVM; Initialize-MultipassVMSSH }
            "wsl-ubuntu" { Install-WSLDistro -DistroName "Ubuntu-24.04" }
            "wsl-debian" { Install-WSLDistro -DistroName "Debian" }
            "wsl-opensuse" { Install-WSLDistro -DistroName "openSUSE-Tumbleweed" }
            "wsl-centos" { Install-CentOSWSL; Initialize-CentOSWSL }
            "wsl-nixos" { Install-NixOSWSL }
            # "scoop" { Install-Scoop }
            default { Write-Host "Unknown component: $component" -ForegroundColor Red }
        }
    }

    Write-Host "`nSelected components installation complete!" -ForegroundColor Green
}

function Main {
    param (
        [switch]$ListComponents,
        [string[]]$Components = @()
    )

    if ($ListComponents) {
        Write-Host "Available components:" -ForegroundColor Cyan
        foreach ($key in $availableComponents.Keys | Sort-Object) {
            Write-Host "  $key - $($availableComponents[$key])" -ForegroundColor Yellow
        }
        return
    }

    if ($null -eq $Components -or $Components.Count -eq 0) {
        # Pass the Components array as PreSelected to Show-Menu
        Write-Host "Running in interactive mode with preselected components: $($Components -join ', ')" -ForegroundColor Cyan
        $selectedComponents = Show-Menu -PreSelected @("nerd-fonts", "vscode", "wsl", "wsl-ubuntu")
    }
    else {
        # Non-interactive mode, use provided components
        Write-Host "Running in non-interactive mode with components: $($Components -join ', ')" -ForegroundColor Cyan
        $selectedComponents = $Components
    }

    if ($selectedComponents.Count -eq 0) {
        Write-Host "No components selected. Exiting." -ForegroundColor Yellow
        return
    }

    Write-Host "Selected components: $($selectedComponents -join ', ')" -ForegroundColor Green
    Install-SelectedComponents -ComponentList $selectedComponents
}

if ($MyInvocation.InvocationName -ne ".") {
    Main @PSBoundParameters
}

# Restore original execution policy at the end of the script
if ($originalPolicy -ne "RemoteSigned" -and $originalPolicy -ne "Unrestricted") {
    Write-Host "Restoring original execution policy..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy $originalPolicy -Scope Process -Force
    Write-Host "Original execution policy restored." -ForegroundColor Green
}
