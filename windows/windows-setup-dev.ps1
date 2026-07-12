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

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = [Security.Principal.WindowsPrincipal]::new($currentIdentity)
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdministrator) {
    if ([string]::IsNullOrWhiteSpace($PSCommandPath)) {
        throw "Administrator privileges are required. Save the script to a file and run it again."
    }

    Write-Host "Administrator privileges are required. Requesting elevation..." -ForegroundColor Yellow
    $shellPath = (Get-Process -Id $PID).Path
    $escapedScriptPath = $PSCommandPath.Replace('"', '\"')
    $elevatedArguments = @(
        "-NoProfile"
        "-ExecutionPolicy", "Bypass"
        "-File", "`"$escapedScriptPath`""
    )
    if ($ListComponents) {
        $elevatedArguments += "-ListComponents"
    }
    if ($Components.Count -gt 0) {
        $elevatedArguments += "-Components"
        $elevatedArguments += $Components
    }

    try {
        $process = Start-Process -FilePath $shellPath -Verb RunAs -ArgumentList $elevatedArguments -PassThru -ErrorAction Stop
        $process.WaitForExit()
        exit $process.ExitCode
    }
    catch {
        throw "Unable to start the setup with administrator privileges: $_"
    }
}

# Set execution policy for the current process only
$originalPolicy = Get-ExecutionPolicy -Scope Process
if ($originalPolicy -ne "RemoteSigned" -and $originalPolicy -ne "Unrestricted") {
    Write-Host "Setting execution policy to RemoteSigned for current session..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
    Write-Host "Execution policy set to RemoteSigned for this session." -ForegroundColor Green
}

function New-SetupContext {
    return [pscustomobject]@{
        GitHubBaseUrl    = "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main"
        DotfilesDirectory = Join-Path $env:USERPROFILE ".ilm"
        UserProfile      = $env:USERPROFILE
        LocalAppData     = $env:LOCALAPPDATA
        RoamingAppData   = $env:APPDATA
    }
}

function Copy-Safe {
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (Test-Path -LiteralPath $Destination) {
        Write-Error "Destination already exists: $Destination"
        return
    }

    Copy-Item -LiteralPath $Source -Destination $Destination
}

function Copy-WithBackup {
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (Test-Path -LiteralPath $Destination) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmssfff'
        $backupPath = "$Destination.$timestamp.bak"
        Move-Item -LiteralPath $Destination -Destination $backupPath
    }

    Copy-Item -LiteralPath $Source -Destination $Destination
}

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
        Restart-Computer
    }

    Write-Host "Please restart your computer manually and run this script again to continue setup." -ForegroundColor Yellow
    exit 0
}

function New-SetupResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Installed", "AlreadyPresent", "Completed", "Skipped", "Failed")]
        [string]$Status,

        [string]$Message = "",
        [int]$ExitCode = 0,
        [bool]$RestartNeeded = $false
    )

    return [pscustomobject]@{
        PSTypeName    = "Dotfiles.SetupResult"
        Name          = $Name
        Status        = $Status
        Success       = $Status -ne "Failed"
        Message       = $Message
        ExitCode      = $ExitCode
        RestartNeeded = $RestartNeeded
    }
}

function Write-SetupResult {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Result
    )

    $color = switch ($Result.Status) {
        "Failed" { "Red" }
        "AlreadyPresent" { "Yellow" }
        "Skipped" { "Yellow" }
        default { "Green" }
    }

    $message = if ([string]::IsNullOrWhiteSpace($Result.Message)) {
        "$($Result.Name): $($Result.Status)"
    }
    else {
        $Result.Message
    }
    Write-Host $message -ForegroundColor $color
}

function Update-ProcessPath {
    $pathValues = @(
        $env:Path
        [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        [System.Environment]::GetEnvironmentVariable("Path", "User")
    )

    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $mergedPaths = foreach ($entry in ($pathValues -split ";")) {
        $trimmedEntry = $entry.Trim()
        if (![string]::IsNullOrWhiteSpace($trimmedEntry) -and $seen.Add($trimmedEntry)) {
            $trimmedEntry
        }
    }

    $env:Path = $mergedPaths -join ";"
}

function Test-WingetPackageInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId
    )

    & winget list --id $PackageId --exact --accept-source-agreements --disable-interactivity 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Install-WingetPackage {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageId,

        [string]$Name = $PackageId,
        [string]$Command,
        [string]$Override,
        [switch]$RestartNeeded
    )

    if (!(Test-CommandExists winget)) {
        $result = New-SetupResult -Name $Name -Status Failed -Message "winget is unavailable; cannot install $Name." -ExitCode 1
        Write-SetupResult $result
        return $result
    }

    if (Test-WingetPackageInstalled -PackageId $PackageId) {
        $result = New-SetupResult -Name $Name -Status AlreadyPresent -Message "$Name is already installed."
        Write-SetupResult $result
        return $result
    }

    Write-Host "Installing $Name..." -ForegroundColor Cyan
    $arguments = @(
        "install"
        "--id", $PackageId
        "--exact"
        "--accept-source-agreements"
        "--accept-package-agreements"
        "--silent"
        "--disable-interactivity"
    )

    if (![string]::IsNullOrWhiteSpace($Override)) {
        $arguments += "--override", $Override
    }

    & winget @arguments | Out-Host
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        $result = New-SetupResult -Name $Name -Status Failed -Message "Failed to install $Name (winget exit code $exitCode)." -ExitCode $exitCode
        Write-SetupResult $result
        return $result
    }

    Update-ProcessPath
    $message = "$Name installed successfully."
    if (![string]::IsNullOrWhiteSpace($Command) -and !(Test-CommandExists $Command)) {
        $message += " The '$Command' command will be available after restarting the shell."
    }

    $result = New-SetupResult -Name $Name -Status Installed -Message $message -RestartNeeded:$RestartNeeded
    Write-SetupResult $result
    return $result
}

function Install-WingetPackageSet {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Packages
    )

    $results = foreach ($package in $Packages) {
        $parameters = @{
            PackageId = $package.Id
            Name      = $package.Name
        }
        if ($package.Command) { $parameters.Command = $package.Command }
        if ($package.Override) { $parameters.Override = $package.Override }
        if ($package.RestartNeeded) { $parameters.RestartNeeded = $true }
        Install-WingetPackage @parameters
    }

    return @($results)
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

    if (!(Test-Path "$env:USERPROFILE\.ssh\id_ed25519.pub")) {
        Write-Host "SSH public key not found at $env:USERPROFILE\.ssh\id_ed25519.pub" -ForegroundColor Red
        return $false
    }

    Write-Host "Copying SSH key to $Distribution for user $Username..." -ForegroundColor Cyan

    $pubKey = (Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" -Raw).Trim()
    $encodedPubKey = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pubKey))
    wsl -d $Distribution -u root bash -c "mkdir -p /home/$Username/.ssh && chmod 700 /home/$Username/.ssh"
    wsl -d $Distribution -u root bash -c "touch /home/$Username/.ssh/authorized_keys; key=`$(printf '%s' '$encodedPubKey' | base64 -d); grep -Fqx -- `"`$key`" /home/$Username/.ssh/authorized_keys || printf '%s\n' `"`$key`" >> /home/$Username/.ssh/authorized_keys"
    wsl -d $Distribution -u root bash -c "chmod 600 /home/$Username/.ssh/authorized_keys"
    wsl -d $Distribution -u root bash -c "chown -R ${Username}:${Username} /home/$Username/.ssh"

    Write-Host "SSH key copied successfully to $Distribution" -ForegroundColor Green
}

function Update-Windows {
    Write-Host "Checking for Windows updates..." -ForegroundColor Cyan

    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser

        Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Cyan
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
        Write-Host "PSWindowsUpdate module installed successfully!" -ForegroundColor Green
    }

    Import-Module PSWindowsUpdate

    $updates = Get-WindowsUpdate

    if ($updates.Count -eq 0) {
        Write-Host "No Windows updates available. System is up to date." -ForegroundColor Green
        return
    }

    Write-Host "Found $($updates.Count) Windows updates available." -ForegroundColor Yellow

    $rebootRequired = $updates | Where-Object { $_.RebootRequired -eq $true }

    if (!($rebootRequired)) {
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
        Set-ExecutionPolicy RemoteSigned -Scope Process -Force
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
    return Winget-Install -PackageId "Microsoft.VisualStudioCode" -Name "Visual Studio Code" -Command "code"
}

function Install-Git {
    return Winget-Install -PackageId "Git.Git" -Name "Git" -Command "git"
}

function Install-Nushell {
    return Winget-Install -PackageId "Nushell.Nushell" -Name "Nushell" -Command "nu"
}

function Install-Starship {
    return Winget-Install -PackageId "Starship.Starship" -Name "Starship" -Command "starship"
}

function Install-Zoxide {
    return Winget-Install -PackageId "ajeetdsouza.zoxide" -Name "zoxide" -Command "zoxide"
}

function Install-Carapace {
    return Winget-Install -PackageId "rsteube.Carapace" -Name "Carapace" -Command "carapace"
}

function Install-DevTools {
    Write-Host "Installing development tools..." -ForegroundColor Cyan
    return Install-WingetPackageSet -Packages @(
        @{ Name = "PowerShell 7"; Id = "Microsoft.PowerShell"; Command = "pwsh" }
        @{ Name = "Starship"; Id = "Starship.Starship"; Command = "starship" }
        @{ Name = "Git"; Id = "Git.Git"; Command = "git" }
        @{ Name = "Nushell"; Id = "Nushell.Nushell"; Command = "nu" }
        @{ Name = "zoxide"; Id = "ajeetdsouza.zoxide"; Command = "zoxide" }
        @{ Name = "Carapace"; Id = "rsteube.Carapace"; Command = "carapace" }
        @{ Name = "7-Zip"; Id = "7zip.7zip"; Command = "7z" }
        @{ Name = "Firefox"; Id = "Mozilla.Firefox" }
        @{ Name = "WezTerm"; Id = "wez.wezterm"; Command = "wezterm" }
        @{ Name = "Docker Desktop"; Id = "Docker.DockerDesktop"; Command = "docker" }
        @{ Name = "ripgrep"; Id = "BurntSushi.ripgrep"; Command = "rg" }
        @{ Name = "fzf"; Id = "junegunn.fzf"; Command = "fzf" }
        @{ Name = "fd"; Id = "sharkdp.fd"; Command = "fd" }
        @{ Name = "bat"; Id = "sharkdp.bat"; Command = "bat" }
        @{ Name = "eza"; Id = "eza-community.eza"; Command = "eza" }
        @{ Name = "GitHub CLI"; Id = "GitHub.cli"; Command = "gh" }
        @{ Name = "delta"; Id = "dandavison.delta"; Command = "delta" }
        @{ Name = "uv"; Id = "astral-sh.uv"; Command = "uv" }
        @{ Name = "lazygit"; Id = "jesseduffield.lazygit"; Command = "lazygit" }
        @{ Name = "lazydocker"; Id = "jesseduffield.lazydocker"; Command = "lazydocker" }
        @{ Name = "Neovim"; Id = "Neovim.Neovim"; Command = "nvim" }
        @{ Name = "Emacs"; Id = "GNU.Emacs"; Command = "emacs" }
    )
}

function Install-CppTools {
    Write-Host "Installing C++ development tools..." -ForegroundColor Cyan
    return Install-WingetPackageSet -Packages @(
        @{
            Name = "Visual Studio Build Tools"
            Id = "Microsoft.VisualStudio.2022.BuildTools"
            Override = "--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
        }
        @{ Name = "CMake"; Id = "Kitware.CMake"; Command = "cmake" }
        @{ Name = "LLVM/Clang"; Id = "LLVM.LLVM"; Command = "clang" }
        @{ Name = "Ninja"; Id = "Ninja-build.Ninja"; Command = "ninja" }
    )
}

function Install-Apps {
    return Install-WingetPackageSet -Packages @(
        @{ Name = "GlazeWM"; Id = "glazewm.glazewm"; Command = "glazewm" }
        @{ Name = "Telegram"; Id = "Telegram.TelegramDesktop" }
        @{ Name = "Zoom"; Id = "Zoom.Zoom" }
        @{ Name = "Signal"; Id = "OpenWhisperSystems.Signal" }
    )
}

function Install-AI-Tools {
    Write-Host "Installing AI tools..." -ForegroundColor Cyan
    return Install-WingetPackageSet -Packages @(
        @{ Name = "Codex CLI"; Id = "OpenAI.Codex"; Command = "codex" }
        @{ Name = "OpenCode"; Id = "SST.opencode"; Command = "opencode" }
        @{ Name = "Claude"; Id = "Anthropic.Claude" }
        @{ Name = "Claude Code"; Id = "Anthropic.ClaudeCode"; Command = "claude" }
        @{ Name = "Claude"; Id = "ZhipuAI.ZCode"; }
    )
}

function Install-Multipass {
    $result = Install-WingetPackage -PackageId "Canonical.Multipass" -Name "Multipass" -Command "multipass" -RestartNeeded
    if ($result.Success -and $result.Status -eq "Installed") {
        Restart-PC
    }
    return $result
}

function Install-MultipassVM {
    if (!(Test-CommandExists multipass)) {
        Write-Host "Multipass is not installed. Please install Multipass first." -ForegroundColor Red
        return
    }

    Write-Host "Setting up Ubuntu 26.04 VM in Multipass..." -ForegroundColor Cyan

    if (multipass list | Select-String "ubuntu-ilm") {
        Write-Host "Ubuntu VM 'ubuntu-ilm' already exists. Skipping..." -ForegroundColor Yellow
        return
    }

    multipass find | Out-Null

    Start-Sleep -Seconds 5

    Write-Host "Creating Ubuntu 26.04 VM with 8GB RAM and 20GB disk..." -ForegroundColor Cyan
    multipass launch resolute --name ubuntu-ilm --memory 8G --disk 20G

    Start-Sleep -Seconds 5

    Write-Host "Running shell installer script..." -ForegroundColor Cyan
    multipass exec ubuntu-ilm -- bash -c "curl -sSL https://is.gd/egitif | bash -s -- min"

    Write-Host "Ubuntu 26.04 VM setup complete!" -ForegroundColor Green
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
        $pubKey = Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" -ErrorAction Stop
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

    if (!(Test-CommandExists multipass)) {
        Write-Host "Multipass is not installed. Please install Multipass first." -ForegroundColor Red
        return
    }

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
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    Write-Host "Setting up CentOS Stream 10..." -ForegroundColor Cyan

    $username = Read-Host "Enter username for CentOS"
    $password = Read-Host "Enter password for $username" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    try {
        Write-Host "Running setup script in CentOS Stream 10..." -ForegroundColor Cyan
        wsl -d CentOS-Stream-10 -u root -- bash -c "curl -sSL $($Context.GitHubBaseUrl)/windows/setup-centos.sh | bash -s -- '$username' '$passwordText'"
    }
    finally {
        $passwordText = $null
        [System.GC]::Collect()
    }

    Write-Host "CentOS Stream 10 setup complete!" -ForegroundColor Green
    Write-Host "To access your CentOS environment, use: wsl -d CentOS-Stream-10" -ForegroundColor Cyan
}


function Install-Ubuntu2604 {
    Write-Host "Installing Ubuntu 26.04 on WSL..." -ForegroundColor Cyan

    $installedDistros = wsl --list --quiet
    if ($installedDistros -contains "Ubuntu-26.04") {
        Write-Host "Ubuntu 26.04 is already installed." -ForegroundColor Yellow
        return
    }

    Write-Host "Downloading Ubuntu 26.04 WSL image (this may take time)..." -ForegroundColor Cyan

    $tempDir = "$env:TEMP"
    $wslFile = "$tempDir\ubuntu-26.04.wsl"
    $downloadUrl = "https://releases.ubuntu.com/26.04/ubuntu-26.04-wsl-amd64.wsl"

    $ProgressPreference = 'SilentlyContinue'
    try {
        if (Test-Path $wslFile) {
            Write-Host "Ubuntu 26.04 WSL image already downloaded." -ForegroundColor Cyan
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

    Write-Host "Installing Ubuntu from .wsl file..." -ForegroundColor Cyan
    wsl --install --from-file $wslFile --name Ubuntu-26.04

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Ubuntu installation failed." -ForegroundColor Red
        return
    }

    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item -Path $wslFile -Force

    Write-Host "Ubuntu installed successfully!" -ForegroundColor Green
    Write-Host "To start Ubuntu, open a terminal and type: wsl -d Ubuntu-26.04" -ForegroundColor Cyan
}

function Install-NixOSWSL {
    Write-Host "Installing NixOS on WSL..." -ForegroundColor Cyan

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

    # Write-Host "Running shell setup script..." -ForegroundColor Cyan
    # wsl -d NixOS -u nixos -- bash -c "nix-shell -p curl --run 'curl -sSL https://is.gd/egitif | bash -s -- nixos-wslbox'"
    Write-Host "nixos setup completed!" -ForegroundColor Green
}

function Install-CentOSWSL {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

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

    Initialize-CentOSWSL -Context $Context
}

function Set-CapsLockAsControl {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    Write-Host "Remapping Caps Lock to Control key..." -ForegroundColor Cyan

    $regFilePath = Join-Path $Context.DotfilesDirectory "windows\caps2ctrl.reg"

    if (!(Test-Path $regFilePath)) {
        Write-Host "Registry file not found at: $regFilePath" -ForegroundColor Red
        return
    }

    Start-Process -FilePath "regedit.exe" -ArgumentList "/s", "`"$regFilePath`"" -Wait
    Write-Host "Caps Lock remapped to Control key. A system restart is required." -ForegroundColor Green
}

function Install-VSCodeExtensions {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan

    $extensionsFile = Join-Path $Context.DotfilesDirectory "extras\vscode\extensions\wsl"

    if (!(Test-Path $extensionsFile)) {
        Write-Host "Extensions file not found at: $extensionsFile" -ForegroundColor Red
        return
    }

    if (!(Test-CommandExists code)) {
        Write-Host "VS Code is not installed. Please install VS Code first." -ForegroundColor Red
        return
    }

    $installedExtensions = code --list-extensions

    Get-Content $extensionsFile | ForEach-Object {
        if ($_ -match '\S' -and -not $_.StartsWith('#')) {
            $extension = $_.Trim()
            if (!($installedExtensions -contains $extension)) {
                Write-Host "Installing extension: $extension" -ForegroundColor DarkCyan
                code --install-extension $extension
            }
        }
    }
    Write-Host "VS Code extensions installed successfully!" -ForegroundColor Green
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
        Install-Chocolatey
        if (-not (Test-CommandExists choco)) {
            Write-Host "Failed to install Chocolatey. Cannot install Nerd Fonts." -ForegroundColor Red
            return
        }
    }

    Write-Host "Installing Nerd Fonts ..." -ForegroundColor Cyan
    choco install nerd-fonts-JetBrainsMono -y
    Write-Host "Nerd Fonts installation completed!" -ForegroundColor Green
}

function Get-Dotfiles {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    $gitResult = Install-Git

    if (!$gitResult.Success -or !(Test-CommandExists git)) {
        Write-Host "Git is not installed. Cannot clone dotfiles." -ForegroundColor Red
        return $false
    }

    if (Test-Path $Context.DotfilesDirectory) {
        Write-Host "Dotfiles already present. Updating..." -ForegroundColor Cyan

        Push-Location $Context.DotfilesDirectory
        try {
            $gitStatus = git status --porcelain
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Failed to inspect dotfiles status." -ForegroundColor Red
                return $false
            }

            if ([string]::IsNullOrWhiteSpace(($gitStatus -join "`n"))) {
                Write-Host "Pulling latest changes..." -ForegroundColor Cyan
                git pull --rebase
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "Failed to update dotfiles." -ForegroundColor Red
                    return $false
                }
                Write-Host "Dotfiles updated successfully!" -ForegroundColor Green
                return $true
            }
            else {
                Write-Host "Dotfiles have uncommitted changes. Please commit or stash them before updating." -ForegroundColor Red
                return $false
            }
        }
        catch {
            Write-Host "Failed to update dotfiles: $_" -ForegroundColor Red
            return $false
        }
        finally {
            Pop-Location
        }
    }

    Write-Host "Cloning dotfiles..." -ForegroundColor Cyan
    git clone https://github.com/pervezfunctor/dotfiles.git $Context.DotfilesDirectory

    if ($LASTEXITCODE -ne 0 -or !(Test-Path $Context.DotfilesDirectory)) {
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
        "Terminal-Icons",
        "PSFzf"
    )

    try {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction Stop | Out-Null

        foreach ($module in $modules) {
            if (!(Get-Module -ListAvailable -Name $module)) {
                Write-Host "Installing $module for Windows PowerShell..." -ForegroundColor Yellow
                Install-Module -Name $module -Scope CurrentUser -Force -ErrorAction Stop
            }
        }
    }
    catch {
        Write-Host "Failed to install PowerShell modules for Windows PowerShell: $_" -ForegroundColor Red
        return $false
    }

    if (Test-CommandExists pwsh) {
        $previousModuleNames = $env:DOTFILES_POWERSHELL_MODULES
        $env:DOTFILES_POWERSHELL_MODULES = $modules -join ","
        pwsh -NoLogo -NoProfile -Command @'
$ErrorActionPreference = "Stop"
foreach ($module in ($env:DOTFILES_POWERSHELL_MODULES -split ",")) {
    if (!(Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing $module for PowerShell 7..." -ForegroundColor Yellow
        Install-Module -Name $module -Scope CurrentUser -Force
    }
}
'@
        $env:DOTFILES_POWERSHELL_MODULES = $previousModuleNames
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install one or more modules for PowerShell 7." -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "PowerShell 7 not found. Skipping module installation for PowerShell 7." -ForegroundColor Yellow
        Write-Host "Consider installing PowerShell 7 for better features and performance." -ForegroundColor Yellow
    }

    Write-Host "PowerShell modules installed successfully!" -ForegroundColor Green
    return $true
}

