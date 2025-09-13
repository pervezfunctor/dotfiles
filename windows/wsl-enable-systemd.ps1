function Set-WslSystemdSupport {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Distro
    )

    if (-not (Test-WslDistroExists -Distro $Distro)) {
        throw "WSL Distro '$Distro' not found. Use 'wsl --list' to see available distributions."
    }

    if ($PSCmdlet.ShouldProcess("WSL Distro: $Distro", "Configure systemd via /etc/wsl.conf")) {
        try {
            Invoke-SystemdConfiguration -Distro $Distro

            Write-Host "✅ systemd configuration ensured in /etc/wsl.conf for '$Distro'" -ForegroundColor Green

            # Prompt user to restart WSL
            Write-Warning "WSL must be restarted for changes to take effect."
            Write-Host "🔄 Run the following command when ready:" -ForegroundColor Yellow
            Write-Host "   wsl --shutdown" -ForegroundColor Cyan
            Write-Host "   Then start your distro again with:" -ForegroundColor Yellow
            Write-Host "   wsl -d $Distro" -ForegroundColor Cyan
        }
        catch {
            throw "Failed to configure systemd for distro '$Distro': $($_.Exception.Message)"
        }
    }
}

function Test-WslDistroExists {
    param(
        [string]$Distro
    )
    $distros = wsl --list --quiet 2>$null | ForEach-Object { $_.Trim() }
    return $distros -contains $Distro
}

function Invoke-SystemdConfiguration {
    param(
        [string]$Distro
    )

    $script = @'
mkdir -p /etc
if [ -f /etc/wsl.conf ]; then
    if grep -q "^\[boot\]" /etc/wsl.conf; then
        # Section [boot] exists; update or add systemd=true
        if grep -q "^systemd=" /etc/wsl.conf; then
            sed -i 's/^systemd=.*/systemd=true/' /etc/wsl.conf
        else
            sed -i '/^\[boot\]/a systemd=true' /etc/wsl.conf
        fi
    else
        # No [boot] section, append it
        printf '\n[boot]\nsystemd=true\n' >> /etc/wsl.conf
    fi
else
    # Create new wsl.conf with [boot] and systemd=true
    printf '[boot]\nsystemd=true\n' > /etc/wsl.conf
fi
'@

    # Run script in target distro as root
    $process = Start-Process -FilePath "wsl" -ArgumentList "-d", "$Distro", "--user", "root", "bash", "-c", $script -PassThru -NoNewWindow -Wait

    if ($process.ExitCode -ne 0) {
        throw "Script failed with exit code $($process.ExitCode)"
    }
}

# Optional: Export functions if used in a module
# Export-ModuleMember -Function Set-WslSystemdSupport
