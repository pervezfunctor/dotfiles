# Nushell Environment Config File

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

$env.XDG_CONFIG_HOME = ($nu.home-path | path join ".config")

$env.config.show_banner = false

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
use std "path add"
# $env.PATH = ($env.PATH | split row (char esep))
# path add /some/path
# path add ($env.CARGO_HOME | path join "bin")
# path add ($env.HOME | path join ".local" "bin")
# $env.PATH = ($env.PATH | uniq)
# path add /opt/homebrew/bin

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

zoxide init nushell | save -f ~/.zoxide.nu

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

$env.GOPATH = ($nu.home-path | path join "go")

$env.PATH = ($env.PATH | prepend [
    "/usr/bin"
    "/snap/bin"
    ($env.GOPATH | path join "bin")
    ($env.XDG_CONFIG_HOME | path join "emacs/bin")
    ($nu.home-path | path join ".local/bin")
    ($nu.home-path | path join "bin")
    ($nu.home-path | path join ".bin")
    ($nu.home-path | path join ".ilm/bin")
    ($nu.home-path | path join "Applications")
    ($nu.home-path | path join ".local/share/pypoetry")
    ($env.XDG_CONFIG_HOME | path join "Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin")
    ($nu.home-path | path join ".console-ninja/.bin")
])

$env.GOPATH = ($nu.home-path | path join "go")

$env.MANPAGER = "nvim +Man!"

# Set environment variables
$env.LANG = "en_US.UTF-8"
$env.HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK = "1"
$env.ELECTRON_OZONE_PLATFORM_HINT = "auto"

$env.PATH = ($env.PATH | prepend [
    "/opt/homebrew/bin"
    "/home/linuxbrew/.linuxbrew/bin"
])

# Add LLVM/Clang to PATH
$env.PATH = ($env.PATH | prepend [
    "C:\\Program Files\\LLVM\\bin"
])
