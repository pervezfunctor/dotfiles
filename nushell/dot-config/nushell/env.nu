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

$env.PATH = ($env.PATH | prepend [
    "/usr/bin"
    "/snap/bin"
    ($env.GOPATH | path join "bin")
    ($env.XDG_CONFIG_HOME | path join "emacs/bin")
    ($env.HOME | path join ".local/bin")
    ($env.HOME | path join "bin")
    ($env.HOME | path join ".bin")
    ($env.HOME | path join ".ilm/bin")
    ($env.HOME | path join "Applications")
    ($env.HOME | path join ".local/share/pypoetry")
    ($env.XDG_CONFIG_HOME | path join "Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin")
    ($env.HOME | path join ".console-ninja/.bin")
])

$env.GOPATH = ($env.HOME | path join "go")

$env.MANPAGER = "nvim +Man!"

# Set environment variables
$env.LANG = "en_US.UTF-8"
$env.HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK = "1"
$env.ELECTRON_OZONE_PLATFORM_HINT = "auto"

let homebrew_mac = "/opt/homebrew/bin/brew"
let homebrew_linux = "/home/linuxbrew/.linuxbrew/bin/brew"

if ($homebrew_mac | path exists) {
    ^$homebrew_mac shellenv | lines | parse "export {name}={value}" | each { |it|
        load-env { $it.name: ($it.value | str replace -a '"' '') }
    }
} else if ($homebrew_linux | path exists) {
    ^$homebrew_linux shellenv | lines | parse "export {name}={value}" | each { |it|
        load-env { $it.name: ($it.value | str replace -a '"' '') }
    }
}
