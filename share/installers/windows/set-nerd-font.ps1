function Set-WindowsTerminalDefaults {
    param (
        [string]$FontFace = "JetBrainsMono Nerd Font",
        [string]$ColorScheme = "One Half Dark",
        [double]$Opacity = 0.97,
        [string]$ProfileName = "", # Empty string means apply to defaults
        [switch]$SetAsDefault = $false
    )

    # Check multiple possible locations for Windows Terminal settings
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )

    $settingsPath = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-Not $settingsPath) {
        Write-Error "Windows Terminal settings.json not found in any of the expected locations"
        return
    }

    # Create backup of existing settings
    $backupPath = "$settingsPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    try {
        Copy-Item -Path $settingsPath -Destination $backupPath -Force
        Write-Host "Created backup of settings at $backupPath" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Failed to create backup of settings: $_"
        return
    }

    try {
        # Read and parse the JSON
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

        # Validate JSON structure
        if ($null -eq $settings) {
            Write-Error "Invalid settings file: Could not parse JSON"
            return
        }

        # Ensure the profiles section exists
        if ($null -eq $settings.profiles) {
            $settings | Add-Member -MemberType NoteProperty -Name profiles -Value @{}
        }

        # Determine if we're updating a specific profile or the defaults
        if ([string]::IsNullOrEmpty($ProfileName)) {
            # Ensure the defaults section exists
            if ($null -eq $settings.profiles.defaults) {
                $settings.profiles | Add-Member -MemberType NoteProperty -Name defaults -Value @{}
            }
            $targetProfile = $settings.profiles.defaults
            $targetDescription = "defaults"

            # Can't set defaults as default profile
            if ($SetAsDefault) {
                Write-Warning "Cannot set defaults as default profile. Ignoring SetAsDefault parameter."
                $SetAsDefault = $false
            }
        }
        else {
            # Ensure the list section exists
            if ($null -eq $settings.profiles.list) {
                $settings.profiles | Add-Member -MemberType NoteProperty -Name list -Value @()
            }

            # Find the specified profile
            $targetProfile = $settings.profiles.list | Where-Object { $_.name -eq $ProfileName } | Select-Object -First 1

            if ($null -eq $targetProfile) {
                Write-Error "Profile '$ProfileName' not found in Windows Terminal settings"
                return
            }

            $targetDescription = "profile '$ProfileName'"

            # Set as default profile if requested
            if ($SetAsDefault) {
                if ($null -eq $targetProfile.guid) {
                    Write-Error "Cannot set profile as default: Profile '$ProfileName' does not have a GUID"
                    $SetAsDefault = $false
                }
                else {
                    $settings.defaultProfile = $targetProfile.guid
                }
            }
        }

        # Set font settings
        if ($null -eq $targetProfile.font) {
            $targetProfile | Add-Member -MemberType NoteProperty -Name font -Value @{ face = $FontFace }
        }
        else {
            $targetProfile.font.face = $FontFace
        }

        # Set color scheme
        $targetProfile.colorScheme = $ColorScheme

        # Set opacity/transparency
        $targetProfile.opacity = $Opacity

        # Enable acrylic effect
        # $targetProfile.useAcrylic = $false

        # Validate settings before saving
        try {
            $testJson = $settings | ConvertTo-Json -Depth 32 -ErrorAction Stop
            if ([string]::IsNullOrWhiteSpace($testJson)) {
                throw "Generated JSON is empty or invalid"
            }
        }
        catch {
            Write-Error "Failed to validate settings: $_"
            Write-Host "Restoring from backup..." -ForegroundColor Yellow
            Copy-Item -Path $backupPath -Destination $settingsPath -Force
            return
        }

        # Save the updated JSON with proper formatting
        $settings | ConvertTo-Json -Depth 32 | Set-Content $settingsPath -Encoding UTF8

        Write-Host "Updated Windows Terminal ${targetDescription}:" -ForegroundColor Green
        Write-Host "  - Font: $FontFace" -ForegroundColor Green
        Write-Host "  - Color Scheme: $ColorScheme" -ForegroundColor Green
        Write-Host "  - Opacity: $(($Opacity * 100).ToString())%" -ForegroundColor Green

        if ($SetAsDefault) {
            Write-Host "  - Set as default profile: Yes" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "Failed to update Windows Terminal settings: $_"
        Write-Host "Restoring from backup..." -ForegroundColor Yellow
        Copy-Item -Path $backupPath -Destination $settingsPath -Force
    }
}

function Set-NerdFont {
    param (
        [string]$FontFace = "JetBrainsMono Nerd Font",
        [string]$ProfileName = "",
        [switch]$SetAsDefault = $false
    )

    Set-WindowsTerminalDefaults -FontFace $FontFace -ProfileName $ProfileName -SetAsDefault:$SetAsDefault
}

# Export the functions if the script is imported as a module
Export-ModuleMember -Function Set-WindowsTerminalDefaults

# Examples:
# Set Windows Terminal defaults
# Set-WindowsTerminalDefaults -FontFace "JetBrainsMono Nerd Font" -ColorScheme "One Half Dark" -Opacity 0.97

# Set specific profile
# Set-WindowsTerminalDefaults -FontFace "JetBrainsMono Nerd Font" -ColorScheme "One Half Dark" -Opacity 0.97 -ProfileName "PowerShell"

# Set specific profile and make it the default
# Set-WindowsTerminalDefaults -FontFace "JetBrainsMono Nerd Font" -ColorScheme "One Half Dark" -Opacity 0.97 -ProfileName "PowerShell" -SetAsDefault
