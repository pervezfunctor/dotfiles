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

function Install-Windows11VM {
    param (
        [string]$VMName = "Windows11VM",
        [int64]$MemoryGB = 16,
        [int]$ProcessorCount = 4,
        [int64]$DiskSizeGB = 100
    )

    # Validate VM name doesn't already exist
    if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
        Write-Host "VM '$VMName' already exists. Please choose a different name." -ForegroundColor Red
        return
    }

    Write-Host "Creating Windows 11 VM: $VMName..." -ForegroundColor Cyan

    $MemoryMB = $MemoryGB * 1024

    $VHDPath = "$env:USERPROFILE\Hyper-V\Virtual Hard Disks\$VMName.vhdx"
    $downloadsPath = "$env:USERPROFILE\Downloads"
    $isoName = "Win11_24H2_English_x64.iso"
    $isoPath = "$downloadsPath\$isoName"

    # ISO handling with robust validation
    if (-not (Test-Path $isoPath)) {
        Write-Host "Windows 11 ISO not found at: $isoPath" -ForegroundColor Yellow
        Write-Host "Please download the Windows 11 ISO manually from the Microsoft website." -ForegroundColor Cyan
        Write-Host "Visit: https://www.microsoft.com/software-download/windows11" -ForegroundColor Cyan

        $downloadChoice = Read-Host "Would you like to open the download page now? (Y/N)"
        if ($downloadChoice -eq "Y" -or $downloadChoice -eq "y") {
            Start-Process "https://www.microsoft.com/software-download/windows11"
        }

        Write-Host "After downloading, please save the ISO as: $isoPath" -ForegroundColor Yellow
        Write-Host "Then run this script again." -ForegroundColor Yellow
        return
    }

    # Validate ISO file integrity
    Write-Host "Validating Windows 11 ISO file integrity..." -ForegroundColor Cyan
    try {
        # Check file size (should be at least 4GB for Windows 11)
        $fileSize = (Get-Item $isoPath).Length
        if ($fileSize -lt 4GB) {
            Write-Host "Warning: ISO file size ($($fileSize/1GB) GB) seems smaller than expected for Windows 11." -ForegroundColor Yellow
            $continueAnyway = Read-Host "Continue anyway? (Y/N)"
            if ($continueAnyway -ne "Y" -and $continueAnyway -ne "y") {
                Write-Host "Operation cancelled by user." -ForegroundColor Red
                return
            }
        }

        # Try mounting the ISO to verify it's valid
        try {
            $mountResult = Mount-DiskImage -ImagePath $isoPath -PassThru -ErrorAction Stop
            $driveLetter = ($mountResult | Get-Volume).DriveLetter

            # Check for key Windows installation files
            if (-not (Test-Path "${driveLetter}:\sources\install.wim") -and -not (Test-Path "${driveLetter}:\sources\install.esd")) {
                Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
                Write-Host "The Windows 11 ISO appears to be invalid (missing installation files)." -ForegroundColor Red
                Write-Host "Please download a valid Windows 11 ISO and try again." -ForegroundColor Yellow
                return
            }

            # Dismount after validation
            Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "The Windows 11 ISO file appears to be corrupted or invalid." -ForegroundColor Red
            $replaceIso = Read-Host "Would you like to delete it and download a new one? (Y/N)"
            if ($replaceIso -eq "Y" -or $replaceIso -eq "y") {
                Remove-Item -Path $isoPath -Force -ErrorAction SilentlyContinue
                Write-Host "ISO file removed. Please download a valid Windows 11 ISO and try again." -ForegroundColor Yellow
                Start-Process "https://www.microsoft.com/software-download/windows11"
            }
            return
        }
    }
    catch {
        Write-Host "Error validating ISO file: $_" -ForegroundColor Red
        return
    }

    # Create VM switch if needed
    $vmSwitch = Get-VMSwitch | Select-Object -First 1
    if (-not $vmSwitch) {
        Write-Host "No virtual switch found. Creating a new internal switch..." -ForegroundColor Yellow
        try {
            $vmSwitch = New-VMSwitch -Name "Internal Switch" -SwitchType Internal -ErrorAction Stop
        }
        catch {
            Write-Host "Failed to create virtual switch: $_" -ForegroundColor Red
            Write-Host "Please create a virtual switch manually using Hyper-V Manager and try again." -ForegroundColor Yellow
            return
        }
    }

    # Create VHD directory if it doesn't exist
    $vhdDirectory = Split-Path -Parent $VHDPath
    if (-not (Test-Path $vhdDirectory)) {
        try {
            New-Item -Path $vhdDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Host "Failed to create VHD directory: $_" -ForegroundColor Red
            return
        }
    }

    # Create virtual hard disk with error handling
    Write-Host "Creating virtual hard disk..." -ForegroundColor Cyan
    try {
        New-VHD -Path $VHDPath -SizeBytes ($DiskSizeGB * 1GB) -Dynamic -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Host "Failed to create virtual hard disk: $_" -ForegroundColor Red
        return
    }

    # Create the VM with error handling
    Write-Host "Creating virtual machine..." -ForegroundColor Cyan
    try {
        New-VM -Name $VMName -MemoryStartupBytes ($MemoryMB * 1MB) -VHDPath $VHDPath -Generation 2 -SwitchName $vmSwitch.Name -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Host "Failed to create virtual machine: $_" -ForegroundColor Red
        # Clean up VHD if VM creation fails
        Remove-Item -Path $VHDPath -Force -ErrorAction SilentlyContinue
        return
    }

    # Configure VM settings for Windows 11 compatibility with error handling
    try {
        Set-VMProcessor -VMName $VMName -Count $ProcessorCount -ExposeVirtualizationExtensions $true -ErrorAction Stop
        Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes (2GB) -MaximumBytes ($MemoryMB * 1MB) -ErrorAction Stop

        # Configure secure boot with proper key protector first
        Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector -ErrorAction Stop
        Set-VMSecurityPolicy -VMName $VMName -VirtualizationBasedSecurityOptOut $false -TpmEnabled $true -ErrorAction Stop
        Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate MicrosoftWindows -ErrorAction Stop

        # Now enable TPM after key protector is set
        Enable-VMTPM -VMName $VMName -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to configure VM settings: $_" -ForegroundColor Red
        Write-Host "Removing partially created VM..." -ForegroundColor Yellow
        Remove-VM -Name $VMName -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $VHDPath -Force -ErrorAction SilentlyContinue
        return
    }

    # Create directory for autounattend files if it doesn't exist
    $autoDir = "$env:USERPROFILE\Hyper-V\AutoUnattend"
    if (!(Test-Path $autoDir)) {
        try {
            New-Item -Path $autoDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Host "Failed to create AutoUnattend directory: $_" -ForegroundColor Red
            # Continue anyway, we'll use the original ISO if this fails
        }
    }

    # Create autounattend.xml in the directory
    $autoXmlPath = "$autoDir\autounattend.xml"
    Set-Content -Path $autoXmlPath -Value @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <UserData>
                <AcceptEula>true</AcceptEula>
            </UserData>
            <ImageInstall>
                <OSImage>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>2</PartitionID>
                    </InstallTo>
                </OSImage>
            </ImageInstall>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>$VMName</ComputerName>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <ProtectYourPC>3</ProtectYourPC>
            </OOBE>
            <UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>UABhAHMAcwB3AG8AcgBkADEAMgAzACEAUABhAHMAcwB3AG8AcgBkAA==</Value>
                            <PlainText>false</PlainText>
                        </Password>
                        <Name>User</Name>
                        <Group>Administrators</Group>
                        <DisplayName>User</DisplayName>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
            <AutoLogon>
                <Password>
                    <Value>UABhAHMAcwB3AG8AcgBkADEAMgAzACEAUABhAHMAcwB3AG8AcgBkAA==</Value>
                    <PlainText>false</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <Username>User</Username>
            </AutoLogon>
        </component>
    </settings>
