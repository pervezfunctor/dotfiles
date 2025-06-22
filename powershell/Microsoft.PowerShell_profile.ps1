# PowerShell Profile Configuration

# Initialize Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# PSReadLine configuration for autosuggestions and syntax highlighting
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    # Set-PSReadLineOption -PredictionSource History
    # Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -Colors @{
        Command   = 'Cyan'
        Parameter = 'DarkCyan'
        Operator  = 'DarkGreen'
        Variable  = 'DarkGreen'
        String    = 'DarkYellow'
        Number    = 'DarkGreen'
        Member    = 'DarkGreen'
        Type      = 'DarkYellow'
        Comment   = 'DarkGray'
        # InlinePrediction = 'DarkGray'
    }
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Common PowerShell aliases
Set-Alias -Name vim -Value nvim -ErrorAction SilentlyContinue
Set-Alias -Name vi -Value nvim -ErrorAction SilentlyContinue
Set-Alias -Name g -Value git -ErrorAction SilentlyContinue
Set-Alias -Name grep -Value Select-String -ErrorAction SilentlyContinue
Set-Alias -Name ll -Value Get-ChildItem -ErrorAction SilentlyContinue

# Environment variables
$env:EDITOR = "nvim"

# Add LLVM/Clang to PATH
$env:PATH = "C:\Program Files\LLVM\bin;" + $env:PATH

# Helper functions
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function touch($file) {
    if (Test-Path $file) {
        (Get-Item $file).LastWriteTime = Get-Date
    }
    else {
        New-Item -ItemType File -Path $file
    }
}

# Initialize zoxide if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Initialize carapace if available
if (Get-Command carapace -ErrorAction SilentlyContinue) {
    $env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    Invoke-Expression (& { (carapace _carapace powershell | Out-String) })
}

# Load local profile if it exists
$localProfile = Join-Path $env:USERPROFILE ".localprofile.ps1"
if (Test-Path $localProfile) {
    . $localProfile
}

# Source another PS1 file
# . "$env:USERPROFILE\.ilm\powershell\functions.ps1"

# Print welcome message
Write-Host "PowerShell profile loaded successfully!" -ForegroundColor Green

# Helper function to edit PowerShell profile
function Edit-Profile {
    if (!(Test-Path $PROFILE)) {
        New-Item -Type File -Path $PROFILE -Force
    }
    code $PROFILE
}
Set-Alias -Name ep -Value Edit-Profile


