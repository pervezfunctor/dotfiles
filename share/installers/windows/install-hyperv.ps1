#Requires -RunAsAdministrator

function Test-Windows11 {
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $version = [Version]$osInfo.Version

    # Windows 11 is version 10.0.22000 or higher
    if ($version.Build -ge 22000) {
        return $true
    }
    return $false
}

function Test-HyperVInstalled {
    $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
    return $hyperv.State -eq "Enabled"
}

function Install-HyperV {
    Write-Host "Installing Hyper-V and related components..." -ForegroundColor Cyan

    # Enable Hyper-V feature
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

    # Enable Virtual Machine Platform (required for WSL2 and other virtualization)
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

    # Enable Windows Hypervisor Platform
    Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart

    # Enable Containers feature
    Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart

    Write-Host "Hyper-V installation complete! A system restart is required to finish the setup." -ForegroundColor Green

    $restart = Read-Host "Would you like to restart now? (y/n)"
    if ($restart -eq 'y') {
        Restart-Computer
    }
}

function Set-HyperVConfiguration {
    Write-Host "Configuring Hyper-V..." -ForegroundColor Cyan

    # Create a default virtual switch if none exists
    $switches = Get-VMSwitch -ErrorAction SilentlyContinue
    if ($switches.Count -eq 0) {
        Write-Host "Creating a default External Virtual Switch..." -ForegroundColor Cyan

        # Get the first connected network adapter
        $netAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notmatch "Hyper-V|vEthernet" } | Select-Object -First 1

        if ($netAdapter) {
            New-VMSwitch -Name "Default Switch" -AllowManagementOS $true -NetAdapterName $netAdapter.Name
            Write-Host "Default External Virtual Switch created successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "No suitable network adapter found for creating an External Virtual Switch." -ForegroundColor Yellow
            Write-Host "Creating an Internal Virtual Switch instead..." -ForegroundColor Cyan
            New-VMSwitch -Name "Internal Switch" -SwitchType Internal
            Write-Host "Internal Virtual Switch created successfully!" -ForegroundColor Green
        }
    }
    else {
        Write-Host "Virtual Switch already exists. Skipping creation." -ForegroundColor Yellow
    }

    # Set default VM location
    $defaultVMPath = "$env:USERPROFILE\Hyper-V\Virtual Machines"
    $defaultVHDPath = "$env:USERPROFILE\Hyper-V\Virtual Hard Disks"

    if (!(Test-Path $defaultVMPath)) {
        New-Item -Path $defaultVMPath -ItemType Directory -Force | Out-Null
    }

    if (!(Test-Path $defaultVHDPath)) {
        New-Item -Path $defaultVHDPath -ItemType Directory -Force | Out-Null
    }

    Set-VMHost -VirtualMachinePath $defaultVMPath -VirtualHardDiskPath $defaultVHDPath

    Write-Host "Hyper-V configured successfully!" -ForegroundColor Green
}

function Main {
    Write-Host "Hyper-V Installation for Windows 11" -ForegroundColor Green

    # Check if running on Windows 11
    if (-not (Test-Windows11)) {
        Write-Host "This script is designed for Windows 11. Your system appears to be running an older version of Windows." -ForegroundColor Red
        Write-Host "Hyper-V installation may still work, but some features might not be available." -ForegroundColor Yellow
        $continue = Read-Host "Do you want to continue anyway? (y/n)"
        if ($continue -ne 'y') {
            return
        }
    }

    # Check if Hyper-V is already installed
    if (Test-HyperVInstalled) {
        Write-Host "Hyper-V is already installed on this system." -ForegroundColor Yellow
        $configure = Read-Host "Would you like to configure Hyper-V settings? (y/n)"
        if ($configure -eq 'y') {
            Set-HyperVConfiguration
        }
        return
    }

    # Check hardware virtualization support
    $systemInfo = Get-ComputerInfo
    if (-not $systemInfo.HyperVisorPresent) {
        Write-Host "Hardware virtualization might not be enabled in your BIOS/UEFI." -ForegroundColor Red
        Write-Host "Please enable virtualization in your system BIOS/UEFI settings and try again." -ForegroundColor Yellow
        $continue = Read-Host "Do you want to continue anyway? (y/n)"
        if ($continue -ne 'y') {
            return
        }
    }

    # Install Hyper-V
    Install-HyperV

    # Configure Hyper-V if no restart is needed
    if (Test-HyperVInstalled) {
        Set-HyperVConfiguration
    }
    else {
        Write-Host "Please restart your computer to complete Hyper-V installation." -ForegroundColor Yellow
        Write-Host "After restart, run this script again to configure Hyper-V." -ForegroundColor Yellow
    }
}

# Run the main function
Main