</unattend>
"@

    Write-Host "Created autounattend.xml at $autoXmlPath" -ForegroundColor Cyan

    # Mount the Windows ISO to copy files
    try {
        $mountResult = Mount-DiskImage -ImagePath $isoPath -PassThru -ErrorAction Stop
        $driveLetter = ($mountResult | Get-Volume).DriveLetter

        # Create a working directory for the new ISO
        $workDir = "$autoDir\iso"
        if (Test-Path $workDir) {
            Remove-Item -Path $workDir -Recurse -Force -ErrorAction Stop
        }
        New-Item -Path $workDir -ItemType Directory -Force -ErrorAction Stop | Out-Null

        # Copy Windows installation files with progress indicator
        Write-Host "Copying Windows installation files (this may take a while)..." -ForegroundColor Cyan
        Copy-Item -Path "${driveLetter}:\*" -Destination $workDir -Recurse -ErrorAction Stop

        # Add the autounattend.xml file
        Copy-Item -Path $autoXmlPath -Destination "$workDir\autounattend.xml" -ErrorAction Stop

        # Unmount the original ISO
        Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "Error preparing installation files: $_" -ForegroundColor Red
        Write-Host "Will attempt to use the original ISO without unattended setup." -ForegroundColor Yellow
        Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
        $useOriginalIso = $true
    }

    # Create the new ISO with autounattend.xml if we successfully prepared the files
    $autoIsoPath = "$autoDir\Windows11-Unattended.iso"
    $useOriginalIso = $false

    if (-not $useOriginalIso) {
        # Check if oscdimg is available (part of Windows ADK)
        $oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
        if (Test-Path $oscdimgPath) {
            try {
                Write-Host "Creating bootable ISO with unattended setup..." -ForegroundColor Cyan
                & $oscdimgPath -m -o -u2 -udfver102 -bootdata:2`#p0, e, b"$workDir\boot\etfsboot.com"`#pEF, e, b"$workDir\efi\microsoft\boot\efisys.bin" "$workDir" "$autoIsoPath" | Out-Null
                if (-not (Test-Path $autoIsoPath) -or (Get-Item $autoIsoPath).Length -lt 100MB) {
                    throw "Created ISO file is invalid or too small"
                }
            }
            catch {
                Write-Host "Failed to create bootable ISO: $_" -ForegroundColor Red
                Write-Host "Using the original ISO instead. Installation will not be fully unattended." -ForegroundColor Yellow
                $useOriginalIso = $true
            }
        }
        else {
            Write-Host "Warning: oscdimg not found. Cannot create bootable ISO." -ForegroundColor Yellow
            Write-Host "Using the original ISO instead. Installation will not be fully unattended." -ForegroundColor Yellow
            $useOriginalIso = $true
        }
    }

    # Use the appropriate ISO path
    $finalIsoPath = if ($useOriginalIso) { $isoPath } else { $autoIsoPath }

    # Now add DVD drive with the correct ISO path
    try {
        $dvdDrive = Add-VMDvdDrive -VMName $VMName -Path $finalIsoPath -PassThru -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to add DVD drive: $_" -ForegroundColor Red
        Write-Host "Attempting to continue without DVD drive..." -ForegroundColor Yellow
        # Try to create DVD drive without ISO
        try {
            $dvdDrive = Add-VMDvdDrive -VMName $VMName -PassThru -ErrorAction Stop
            # Then try to set the ISO path
            Set-VMDvdDrive -VMName $VMName -ControllerNumber $dvdDrive.ControllerNumber -ControllerLocation $dvdDrive.ControllerLocation -Path $finalIsoPath -ErrorAction Stop
        }
        catch {
            Write-Host "Failed to create DVD drive. VM will be created but you'll need to manually attach the ISO." -ForegroundColor Red
            $dvdDrive = $null
        }
    }

    # Set boot order with proper objects - only if we have a DVD drive
    try {
        if ($dvdDrive) {
            $bootOrder = @(
                $dvdDrive
                Get-VMHardDiskDrive -VMName $VMName | Select-Object -First 1
            )
            Set-VMFirmware -VMName $VMName -BootOrder $bootOrder -ErrorAction Stop
        }
        else {
            Write-Host "DVD drive not available. Boot order not set." -ForegroundColor Yellow
            Write-Host "You'll need to manually configure boot order in Hyper-V Manager." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Failed to set boot order: $_" -ForegroundColor Red
        Write-Host "You'll need to manually configure boot order in Hyper-V Manager." -ForegroundColor Yellow
    }

    # Start the VM with error handling
    try {
        Start-VM -VMName $VMName -ErrorAction Stop
        Write-Host "VM started successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to start VM: $_" -ForegroundColor Red
        Write-Host "You can try starting the VM manually from Hyper-V Manager." -ForegroundColor Yellow
    }

    # Open VM Connect window
    try {
        Write-Host "Opening VM Connect window..." -ForegroundColor Cyan
        Start-Process "vmconnect.exe" -ArgumentList "localhost", $VMName -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to open VM Connect window: $_" -ForegroundColor Red
        Write-Host "You can connect to the VM manually using Hyper-V Manager." -ForegroundColor Yellow
    }

    Write-Host "Windows 11 VM '$VMName' created successfully!" -ForegroundColor Green
    Write-Host "VM Specifications:" -ForegroundColor Cyan
    Write-Host "  - Memory: $MemoryGB GB" -ForegroundColor Cyan
    Write-Host "  - Processors: $ProcessorCount" -ForegroundColor Cyan
    Write-Host "  - Disk Size: $DiskSizeGB GB" -ForegroundColor Cyan
    Write-Host "  - Network: $($vmSwitch.Name)" -ForegroundColor Cyan

    if ($useOriginalIso) {
        Write-Host "Note: Using original ISO without unattended setup. You'll need to complete the Windows installation manually." -ForegroundColor Yellow
    }
}

function Main {
    $systemInfo = Get-ComputerInfo
    if (-not $systemInfo.HyperVisorPresent) {
        Write-Host "Hardware virtualization might not be enabled in your BIOS/UEFI." -ForegroundColor Red
        Write-Host "Please enable virtualization in your system BIOS/UEFI settings and try again." -ForegroundColor Yellow
        return
    }

    Write-Host "Hyper-V Installation for Windows 11" -ForegroundColor Green

    if (-not (Test-Windows11)) {
        Write-Host "This script is designed for Windows 11. Your system appears to be running an older version of Windows. Quitting." -ForegroundColor Red
        return
    }

    if (Test-HyperVInstalled) {
        Write-Host "Hyper-V is already installed on this system." -ForegroundColor Yellow
    }
    else {
        Install-HyperV

        Write-Host "Please restart your computer to complete Hyper-V installation." -ForegroundColor Yellow
        Write-Host "After restart, run this script again to configure Hyper-V." -ForegroundColor Yellow
    }

    Set-HyperVConfiguration
    Install-Windows11VM
}

Main