function Initialize-PowerShell {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    # Respect OneDrive, Group Policy, and other Documents-folder redirection.
    $documentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
    $ps5ProfilePath = Join-Path $documentsPath "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    $ps7ProfilePath = Join-Path $documentsPath "PowerShell\Microsoft.PowerShell_profile.ps1"

    $sourceProfilePath = Join-Path $Context.DotfilesDirectory "powershell\Microsoft.PowerShell_profile.ps1"

    if (Test-Path $sourceProfilePath) {
        Write-Host "Setting up PowerShell profiles for both Windows PowerShell and PowerShell 7..." -ForegroundColor Cyan

        Set-ExecutionPolicy RemoteSigned -Scope Process -Force
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
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    Write-Host "Setting up WezTerm config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath (Join-Path $Context.DotfilesDirectory "wezterm\dot-config\wezterm") -targetPath (Join-Path $Context.UserProfile ".config\wezterm")

    Write-Host "Setting up Neovim config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath (Join-Path $Context.DotfilesDirectory "nvim\dot-config\nvim") -targetPath (Join-Path $Context.LocalAppData "nvim")
    New-ConfigLink -sourcePath (Join-Path $Context.DotfilesDirectory "nvim\dot-config\nvim") -targetPath (Join-Path $Context.UserProfile ".config\nvim")

    Write-Host "Setting up Emacs config..." -ForegroundColor Cyan
    New-ConfigLink -sourcePath (Join-Path $Context.DotfilesDirectory "emacs-slim\dot-emacs") -targetPath (Join-Path $Context.UserProfile ".emacs")

    Write-Host "Setting up Nushell config..." -ForegroundColor Cyan
    $null = Backup-ConfigFile -FilePath "$env:APPDATA\nushell"
    New-ConfigLink -sourcePath (Join-Path $Context.DotfilesDirectory "nushell\dot-config\nushell") -targetPath (Join-Path $Context.RoamingAppData "nushell")

    Initialize-PowerShell -Context $Context

    Write-Host "Setting up VS Code config..." -ForegroundColor Cyan
    $vscodeSettingsSource = Join-Path $Context.DotfilesDirectory "extras\vscode\wsl-settings.json"
    $vscodeSettingsTarget = Join-Path $Context.RoamingAppData "Code\User\settings.json"

    if (Test-Path $vscodeSettingsSource) {
        $null = Backup-ConfigFile -FilePath $vscodeSettingsTarget
        $null = New-ConfigDirectory -ConfigPath $vscodeSettingsTarget
        Copy-Item -Path $vscodeSettingsSource -Destination $vscodeSettingsTarget -Force
        Write-Host "VS Code settings copied successfully" -ForegroundColor Green
    }
    else {
        Write-Host "VS Code settings source file not found at: $vscodeSettingsSource" -ForegroundColor Red
    }

    Install-Starship
    Install-Nushell
    Install-Zoxide
    Install-Carapace

    Initialize-NushellProfile
    Set-PowerShellProfileAsDefault
}

function ConvertFrom-JsonC {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$InputObject
    )

    process {
        $result = [System.Text.StringBuilder]::new($InputObject.Length)
        $inString = $false
        $escaped = $false
        $inLineComment = $false
        $inBlockComment = $false

        for ($i = 0; $i -lt $InputObject.Length; $i++) {
            $character = $InputObject[$i]
            $nextCharacter = if ($i + 1 -lt $InputObject.Length) { $InputObject[$i + 1] } else { [char]0 }

            if ($inLineComment) {
                if ($character -eq "`r" -or $character -eq "`n") {
                    $inLineComment = $false
                    [void]$result.Append($character)
                }
                continue
            }

            if ($inBlockComment) {
                if ($character -eq '*' -and $nextCharacter -eq '/') {
                    $inBlockComment = $false
                    $i++
                }
                elseif ($character -eq "`r" -or $character -eq "`n") {
                    [void]$result.Append($character)
                }
                continue
            }

            if (!$inString -and $character -eq '/' -and $nextCharacter -eq '/') {
                $inLineComment = $true
                $i++
                continue
            }

            if (!$inString -and $character -eq '/' -and $nextCharacter -eq '*') {
                $inBlockComment = $true
                $i++
                continue
            }

            [void]$result.Append($character)

            if ($inString) {
                if ($escaped) {
                    $escaped = $false
                }
                elseif ($character -eq '\') {
                    $escaped = $true
                }
                elseif ($character -eq '"') {
                    $inString = $false
                }
            }
            elseif ($character -eq '"') {
                $inString = $true
            }
        }

        $result.ToString() | ConvertFrom-Json -ErrorAction Stop
    }
}

