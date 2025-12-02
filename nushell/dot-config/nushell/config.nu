$env.DOT_DIR = ($nu.home-path | path join ".ilm")

if ($env.XDG_CONFIG_HOME? | is-empty) {
  $env.XDG_CONFIG_HOME = ($nu.home-path | path join ".config")
}
if ($env.XDG_DATA_HOME? | is-empty) {
  $env.XDG_DATA_HOME = ($nu.home-path | path join ".local/share")
}
if ($env.XDG_CACHE_HOME? | is-empty) {
  $env.XDG_CACHE_HOME = ($nu.home-path | path join ".cache")
}
if ($env.XDG_STATE_HOME? | is-empty) {
  $env.XDG_STATE_HOME = ($nu.home-path | path join ".local/state")
}


def has-cmd [cmd: string] {
  (which $cmd | describe) != "nothing"
}

const is_linux = ($nu.os-info.name == "linux")
const is_mac = ($nu.os-info.name == "macos")


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

$env.GOPATH = ($nu.home-path | path join "go")
$env."VOLTA_HOME" = ($nu.home-path | path join ".volta")
$env.LIBVIRT_DEFAULT_URI = "qemu:///system"

path add /snap/bin
path add ($env.GOPATH | path join "bin")
path add ($env.XDG_CONFIG_HOME | path join "emacs/bin")
path add ($nu.home-path | path join ".local/bin")
path add ($nu.home-path | path join "bin")
path add ($nu.home-path | path join ".bin")
path add ($env.DOT_DIR | path join "bin")
path add ($env.DOT_DIR | path join "bin/vt")
path add ($nu.home-path | path join ".cargo/env")
path add ($nu.home-path | path join "Applications")
path add ($nu.home-path | path join ".local/share/pypoetry")
path add ($env.XDG_CONFIG_HOME | path join "Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin")
path add ($nu.home-path | path join ".console-ninja/.bin")


if ('/opt/homebrew/bin/brew' | path exists) {
  path add /opt/homebrew/bin
} else if ('/usr/local/bin/brew' | path exists) {
  path add /usr/local/bin
} else if ('/home/linuxbrew/.linuxbrew/bin/brew' | path exists) {
  path add /home/linuxbrew/.linuxbrew/bin
}

$env.MANPAGER = "nvim +Man!"

# Set environment variables
$env.LANG = "en_US.UTF-8"
$env.HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK = "1"
$env.ELECTRON_OZONE_PLATFORM_HINT = "auto"

alias open = xdg-open

def pbcopy [] {
  if ($env.XDG_SESSION_TYPE == "wayland") {
    wl-copy
  } else {
    xsel --clipboard --input
  }
}

def pbpaste [] {
  if ($env.XDG_SESSION_TYPE == "wayland") {
    wl-paste --no-newline
  } else {
    xsel --clipboard --output
  }
}

alias m = mkdir
alias e = emacsclient -t
alias ec = emacsclient -c -n
alias en = emacs -nw
alias ff = fzf --preview 'bat --style=numbers --color=always {}'
alias fv = fzf --bind 'enter:become(vim {})'

# Base aliases
alias g = git
alias gp = git push
alias gs = git stash -u
alias gst = git status
alias gsu = git status -u
alias gsa = git stash apply
alias gfm = git pull
alias gco = git checkout
alias gb = git branch
alias gbc = git checkout -b
alias gia = git add

# Commit aliases
alias gcm = git commit --message
alias gcne = git commit --no-edit
alias gca = git commit --amend
alias gcan = git commit --amend --no-edit
alias Gcm = git commit --no-verify -m
alias Gcan = git commit --amend --no-edit --no-verify

# Git reset / discard helpers
alias git-unstage = git reset HEAD
alias git-discard = git checkout --

alias gun = git-unstage
alias gur = git-discard

# Git stash, pull, and rebase (safe pull)
alias tsgfm = do {
  git stash
  (git pull --rebase | complete; if ($env.LAST_EXIT_CODE != 0) { git pull })
  git stash pop
}

# Custom pretty log
alias gl = git log --topo-order --pretty=format:"%C(yellow)%h%C(reset)%C(black)%d%C(reset) %C(cyan)%ar%C(reset) %C(green)%an%C(reset)%n%C(white)%s%C(reset)"
alias glog = git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit

# GitHub clone
alias clone = gh repo clone

alias c = code
alias c. = code .
alias cs = code --password-store=gnome-libsecret

alias nm = nmap -sC -sV -oN
alias v = nvim
alias t = tmux


alias la = tree
alias lm = do { tree | $env.PAGER }
alias lr = ll -R
alias lc = lt -c
alias lu = lt -u
alias sl = ls  # Typo helper

alias d = docker
alias dco = docker compose
alias dps = docker ps
alias dpa = docker ps -a
alias dl = docker ps -l -q
alias dx = docker exec -it
alias dlogs = docker logs -f
alias lzg = lazygit
alias lzd = lazydocker

alias dt = distrobox
alias dte = distrobox enter -nw --clean-path
alias dtl = distrobox list
alias dtr = distrobox run
alias dtc = distrobox create
alias dtd = distrobox rm

alias rdte = distrobox enter -nw --clean-path --root
alias rdtl = distrobox list --root
alias rdtr = distrobox run --root
alias rdtc = distrobox create --root
alias rdtd = distrobox rm --root

alias n = pnpm
alias ni = pnpm install
alias nid = pnpm install -D
alias nb = pnpm build
alias nl = pnpm lint:dev
alias ne = pnpm exec
alias nd = pnpm dev
alias nc = pnpm ci
alias nt = pnpm types:dev
alias ntc = pnpm types
alias ntt = pnpm test:dev
alias nttc = pnpm test:dev
alias nci = pnpm types and pnpm lint
alias ndb = pnpm db
alias ndbt = pnpm db:types
alias ndbp = pnpm db:push
alias ndbs = pnpm db:seed
alias ndbst = pnpm db:studio
alias ndbr = pnpm db:repl

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
source ~/.cache/carapace/init.nu

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
