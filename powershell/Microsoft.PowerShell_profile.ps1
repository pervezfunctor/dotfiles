# PowerShell Profile Configuration

# PSReadLine configuration for autosuggestions and syntax highlighting
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    # Prediction options require PSReadLine 2.1+ and a terminal that supports VT.
    if ((Get-Module PSReadLine).Version -ge [version]'2.1' -and $Host.UI.SupportsVirtualTerminal) {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
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

foreach ($module in 'posh-git', 'Terminal-Icons', 'PSFzf') {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module $module
    }
}

# Initialize the prompt after posh-git so Starship remains in control of prompt rendering.
if ($env:TERM -ne 'dumb' -and (Get-Command starship -ErrorAction SilentlyContinue)) {
    Invoke-Expression (&starship init powershell)
}

# Common PowerShell aliases
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias vim nvim
    Set-Alias vi nvim
    Set-Alias v nvim
}
if (Get-Command git -ErrorAction SilentlyContinue) { Set-Alias g git }
Set-Alias grep Select-String
Set-Alias ll Get-ChildItem

# Environment variables
$editor = @('nvim', 'vim', 'notepad') | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue } | Select-Object -First 1
if ($editor) {
    $env:EDITOR = $editor
    $env:VISUAL = $editor
}

# Add LLVM/Clang to PATH
$llvmPath = "C:\Program Files\LLVM\bin"
if ((Test-Path $llvmPath) -and (($env:PATH -split ';') -notcontains $llvmPath)) {
    $env:PATH = "$llvmPath;$env:PATH"
}

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

# Familiar zsh/fish navigation shortcuts (PowerShell aliases cannot contain dots).
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

function gst { git status @args }
function gsu { git status -u @args }
function gia { git add @args }
function gco { git checkout @args }
function gb { git branch @args }
function gfm { git pull @args }

# Modern file listing and viewing, matching the Linux shell configuration.
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    Remove-Item Alias:ll -Force -ErrorAction SilentlyContinue
    function ls { eza --icons=auto --group-directories-first @args }
    function ll { eza -la --icons=auto --group-directories-first --git @args }
    function lt { eza --tree --level=2 --icons=auto --group-directories-first --git @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias b bat
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function cat { bat @args }
}

# Common Docker shortcuts from the zsh/fish workflow.
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Set-Alias d docker
    function dco { docker compose @args }
    function dps { docker ps @args }
    function dpa { docker ps -a @args }
    function dx { docker exec -it @args }
    function dlogs { docker logs -f @args }
}
if (Get-Command lazygit -ErrorAction SilentlyContinue) { Set-Alias lzg lazygit }
if (Get-Command lazydocker -ErrorAction SilentlyContinue) { Set-Alias lzd lazydocker }

# pnpm shortcuts keep their native argument handling through wrapper functions.
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    Set-Alias n pnpm
    # `ni` is PowerShell's built-in New-Item alias and otherwise wins over our function.
    Remove-Item Alias:ni -Force -ErrorAction SilentlyContinue
    function ni { pnpm install @args }
    function nid { pnpm install --save-dev @args }
    function nb { pnpm build @args }
    function ne { pnpm exec @args }
    function nd { pnpm dev @args }
    function nt { pnpm types @args }
    function ntt { pnpm test @args }
}

if (Get-Module PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
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

# Helper function to edit PowerShell profile
function Edit-Profile {
    if (!(Test-Path $PROFILE)) {
        New-Item -Type File -Path $PROFILE -Force
    }
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code $PROFILE
    }
    else {
        & $env:EDITOR $PROFILE
    }
}
Set-Alias -Name ep -Value Edit-Profile