function Initialize-NushellProfile {
    if (!(Test-CommandExists nu)) {
        Write-Host "Nushell is not installed. Cannot initialize profile." -ForegroundColor Red
        return $false
    }

    $possiblePaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )

    $wtConfigPath = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-Not $wtConfigPath) {
        Write-Host "Windows Terminal settings.json not found in any of the expected locations" -ForegroundColor Red
        return $false
    }

    Write-Host "Found Windows Terminal settings at: $wtConfigPath" -ForegroundColor Cyan
    Write-Host "Adding Nushell to Windows Terminal profiles..." -ForegroundColor Cyan

    try {
        $wtConfig = Get-Content -Path $wtConfigPath -Raw | ConvertFrom-JsonC

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
            guid              = "{$(New-Guid)}"
        }

        $wtConfig.profiles.list += $nuProfileObj

        $newJsonContent = $wtConfig | ConvertTo-Json -Depth 10
        Set-Content -Path $wtConfigPath -Value $newJsonContent
        Write-Host "Nushell profile added to Windows Terminal!" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "Failed to update Windows Terminal settings: $_" -ForegroundColor Red
        return $false
    }
}

function Set-PowerShellProfileAsDefault {
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )

    $wtConfigPath = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-Not $wtConfigPath) {
        Write-Host "Windows Terminal settings.json not found in any of the expected locations" -ForegroundColor Red
        return
    }

    try {
        $jsonContent = Get-Content -Path $wtConfigPath -Raw
        try {
            $wtConfig = $jsonContent | ConvertFrom-JsonC
        }
        catch {
            Write-Host "Error parsing Windows Terminal settings JSON: $_" -ForegroundColor Red
            Write-Host "Please fix the Windows Terminal settings file manually before setting PowerShell 7 as default." -ForegroundColor Red
            return
        }

        $powerShellProfile = $wtConfig.profiles.list | Where-Object {
            $_.source -eq "Windows.Terminal.PowershellCore" -or $_.commandline -like "*pwsh.exe*"
        } | Select-Object -First 1

        if ($null -eq $powerShellProfile) {
            Write-Host "PowerShell 7 profile not found in Windows Terminal." -ForegroundColor Red
            return
        }

        $wtConfig.defaultProfile = $powerShellProfile.guid

        $newJsonContent = $wtConfig | ConvertTo-Json -Depth 10
        Set-Content -Path $wtConfigPath -Value $newJsonContent
        Write-Host "PowerShell 7 set as default shell in Windows Terminal!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to set PowerShell 7 as default: $_" -ForegroundColor Red

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

function New-ComponentRegistry {
    return [ordered]@{
        "windows-update" = @{
            Description = "Update Windows"
            Dependencies = @()
            Handler = { param($Context) Update-Windows }
        }
        "debloat" = @{
            Description = "Debloat Windows"
            Dependencies = @()
            Handler = { param($Context) Initialize-Debloat }
        }
        "dotfiles-source" = @{
            Description = "Clone or update dotfiles"
            Dependencies = @()
            Visible = $false
            IncludeInAll = $false
            Handler = { param($Context) Get-Dotfiles -Context $Context }
        }
        "dotfiles" = @{
            Description = "Initialize Dotfiles"
            Dependencies = @("dotfiles-source")
            Handler = { param($Context) Initialize-Dotfiles -Context $Context }
        }
        "capslock" = @{
            Description = "Set CapsLock as Control"
            Dependencies = @("dotfiles-source")
            Handler = { param($Context) Set-CapsLockAsControl -Context $Context }
        }
        "nerd-fonts" = @{
            Description = "Install Nerd Fonts"
            Dependencies = @()
            Handler = { param($Context) Install-NerdFonts }
        }
        "vscode" = @{
            Description = "Install VS Code"
            Dependencies = @("dotfiles-source")
            Handler = {
                param($Context)
                Install-VSCode
                Install-VSCodeExtensions -Context $Context
            }
        }
        "devtools" = @{
            Description = "Install Development Tools"
            Dependencies = @()
            Handler = { param($Context) Install-DevTools; Install-CppTools }
        }
        "ai-tools" = @{
            Description = "Install AI Tools"
            Dependencies = @()
            Handler = { param($Context) Install-AI-Tools }
        }
        "apps" = @{
            Description = "Install Applications"
            Dependencies = @()
            Handler = { param($Context) Install-Apps }
        }
        "wsl" = @{
            Description = "Install Hyper-V and WSL"
            Dependencies = @()
            Handler = { param($Context) Install-HyperV-WSL }
        }
        "multipass" = @{
            Description = "Install Multipass"
            Dependencies = @()
            Handler = { param($Context) Install-Multipass }
        }
        "multipass-vm" = @{
            Description = "Install Multipass VM"
            Dependencies = @("multipass")
            Handler = { param($Context) Initialize-SSHKey; Install-MultipassVM; Initialize-MultipassVMSSH }
        }
        "wsl-ubuntu" = @{
            Description = "Install Ubuntu WSL"
            Dependencies = @("wsl")
            Handler = { param($Context) Install-WSLDistro -DistroName "Ubuntu-26.04" }
        }
        "wsl-debian" = @{
            Description = "Install Debian WSL"
            Dependencies = @("wsl")
            Handler = { param($Context) Install-WSLDistro -DistroName "Debian" }
        }
        "wsl-opensuse" = @{
            Description = "Install openSUSE WSL"
            Dependencies = @("wsl")
            Handler = { param($Context) Install-WSLDistro -DistroName "openSUSE-Tumbleweed" }
        }
        "wsl-fedora" = @{
            Description = "Install Fedora WSL"
            Dependencies = @("wsl")
            Handler = { param($Context) Install-WSLDistro -DistroName "FedoraLinux-44" }
        }
        "wsl-centos" = @{
            Description = "Install CentOS WSL"
            Dependencies = @("wsl")
            Handler = { param($Context) Install-CentOSWSL -Context $Context }
        }
        "wsl-nixos" = @{
            Description = "Install NixOS WSL"
            Dependencies = @("wsl")
            Handler = { param($Context) Install-NixOSWSL }
        }
        "wsl-ubuntu-26.04" = @{
            Description = "Install Ubuntu 26.04 WSL from image"
            Dependencies = @("wsl")
            IncludeInAll = $false
            Handler = { param($Context) Install-Ubuntu2604 }
        }
    }
}

function Resolve-ComponentOrder {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Selected,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Registry
    )

    if ($Selected -contains "all") {
        $Selected = @($Registry.Keys | Where-Object { $Registry[$_].IncludeInAll -ne $false })
    }

    $states = @{}
    $resolved = [System.Collections.Generic.List[string]]::new()

    function Resolve-ComponentDependency {
        param([string]$Name)

        if (!$Registry.Contains($Name)) {
            throw "Unknown component: $Name"
        }
        if ($states[$Name] -eq 1) {
            throw "Circular component dependency detected at '$Name'."
        }
        if ($states[$Name] -eq 2) {
            return
        }

        $states[$Name] = 1
        foreach ($dependency in @($Registry[$Name].Dependencies)) {
            Resolve-ComponentDependency -Name $dependency
        }
        $states[$Name] = 2
        $resolved.Add($Name)
    }

    foreach ($name in $Selected) {
        Resolve-ComponentDependency -Name $name
    }

    return $resolved.ToArray()
}

