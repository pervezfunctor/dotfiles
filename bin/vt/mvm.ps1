function Test-MultipassInstalled {
  return Get-Command multipass -ErrorAction SilentlyContinue
}

function Install-Multipass {
  if (Test-MultipassInstalled) {
    Write-Host "Multipass is already installed." -ForegroundColor Yellow
    return
  }

  Write-Host "Installing Multipass..." -ForegroundColor Cyan

  if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id Canonical.Multipass -e
  }
  else {
    Write-Host "Winget is not installed. Please install it first." -ForegroundColor Red
    return
  }

  if (Test-MultipassInstalled) {
    Write-Host "Multipass installed successfully!" -ForegroundColor Green
  }
  else {
    Write-Host "Failed to install Multipass." -ForegroundColor Red
  }
}

function Get-MultipassVMs {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  multipass list
}

function Get-MultipassVMStatus {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  multipass info $VMName
}

function Start-MultipassVM {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  multipass start $VMName
}

function Stop-MultipassVM {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  multipass stop $VMName
}


function Restart-MultipassVM {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  multipass restart $VMName
}

function Remove-MultipassVM {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  multipass delete $VMName
}

function Enter-MultipassVMShell {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  multipass shell $VMName
}

function Invoke-MultipassVMCommand {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [Parameter(Mandatory = $true)]
    [string]$Command
  )

  multipass exec $VMName -- $Command
}

function Get-MultipassVMIP {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  multipass info $VMName | Select-String -Pattern "IPv4" | ForEach-Object { $_.Line.Split(":")[1].Trim() }
}

function Enter-MultipassVMSSH {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  $ip = Get-MultipassVMIP -VMName $VMName
  ssh $ip
}

function Get-MultipassVMInfo {
  if (-not (Test-MultipassInstalled)) {
    Write-Host "Multipass is not installed." -ForegroundColor Red
    return
  }

  param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
  )

  multipass info $VMName
}

function Copy-PublicKeyToMultipass {
  <#
    .SYNOPSIS
        Copies a local public SSH key to a Multipass instance's authorized_keys file.

    .DESCRIPTION
        This function reads a specified public SSH key from the local machine and securely adds it
        to the ~/.ssh/authorized_keys file within a specified Multipass instance. It ensures the
        .ssh directory exists and has the correct permissions.

    .PARAMETER InstanceName
        The name of the target Multipass instance. Defaults to 'primary'.

    .PARAMETER PublicKeyPath
        The full path to the public key file to be copied.
        Defaults to the standard ed25519 key in the user's profile.

    .EXAMPLE
        PS C:\> Copy-PublicKeyToMultipass -InstanceName my-dev-vm

        Copies the default key (~/.ssh/id_ed25519.pub) to the 'my-dev-vm' instance.

    .EXAMPLE
        PS C:\> Copy-PublicKeyToMultipass -InstanceName ubuntu-lts -PublicKeyPath C:\Users\user\.ssh\id_rsa.pub

        Copies the specified RSA public key to the 'ubuntu-lts' instance.

    .EXAMPLE
        PS C:\> 'my-vm1', 'my-vm2' | Copy-PublicKeyToMultipass

        Copies the default public key to both 'my-vm1' and 'my-vm2' using pipeline input.
    #>
  [CmdletBinding()]
  [OutputType([void])]
  param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$InstanceName = 'primary',

    [Parameter()]
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string]$PublicKeyPath = (Join-Path $env:USERPROFILE ".ssh\id_ed25519.pub")
  )

  process {
    try {
      Write-Verbose "Reading public key from: $PublicKeyPath"
      $pubkey = Get-Content -Path $PublicKeyPath -Raw -ErrorAction Stop
    }
    catch {
      # Re-throw with a more user-friendly message
      Throw "Failed to read public key file at '$PublicKeyPath'. Please check the path and permissions. Error: $($_.Exception.Message)"
    }

    # This shell script is more robust:
    # 1. It creates the .ssh directory and sets its permissions first.
    # 2. It checks if the key already exists in authorized_keys before appending to avoid duplicates.
    # 3. It ensures the authorized_keys file has the correct permissions.
    $multipassCommand = @"
set -e
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
if ! grep -q -F "$pubkey" ~/.ssh/authorized_keys; then
    echo '$pubkey' >> ~/.ssh/authorized_keys
    echo 'Public key added.'
else
    echo 'Public key already exists.'
fi
chmod 600 ~/.ssh/authorized_keys
"@

    Write-Verbose "Executing command on Multipass instance '$InstanceName'."
    multipass exec $InstanceName -- bash -c $multipassCommand

    if ($LASTEXITCODE -ne 0) {
      Write-Error "Multipass command failed on instance '$InstanceName' with exit code $LASTEXITCODE."
    }
    else {
      Write-Host "Successfully configured public key on Multipass instance '$InstanceName'."
    }
  }
}