function Debug-Variable {
    param(
        [string]$Name,
        [object]$Value
    )
    Write-Host "DEBUG: $Name = $($Value | ConvertTo-Json -Compress)" -ForegroundColor Magenta
}

function Initialize-Debloat {
    Write-Host "Initializing Windows debloat process..." -ForegroundColor Cyan
    Write-Host "This will download and execute a debloat script from https://debloat.raphi.re/" -ForegroundColor Yellow
    Write-Host "This script helps remove unnecessary Windows bloatware and telemetry." -ForegroundColor Yellow

    $confirmation = Read-Host "Do you want to continue? (y/n)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Debloat process cancelled by user." -ForegroundColor Yellow
        return
    }

    try {
        Write-Host "Downloading debloat script..." -ForegroundColor Cyan
        $debloatScript = Invoke-RestMethod "https://debloat.raphi.re/" -UseBasicParsing -ErrorAction Stop

        if ([string]::IsNullOrEmpty($debloatScript)) {
            Write-Host "Failed to download debloat script: Empty response" -ForegroundColor Red
            return
        }

        Write-Host "Executing debloat script..." -ForegroundColor Cyan
        $scriptBlock = [scriptblock]::Create($debloatScript)

        # Execute the script with error handling
        # The execution policy is already set at the script level (lines 36-41)
        # and will be restored at the end of the script (lines 1747-1751)
        & $scriptBlock

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Debloat process completed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "Debloat process completed with warnings. Exit code: $LASTEXITCODE" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Failed to execute debloat script: $_" -ForegroundColor Red
        Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    }
}

function Show-Menu {
    param (
        [string]$Title = "Select components to install",
        [string[]]$PreSelected = @(),

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Registry
    )

    Write-Host "`n$Title" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan

    $menuItems = [ordered]@{}
    $selectedItems = [ordered]@{}
    $index = 1

    foreach ($key in $Registry.Keys | Where-Object { $Registry[$_].Visible -ne $false }) {
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
            Write-Host "$marker [$i] $($Registry[$key].Description)" -ForegroundColor $(if ($selected) { "Green" } else { "Yellow" })
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

function Initialize-SSHKey {
    Write-Host "Initializing SSH key..." -ForegroundColor Cyan

    New-Directory -Path "$env:USERPROFILE\.ssh" | Out-Null

    $privateKeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
    $publicKeyPath = "$env:USERPROFILE\.ssh\id_ed25519.pub"

    if ((Test-Path $privateKeyPath) -or (Test-Path $publicKeyPath)) {
        Write-Host "SSH key already exists." -ForegroundColor Yellow
        return
    }

    if (!(Test-CommandExists ssh-keygen)) {
        Write-Host "ssh-keygen not found. Please install OpenSSH client." -ForegroundColor Red
        return
    }

    Write-Host "Generating new SSH key..." -ForegroundColor Cyan
    ssh-keygen -t ed25519 -f $privateKeyPath -N ''
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SSH key generated successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Failed to generate SSH key." -ForegroundColor Red
    }
}

function Copy-PublicKeyToMultipass {
    $pubkey = Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" -Raw
    $multipassCommand = @"
mkdir -p ~/.ssh
echo '$pubkey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
"@

    multipass exec ubuntu-ilm -- bash -c "$multipassCommand"
}

function Add-MultipassToSSHConfig {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName
    )

    $ip = multipass info $VMName | Select-String -Pattern "IPv4" | ForEach-Object { $_.Line.Split(":")[1].Trim() }

    $sshConfigEntry = @"
    Host $VMName
        HostName $ip
        User ubuntu
        IdentityFile ~/.ssh/id_ed25519
"@

    Add-Content -Path "$env:USERPROFILE\.ssh\config" -Value $sshConfigEntry
    Write-Host "Added SSH config entry for $VMName ($ip)" -ForegroundColor Green
}