function Add-MultipassToSSHConfig {
  <#
    .SYNOPSIS
        Adds or updates an SSH config entry for a Multipass instance.

    .DESCRIPTION
        This function retrieves the IP address of a specified Multipass instance and adds a corresponding
        Host entry to the user's SSH config file. It intelligently checks for and prevents duplicate
        entries. The function supports -WhatIf and -Confirm to prevent accidental changes.

    .PARAMETER VMName
        The name of the target Multipass instance. This parameter accepts pipeline input.
        Alias: Name, InstanceName

    .PARAMETER SshConfigPath
        The path to the SSH config file. Defaults to '~/.ssh/config'.

    .PARAMETER SshUser
        The username for the SSH connection. Defaults to 'ubuntu'.

    .PARAMETER IdentityFile
        The path to the SSH private key (identity file). Defaults to '~/.ssh/id_ed25519'.

    .PARAMETER Force
        If specified, this switch will overwrite an existing SSH config entry for the VM.
        Otherwise, the function will abort if an entry already exists.

    .EXAMPLE
        PS C:\> Add-MultipassToSSHConfig -VMName my-dev-vm

        Adds a new SSH config entry for 'my-dev-vm' using the default user and identity file.

    .EXAMPLE
        PS C:\> Add-MultipassToSSHConfig -VMName prod-server -SshUser admin -IdentityFile ~/.ssh/prod_key -WhatIf

        Shows what would happen if an entry for 'prod-server' was added with a custom user and key,
        but does not actually modify the file.

    .EXAMPLE
        PS C:\> 'vm1', 'vm2' | Add-MultipassToSSHConfig

        Adds SSH config entries for both 'vm1' and 'vm2' using pipeline input.
    #>
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType([void])]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias('Name', 'InstanceName')]
    [string]$VMName,

    [Parameter()]
    [string]$SshConfigPath = (Join-Path $env:USERPROFILE ".ssh\config"),

    [Parameter()]
    [string]$SshUser = 'ubuntu',

    [Parameter()]
    [string]$IdentityFile = '~/.ssh/id_ed25519',

    [Parameter()]
    [switch]$Force
  )

  process {
    Write-Verbose "Processing VM: $VMName"

    # Step 1: Get VM info using a reliable format (JSON)
    try {
      Write-Verbose "Querying multipass for info on '$VMName' in JSON format."
      $vmInfoJson = multipass info $VMName --format json --ErrorAction Stop
      $vmInfo = $vmInfoJson | ConvertFrom-Json
    }
    catch {
      Write-Error "Failed to get info for Multipass instance '$VMName'. Does it exist and is `multipass.exe` in your PATH? Error: $($_.Exception.Message)"
      return # Stop processing this item
    }

    # The JSON structure is { "info": { "<VMName>": { ... } } }
    $ip = $vmInfo.info.$VMName.ipv4[0]
    if (-not $ip) {
      Write-Error "Could not retrieve an IPv4 address for VM '$VMName'. The VM might be stopped or have no network."
      return
    }

    Write-Verbose "Found IP Address: $ip for VM '$VMName'."

    # Step 2: Prepare the SSH config file and check for existing entries
    $sshDir = Split-Path -Path $SshConfigPath
    if (-not (Test-Path -Path $sshDir)) {
      Write-Verbose "Creating SSH directory at '$sshDir'."
      if ($PSCmdlet.ShouldProcess($sshDir, "Create Directory")) {
        New-Item -Path $sshDir -ItemType Directory -Force | Out-Null
      }
    }

    $entryExists = (Test-Path $SshConfigPath) -and (Select-String -Path $SshConfigPath -Pattern "^\s*Host\s+$VMName\s*$" -Quiet)

    if ($entryExists -and -not $Force) {
      Write-Warning "SSH config entry for host '$VMName' already exists. Use -Force to overwrite."
      return
    }

    # Step 3: Construct the new entry and modify the file
    $sshConfigEntry = @"

Host $VMName
    HostName $ip
    User $SshUser
    IdentityFile $IdentityFile
"@
    # A leading newline ensures separation from any existing content.

    $actionDescription = if ($entryExists) { "Overwrite SSH config entry for '$VMName'" } else { "Add SSH config entry for '$VMName'" }

    if ($PSCmdlet.ShouldProcess($SshConfigPath, $actionDescription)) {
      if ($entryExists -and $Force) {
        Write-Verbose "Overwriting existing entry for '$VMName'."
        $currentConfig = Get-Content $SshConfigPath -Raw
        # This regex removes the old block, from "Host <vm>" to the next "Host " or end of file
        $updatedConfig = $currentConfig -creplace "(?sm)^\s*Host\s+$VMName\s*$.*?(?=(\r?\n\s*\bHost\b|$))", ""
        Set-Content -Path $SshConfigPath -Value ($updatedConfig.Trim() + $sshConfigEntry)
      }
      else {
        Add-Content -Path $SshConfigPath -Value $sshConfigEntry
      }
      Write-Host "Successfully configured SSH entry for $VMName ($ip) in '$SshConfigPath'." -ForegroundColor Green
    }
  }
}

function Main {
  if ($args.Count -eq 0) {
    Write-Host "Usage: mvm <command> [arguments]" -ForegroundColor Yellow
    return
  }

  $command = $args[0]
  $args = $args[1..$args.Count]

  switch ($command) {
    "install" {
      Install-Multipass
    }
    "list" {
      Get-MultipassVMs
    }
    "status" {
      Get-MultipassVMStatus -VMName $args[0]
    }
    "create" {
      multipass launch $args[0]
    }
    "start" {
      Start-MultipassVM -VMName $args[0]
    }
    "stop" {
      Stop-MultipassVM -VMName $args[0]
    }
    "restart" {
      Restart-MultipassVM -VMName $args[0]
    }
    "delete" {
      Remove-MultipassVM -VMName $args[0]
    }
    "shell" {
      Enter-MultipassVMShell -VMName $args[0]
    }
    "exec" {
      Invoke-MultipassVMCommand -VMName $args[0] -Command $args[1]
    }
    "ip" {
      Get-MultipassVMIP -VMName $args[0]
    }
    "ssh" {
      Enter-MultipassVMSSH -VMName $args[0]
    }
    "info" {
      Get-MultipassVMInfo -VMName $args[0]
    }
    default {
      Write-Host "Unknown command: $command" -ForegroundColor Red
    }
  }
}

Main $args