function Install-SelectedComponents {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$ComponentList,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Registry,

        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    try {
        $orderedComponents = Resolve-ComponentOrder -Selected $ComponentList -Registry $Registry
    }
    catch {
        $result = New-SetupResult -Name "Component selection" -Status Failed -Message $_.Exception.Message -ExitCode 1
        Write-SetupResult $result
        return @($result)
    }

    $allResults = [System.Collections.Generic.List[object]]::new()
    $componentSucceeded = @{}

    foreach ($component in $orderedComponents) {
        $definition = $Registry[$component]
        Write-Host "`nProcessing component: $component ($($definition.Description))" -ForegroundColor Cyan

        $failedDependencies = @($definition.Dependencies | Where-Object { $componentSucceeded[$_] -eq $false })
        if ($failedDependencies.Count -gt 0) {
            $result = New-SetupResult -Name $component -Status Skipped -Message "Skipped $component because dependencies failed: $($failedDependencies -join ', ')."
            $result | Add-Member -NotePropertyName Component -NotePropertyValue $component
            Write-SetupResult $result
            $allResults.Add($result)
            $componentSucceeded[$component] = $false
            continue
        }

        try {
            $output = @(& $definition.Handler $Context)
            $results = @($output | Where-Object { $_.PSObject.TypeNames -contains "Dotfiles.SetupResult" })

            if ($results.Count -eq 0) {
                $status = if ($output -contains $false) { "Failed" } else { "Completed" }
                $results = @(New-SetupResult -Name $component -Status $status)
            }
        }
        catch {
            $results = @(New-SetupResult -Name $component -Status Failed -Message "${component}: $($_.Exception.Message)" -ExitCode 1)
        }

        foreach ($result in $results) {
            if ($null -eq $result.Component) {
                $result | Add-Member -NotePropertyName Component -NotePropertyValue $component
            }
            $allResults.Add($result)
        }

        $componentSucceeded[$component] = @($results | Where-Object { !$_.Success }).Count -eq 0
    }

    Write-Host "`nSetup summary" -ForegroundColor Cyan
    foreach ($group in $allResults | Group-Object Status | Sort-Object Name) {
        Write-Host "  $($group.Name): $($group.Count)"
    }

    return $allResults.ToArray()
}

function Main {
    param (
        [switch]$ListComponents,
        [string[]]$Components = @()
    )

    $context = New-SetupContext
    $registry = New-ComponentRegistry

    if ($ListComponents) {
        Write-Host "Available components:" -ForegroundColor Cyan
        foreach ($key in $registry.Keys | Where-Object { $registry[$_].Visible -ne $false }) {
            Write-Host "  $key - $($registry[$key].Description)" -ForegroundColor Yellow
        }
        Write-Host "  all - Install All Components" -ForegroundColor Yellow
        return
    }

    if ($null -eq $Components -or $Components.Count -eq 0) {
        # Pass the Components array as PreSelected to Show-Menu
        Write-Host "Running in interactive mode with preselected components: $($Components -join ', ')" -ForegroundColor Cyan
        $selectedComponents = Show-Menu -Registry $registry -PreSelected @("nerd-fonts", "vscode", "wsl", "wsl-ubuntu-26.04")
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
    $null = Install-SelectedComponents -ComponentList $selectedComponents -Registry $registry -Context $context
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
