#! /usr/bin/env nu

# Common installer functions - shared across all platforms

use ../share/utils.nu *

# Homebrew installation
export def brew-install []: nothing -> nothing {
    if (has-cmd brew) {
        return
    }

    slog "Installing homebrew"
    let env_vars = { NONINTERACTIVE: 1 }
    with-env $env_vars {
        bash -c "$(curl -sSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }

    eval-brew

    if not (has-cmd brew) {
        warn "homebrew not installed, trying again, might require sudo password"
        bash -c "$(curl -sSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval-brew

        if (has-cmd brew) {
            slog "homebrew installation done!"
        } else {
            warn "homebrew installation failed"
        }
    }

    if (is-linux) {
        dir-check /home/linuxbrew/.linuxbrew
    } else if (is-mac) {
        dir-check /opt/homebrew
    }

    cmd-check brew
}

# Mise shell tools installation
export def mise-shell-install []: nothing -> nothing {
    slog "shell tools with mise"

    mis just lazygit lazydocker starship ripgrep gdu choose yazi
    mis shellcheck gum xh bottom fzf hyperfine cheat duf eza dust zoxide

    mi superfile

    if not (has-cmd nu) {
        mise use -g cargo:nu
    }

    slog "shell tools with mise done!"
}

# Brew shell-slim installation
export def brew-shell-slim-install []: nothing -> nothing {
    if not (has-cmd brew) {
        warn "brew not installed; skipping shell utilities installation."
        return
    }

    if (is-linux) {
        brew tap ublue-os/tap
    }

    bis gh stow tmux fzf zoxide starship eza
    bi bash-preexec

    let pkgs = []
    let pkgs = if not (has-cmd trash) {
        $pkgs | append trash-cli
    } else {
        $pkgs
    }

    if ($pkgs | length) > 0 {
        bis ...$pkgs
    }
}

# Brew shell installation
export def brew-shell-install []: nothing -> nothing {
    slog "shell tools with brew"

    brew-shell-slim-install

    bis jq just shfmt shellcheck lazydocker broot cheat curlie duf sd xh doggo atuin direnv dust procs hyperfine pixi yq htop dysk lsd whalebrew yazi ollama carapace lazygit fd luarocks runme act mask devcontainer gum nixfmt pass tailscale age imagemagick tmuxp mcat

    let pkgs = []
    let pkgs = if not (has-cmd bw) { $pkgs | append bitwarden-cli } else { $pkgs }
    let pkgs = if not (has-cmd whiptail) { $pkgs | append newt } else { $pkgs }
    let pkgs = if not (has-cmd tv) { $pkgs | append television } else { $pkgs }
    let pkgs = if not (has-cmd ug) { $pkgs | append ugrep } else { $pkgs }
    let pkgs = if not (has-cmd nvim) { $pkgs | append neovim } else { $pkgs }
    let pkgs = if not (has-cmd spf) { $pkgs | append superfile } else { $pkgs }
    let pkgs = if not (has-cmd gdu) and not (has-cmd gdu-go) { $pkgs | append gdu } else { $pkgs }
    let pkgs = if not (has-cmd tldr) { $pkgs | append tealdeer } else { $pkgs }
    let pkgs = if not (has-cmd choose) { $pkgs | append choose-rust } else { $pkgs }
    let pkgs = if not (has-cmd btm) { $pkgs | append bottom } else { $pkgs }
    let pkgs = if not (has-cmd nu) { $pkgs | append nushell } else { $pkgs }
    let pkgs = if not (has-cmd delta) { $pkgs | append git-delta } else { $pkgs }
    let pkgs = if not (has-cmd rg) { $pkgs | append ripgrep } else { $pkgs }
    let pkgs = if not (has-cmd batcat) and not (has-cmd bat) { $pkgs | append bat } else { $pkgs }
    let pkgs = if not (has-cmd micro) { $pkgs | append micro } else { $pkgs }
    let pkgs = if not (has-cmd llama-server) { $pkgs | append llama.cpp } else { $pkgs }

    if ($pkgs | length) > 0 {
        bis ...$pkgs
    }

    if (is-linux) {
        brew install stress-ng topgrade
    }

    if (has-cmd tldr) {
        tldr --update
    }

    bi Valkyrie00/homebrew-bbrew/bbrew

    slog "shell tools with brew done!"
}

# Pixi shell-slim installation
export def pixi-shell-slim-install []: nothing -> nothing {
    if not (has-cmd trash) {
        pi trash-cli
    }
    if not (has-cmd rg) {
        pi ripgrep
    }
    if not (has-cmd gum) {
        pi go-gum
    }
    if not (has-cmd whiptail) {
        pi newt
    }
    pis micro starship zoxide gh fzf eza
}

# Pixi shell installation
export def pixi-shell-install []: nothing -> nothing {
    pixi-shell-slim-install

    pis broot just lazydocker gdu nvim lazygit luarocks micro glances mask cheat curlie duf sd xh atuin dust procs hyperfine htop jq yazi act carapace direnv yq bat shellcheck fd git-delta jq yq go-shfmt

    let pkgs = []
    let pkgs = if not (has-cmd ug) { $pkgs | append ugrep } else { $pkgs }
    let pkgs = if not (has-cmd tldr) { $pkgs | append tealdeer } else { $pkgs }
    let pkgs = if not (has-cmd tv) { $pkgs | append television } else { $pkgs }
    let pkgs = if not (has-cmd spf) { $pkgs | append superfile } else { $pkgs }
    let pkgs = if not (has-cmd choose) { $pkgs | append choose-rust } else { $pkgs }
    let pkgs = if not (has-cmd btm) { $pkgs | append bottom } else { $pkgs }
    let pkgs = if not (has-cmd nu) { $pkgs | append nushell } else { $pkgs }
    if not (has-cmd shfmt) {
        pi go-shfmt
    }

    if ($pkgs | length) > 0 {
        pis ...$pkgs
    }
}

# Go shell tools installation
export def go-shell-install []: nothing -> nothing {
    if not (has-cmd go) {
        return
    }

    slog "shell tools with go"

    if not (has-cmd cheat) {
        go install github.com/cheat/cheat/cmd/cheat@latest
    }
    if not (has-cmd curlie) {
        go install github.com/rs/curlie@latest
    }
    if not (has-cmd lazygit) {
        go install github.com/jesseduffield/lazygit@latest
    }
    if not (has-cmd gdu) {
        go install github.com/dundee/gdu/v5/cmd/gdu@latest
    }
    if not (has-cmd duf) {
        go install github.com/muesli/duf@latest
    }

    slog "shell tools with go done!"

    cmd-check cheat curlie lazygit gdu duf
}

# Rust shell tools installation
export def rust-shell-install []: nothing -> nothing {
    if not (has-cmd rustup) {
        return
    }

    rustup update stable

    slog "shell tools with rust"

    if not (has-cmd starship) { cargoi starship }
    if not (has-cmd delta) { cargoi git-delta }
    if not (has-cmd dust) { cargoi du-dust }
    if not (has-cmd choose) { cargoi choose }
    if not (has-cmd sd) { cargoi sd }
    if not (has-cmd procs) { cargoi procs }
    if not (has-cmd btm) { cargoi bottom }
    if not (has-cmd xh) { cargoi xh }

    slog "shell tools with rust done!"

    cmd-check starship delta dust choose sd procs btm xh lsd
}

# NPM shell tools installation
export def npm-shell-install []: nothing -> nothing {
    if not (has-cmd npm) {
        return
    }

    slog "shell tools with npm"
    npm install -g degit neovim
    cmd-check degit
}

# Webi shell tools installation
export def webi-shell-install []: nothing -> nothing {
    wis shfmt gh dotenv bat curlie delta fd jq lsd sd yq rg arc fzf shellcheck
}

# Miniconda installation
export def miniconda-install []: nothing -> nothing {
    if (has-cmd conda) {
        return
    }
    if (dir-exists ~/miniconda3) {
        return
    }

    slog "Installing miniconda"

    smd ~/miniconda3
    download-to https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -u -p ~/miniconda3
    frm /tmp/miniconda.sh

    if (has-cmd bash) {
        ~/miniconda3/bin/conda init bash
    }
    if (has-cmd zsh) {
        ~/miniconda3/bin/conda init zsh
    }

    slog "miniconda installation done!"

    cmd-check conda
}

# Check if bash config exists
export def bash-config-exists []: nothing -> bool {
    let bashrc = ~/.bashrc | path expand
    if not ($bashrc | path exists) {
        return false
    }

    let content = open $bashrc
    ($content | str contains ".ilm/share/bashrc") or ($content | str contains "source ${DOT_DIR}/share/bashrc")
}

# Bash configuration installation
export def bash-confstall []: nothing -> nothing {
    slog "Configuring bash"

    if not (bash-config-exists) {
        echo $"export DOT_DIR=($env.DOT_DIR)" >> ~/.bashrc
        echo 'source ${DOT_DIR}/share/bashrc' >> ~/.bashrc
    }

    slog "bash config done!"
}

# Check if zsh config exists
export def zsh-config-exists []: nothing -> bool {
    let zshrc = ~/.zshrc | path expand
    if not ($zshrc | path exists) {
        return false
    }

    let content = open $zshrc
    ($content | str contains ".ilm/share/dot-zshrc") or ($content | str contains "source ${DOT_DIR}/share/dot-zshrc")
}

# Zsh minimal configuration
export def zsh-min-confstall []: nothing -> nothing {
    if not (file-exists ~/.zshrc) {
        warn "$HOME/.zshrc doesn't exist, skipping zsh config"
        return
    }

    slog "Configuring zsh"

    if not (zsh-config-exists) {
        echo $"export DOT_DIR=($env.DOT_DIR)" >> ~/.zshrc
        echo 'source ${DOT_DIR}/share/dot-zshrc' >> ~/.zshrc
    }

    slog "zsh config done!"
}

# Zsh full configuration
export def zsh-confstall []: nothing -> nothing {
    slog "zsh config"

    srm ~/.zshrc
    smd ~/.zsh
    sclone https://github.com/sindresorhus/pure.git ~/.zsh/pure --depth 1
    sclone https://github.com/djui/alias-tips.git ~/.zsh/alias-tips --depth 1
    sclone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions --depth 1
    sclone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting --depth 1

    if (has-cmd stow) {
        stowdf zsh
    } else {
        # zsh-boxstall equivalent
        srm ~/.zshrc
        fln ($env.DOT_DIR | path join "zsh" "dot-zshrc") ~/.zshrc
    }

    slog "zsh config done!"
}

# Tmux configuration
export def tmux-confstall []: nothing -> nothing {
    slog "tmux config"

    srm ($env.XDG_CONFIG_HOME | path join "tmux")

    if (has-cmd stow) {
        stownf tmux
    } else {
        # tmux-boxstall equivalent
        srm ~/.config/tmux
        smd ~/.config/tmux
        smd ~/.tmux
        fln ($env.DOT_DIR | path join "tmux" "dot-config" "tmux" "tmux.conf") ~/.config/tmux/tmux.conf
    }

    slog "tmux config done!"
}

# VSCode extensions from file
export def vscode-extensions-from-file [extensions_file: string]: nothing -> nothing {
    if not (file-exists $extensions_file) {
        warn $"Extensions file not found at: ($extensions_file)"
        return
    }

    let installed_extensions = if (has-cmd code) {
        ^code --list-extensions | lines
    } else {
        []
    }

    open $extensions_file
    | lines
    | where { |line| not ($line | str starts-with "#") and ($line | str trim | is-not-empty) }
    | each { |extension|
        let ext_trimmed = $extension | str trim
        if not ($ext_trimmed in $installed_extensions) {
            slog $"Installing extension: ($ext_trimmed)"
            if (has-cmd code) {
                code --install-extension $ext_trimmed
            }
            if (has-cmd code-insiders) {
                code-insiders --install-extension $ext_trimmed
            }
            if (has-cmd flatpak) and (flatpak list | str contains "com.visualstudio.code") {
                flatpak run com.visualstudio.code --install-extension $ext_trimmed
            }
        } else {
            slog $"Extension already installed: ($ext_trimmed)"
        }
    }
}

# VSCode extensions installation
export def vscode-extensions-install []: nothing -> nothing {
    slog "Installing vscode extensions"

    let extensions_file = if $env.USER == "pervez" {
        $env.DOT_DIR | path join "extras" "vscode" "extensions" "common"
    } else {
        $env.DOT_DIR | path join "extras" "vscode" "extensions" "default"
    }

    vscode-extensions-from-file $extensions_file

    slog "vscode extensions installation done!"
}

# VSCode all extensions installation
export def vscode-all-extensions-install []: nothing -> nothing {
    slog "Installing all vscode extensions"

    vscode-extensions-from-file ($env.DOT_DIR | path join "extras" "vscode" "extensions" "common")
    vscode-extensions-from-file ($env.DOT_DIR | path join "extras" "vscode" "extensions" "cpp")
    vscode-extensions-from-file ($env.DOT_DIR | path join "extras" "vscode" "extensions" "prog")
    vscode-extensions-from-file ($env.DOT_DIR | path join "extras" "vscode" "extensions" "python")
    vscode-extensions-from-file ($env.DOT_DIR | path join "extras" "vscode" "extensions" "web")

    slog "vscode extensions installation done!"
}

# Doom Emacs configuration
export def emacs-doom-confstall []: nothing -> nothing {
    if (dir-exists ($env.XDG_CONFIG_HOME | path join "doom")) {
        return
    }

    slog "Installing doom"

    sclone https://github.com/doomemacs/doomemacs ($env.XDG_CONFIG_HOME | path join "emacs") --depth 1
    sclone https://github.com/pervezfunctor/doomemacs-config ($env.XDG_CONFIG_HOME | path join "doom")

    slog "Configure doom"
    doom sync
    doom env

    slog "doom installation done!"

    if (has-cmd update-locale) {
        sudo update-locale LANG=en_US.UTF8
    }
}

# Emacs configuration
export def emacs-confstall []: nothing -> nothing {
    slog "emacs config"

    srm ($env.XDG_CONFIG_HOME | path join "emacs")
    smd ($env.XDG_CONFIG_HOME | path join "emacs")
    stowdf emacs

    slog "emacs config done!"
}

# Emacs slim configuration
export def emacs-slim-confstall []: nothing -> nothing {
    slog "Installing slim emacs"

    srm ~/.emacs
    stowdf emacs-slim

    slog "emacs slim installation done!"
}

# Neovim cleanup
export def nvim-cleanup []: nothing -> nothing {
    frm ($env.XDG_CONFIG_HOME | path join "nvim.bak")
    omv ($env.XDG_CONFIG_HOME | path join "nvim") ($env.XDG_CONFIG_HOME | path join "nvim.bak")
    frm ~/.local/share/nvim
    frm ~/.local/state/nvim
    frm ~/.cache/nvim
}

# Neovim configuration
export def nvim-confstall [profile: string = "nvim"]: nothing -> nothing {
    slog "nvim config"

    nvim-cleanup

    stowgf $profile

    slog "nvim config done!"
}

# AstroVim configuration
export def astrovim-confstall [profile: string = "nvim"]: nothing -> nothing {
    slog "nvim config"

    let astrovim_dir = ~/.config/astrovim | path expand
    if not (dir-exists $astrovim_dir) {
        git clone --depth 1 https://github.com/AstroNvim/template ~/.config/astrovim
        frm ~/.config/nvim/.git
    }
    sln ~/.config/astrovim ~/.config/nvim

    slog "nvim config done!"
}

# LazyVim configuration
export def lazyvim-confstall []: nothing -> nothing {
    nvim-cleanup

    let lazyvim_dir = ~/.config/lazyvim | path expand
    if not (dir-exists $lazyvim_dir) {
        git clone --depth 1 https://github.com/LazyVim/starter ~/.config/lazyvim
        frm ~/.config/nvim/.git
    }
    sln ~/.config/lazyvim ~/.config/nvim | ignore
}

# Git configuration helper
export def git-conf [...args: string]: nothing -> nothing {
    git config --global ...$args
}

# SSH configuration
export def ssh-confstall []: nothing -> nothing {
    slog "Configuring ssh"
    stowdf ssh
    ssh-key-generate
    smd ~/.ssh/conf.d
    slog "ssh config done!"
}

# Git configuration
export def git-confstall []: nothing -> nothing {
    if not (has-cmd git) {
        warn "git not installed, skipping git config"
        return
    }

    slog "Configuring git"

    git-conf init.defaultBranch "main"
    git-conf pull.ff "only"
    git-conf delta.navigate "true"
    git-conf delta.line-numbers "true"
    git-conf delta.syntax-theme "Monokai Extended"
    git-conf delta.side-by-side "true"
    git-conf merge.conflictStyle "diff3"
    git-conf interactive.diffFilter "delta --color-only"
    git-conf fetch.prune "true"

    if $env.USER == "pervez" {
        git-conf user.name "Pervez Iqbal"
        git-conf user.email "pervefunctor@gmail.com"
    }

    slog "git configuration done!"
}

# VSCode configuration
export def vscode-confstall []: nothing -> nothing {
    if not (has-cmd code) {
        warn "code not installed; skipping vscode configuration"
        return
    }

    slog "vscode config"

    if (is-mac) {
        safe-cp ($env.DOT_DIR | path join "extras" "vscode" "minimal-settings.jsonc") ($env.HOME | path join "Library" "Application Support" "Code" "User" "settings.json")
    } else {
        let code_user_dir = $env.XDG_CONFIG_HOME | path join "Code" "User"
        smd $code_user_dir
        fmv ($code_user_dir | path join "settings.json") ($code_user_dir | path join "settings.json.bak")
        safe-cp ($env.DOT_DIR | path join "extras" "vscode" "minimal-settings.jsonc") ($code_user_dir | path join "settings.json")

        # Support code-insiders
        let insiders_dir = $env.XDG_CONFIG_HOME | path join "Code - Insiders" "User"
        if (dir-exists $insiders_dir) {
            fmv ($insiders_dir | path join "settings.json") ($insiders_dir | path join "settings.json.bak")
            safe-cp ($env.DOT_DIR | path join "extras" "vscode" "minimal-settings.jsonc") ($insiders_dir | path join "settings.json")
        }
    }

    vscode-extensions-install

    slog "vscode config done!"
}

# Shell configuration group
export def shell-confstall []: nothing -> nothing {
    bash-confstall
    if (has-cmd code) {
        vscode-confstall
    }

    if not (has-cmd stow) {
        warn "stow not installed, skipping config"
        return
    }

    if (has-cmd git) { git-confstall }
    if (has-cmd nvim) { nvim-confstall astro }
    if (has-cmd tmux) { tmux-confstall }
    if (has-cmd zsh) { zsh-confstall }

    if not (has-cmd emacs) {
        return
    }

    let emacs_version = (emacs --version | lines | first | split words | get 2 | split row "." | first | into int)
    if $emacs_version > 28 {
        emacs-confstall
    }
}

# Alacritty configuration
export def alacritty-confstall []: nothing -> nothing {
    slog "alacritty config"
    stowgf alacritty
    slog "alacritty config done!"
}

# WezTerm configuration
export def wezterm-confstall []: nothing -> nothing {
    slog "wezterm config"
    stowgf wezterm
    slog "wezterm config done!"
}

# Kitty configuration
export def kitty-confstall []: nothing -> nothing {
    slog "kitty config"
    stowgf kitty
    slog "kitty config done!"
}

# Ghostty configuration
export def ghostty-confstall []: nothing -> nothing {
    slog "ghostty config"
    stowgf ghostty
    slog "ghostty config done!"
}

# Atuin configuration
export def atuin-confstall []: nothing -> nothing {
    slog "atuin config"
    stowgf atuin
    slog "atuin config done!"
}

# Yazi configuration
export def yazi-confstall []: nothing -> nothing {
    slog "yazi config"

    srm ($env.XDG_CONFIG_HOME | path join "yazi")
    smd ($env.XDG_CONFIG_HOME | path join "yazi")
    stownf yazi

    # @TODO: use package.toml file to install flavors
    if (has-cmd ya) {
        ya pkg add yazi-rs/flavors:catppuccin-frappe
        ya pkg add yazi-rs/flavors:catppuccin-mocha
        ya pkg add yazi-rs/flavors:catppuccin-macchiato
        ya pkg upgrade
    }

    slog "yazi config done!"
}

# Bat configuration
export def bat-confstall []: nothing -> nothing {
    slog "bat config"
    stowgf bat
    bat cache --build
    slog "bat config done!"
}

# All configuration installation
export def all-confstall []: nothing -> nothing {
    shell-confstall

    if (has-cmd atuin) { atuin-confstall }
    if (has-cmd yazi) { yazi-confstall }
    if (has-cmd bat) { bat-confstall }

    if (has-cmd alacritty) { alacritty-confstall }
    if (has-cmd foot) { foot-confstall }
    if (has-cmd ghostty) { ghostty-confstall }
    if (has-cmd kitty) { kitty-confstall }
    if (has-cmd wezterm) { wezterm-confstall }

    # Mac specific
    if (has-cmd aerospace) { aerospace-confstall }
    if (has-cmd amethyst) { amethyst-confstall }
}

# UV Jupyter installation
export def uv-jupyter-install []: nothing -> nothing {
    if not (has-cmd uv) {
        warn "uv not installed, skipping jupyter installation"
        return
    }
    if (dir-exists ~/jupyter-standalone) {
        warn "Directory ~/jupyter-standalone already exists, skipping jupyter installation"
        return
    }

    mkdir ~/jupyter-standalone
    cd ~/jupyter-standalone
    uv venv --seed
    uv pip install pydantic
    uv pip install jupyterlab
}

# UV Marimo installation
export def uv-marimo-install []: nothing -> nothing {
    if not (has-cmd uv) {
        warn "uv not installed, skipping marimo installation"
        return
    }
    if (dir-exists ~/marimo-standalone) {
        warn "Directory ~/marimo-standalone already exists, skipping marimo installation"
        return
    }

    mkdir ~/marimo-standalone
    cd ~/marimo-standalone
    uv venv
    uv pip install numpy
    uv pip install marimo
}

# Poetry installation
export def poetry-install []: nothing -> nothing {
    if (has-cmd poetry) {
        return
    }

    slog "Installing poetry"
    if (has-cmd python3) {
        curl -sSL https://install.python-poetry.org | python3 -
        smd ~/.zfunc
        poetry completions zsh > ~/.zfunc/_poetry
        slog "poetry installation done!"
    } else {
        warn "python3 not installed, skipping poetry"
    }

    cmd-check poetry
}

# Pyenv Anaconda installation
export def pyenv-anaconda-install []: nothing -> nothing {
    if not (has-cmd pyenv) {
        warn "pyenv not installed, skipping anaconda"
        return
    }

    let pyenv_versions = (pyenv versions | str trim)
    if not ($pyenv_versions | str contains "anaconda") {
        let anacondaversion = (pyenv install --list | lines | where { |line| $line =~ "(?i)anaconda3-" } | last | str trim)
        slog $"Installing ($anacondaversion)"
        pyenv install $anacondaversion
        smd ~/py
        cd ~/py
        pyenv global $anacondaversion
        python -m pip install --user pipx neovim uv
    }

    cmd-check conda
}

# Pyenv Miniconda installation
export def pyenv-miniconda-install []: nothing -> nothing {
    if not (has-cmd pyenv) {
        warn "pyenv not installed, skipping miniconda"
        return
    }

    let pyenv_versions = (pyenv versions | str trim)
    if not ($pyenv_versions | str contains "miniconda") {
        slog "Installing miniconda"
        let minicondaversion = (pyenv install --list | lines | where { |line| $line =~ "(?i)miniconda" } | last | str trim)
        pyenv install $minicondaversion
        slog "miniconda installation done!"
    }

    cmd-check conda
}

# NPM installation
export def npm-install []: nothing -> nothing {
    if (has-cmd npm) {
        return
    }

    if not (has-cmd volta) {
        curl https://get.volta.sh | bash
    }

    if not (has-cmd ~/.volta/bin/volta) {
        warn "volta not installed! Skipping npm setup."
        return
    }

    volta install node@latest

    cmd-check volta npm
}

# AI CLI installation
export def ai-cli-install []: nothing -> nothing {
    if not (has-cmd npm) {
        npm-install
    }

    npm install -g @anthropic-ai/claude-code
    npm install -g @google/gemini-cli
    npm install -g @qwen-code/qwen-code
    npm install -g @openai/codex
    npm install -g @charmland/crush

    if (has-cmd gh) {
        gh extension install github/gh-copilot
    }
}

# Web development group installation
export def web-groupstall []: nothing -> nothing {
    npm-install

    slog "Installing npm packages globally"
    npm install -g pnpm
    npm install -g ndb @antfu/ni
    npm install -g tsx vite-node zx turbo

    if (is-linux) {
        let sysctl_file = "/etc/sysctl.conf"
        let fs_check = (open $sysctl_file | str contains "fs.inotify.max_user_watches")
        if not $fs_check {
            echo "fs.inotify.max_user_watches=524288" | sudo tee -a $sysctl_file | ignore
            sudo sysctl -p
        }
    }

    if (is-apt) {
        npm dlx playwright install-deps
        npm dlx playwright install
    }
}

# Neovim group installation
export def nvim-groupstall []: nothing -> nothing {
    # nvim-boxstall equivalent
    astrovim-confstall

    if (has-cmd brew) {
        bis luarocks lazygit tectonic fd gdu fzf
        if not (has-cmd nvim) { bi neovim }
        if not (has-cmd tree-sitter) { bi tree-sitter-cli }
        if not (has-cmd rg) { bi ripgrep }
        if not (has-cmd btm) { bi bottom }
    }

    if not (has-cmd pixi) {
        pixi-install
    }

    if (has-cmd pixi) {
        pis nvim luarocks lazygit tectonic gdu fd fzf
        if not (has-cmd tree-sitter) { pi tree-sitter-cli }
        if not (has-cmd rg) { pi ripgrep }
        if not (has-cmd btm) { pi bottom }
    } else if (active-installer-command-exists si) {
        run-active-installer-command si neovim luarocks lazygit gdu ripgrep bottom btm tree-sitter-cli fd-find fzf

        if (is-apt) {
            warn "Older version of neovim is installed. Some features might not work."
        }
    } else {
        warn "nvim not installed!"
        return
    }

    if not (has-cmd nvim) {
        warn "nvim not installed!"
    }
}

# Go tools installation
export def go-tools-install []: nothing -> nothing {
    if not (has-cmd go) {
        warn "go not installed, skipping go dev tools"
        return
    }

    slog "Installing go dev tools..."

    go install golang.org/x/lint/golint@latest
    go install golang.org/x/tools/cmd/goimports@latest
    go install golang.org/x/tools/gopls@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install github.com/ramya-rao-a/go-outline@latest
    go install github.com/acroca/go-symbols@latest
    go install github.com/mdempsky/gocode@latest
    go install github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest
    go install github.com/cweill/gotests/gotests@latest
    go install github.com/fatih/gomodifytags@latest
    go install github.com/josharian/impl@latest
    go install github.com/haya14busa/goplay/cmd/goplay@latest
    go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
    go install github.com/godoctor/godoctor@latest
    go install github.com/zmb3/gogetdoc@latest
    go install github.com/jstemmer/gotags@latest
    go install github.com/fatih/motion@latest
    go install github.com/klauspost/asmfmt/cmd/asmfmt@latest
    go install github.com/kisielk/errcheck@latest
    go install mvdan.cc/gofumpt@latest
}

# Pixi good packages installation
export def pixi-good-packages []: nothing -> nothing {
    pi gh lazygit git-delta unzip wget curl trash-cli tar stow just emacs starship tmux go-gum tree bat eza fzf ripgrep zoxide fd htop sd yazi bat tealdeer navi

    if (has-cmd tldr) {
        tldr --update
    }
}

# Pixi packages installation
export def pixi-packages []: nothing -> nothing {
    pixi-install

    pi git gcc make file zsh
    pixi-good-packages
}

# Devenv installation
export def devenv-install []: nothing -> nothing {
    if (has-cmd devenv) {
        return
    }

    warn "Installing devenv using nix profile"
    warn "Using home-manager or nixos is the recommended approach."
    nix profile install nixpkgs#devenv
}

# Brew good packages installation
export def brew-good-packages []: nothing -> nothing {
    bi gh unzip wget curl trash-cli stow starship tmux gum just emacs zsh tree bat eza fzf ripgrep zoxide fd htop sd yazi bat tealdeer cheat navi lazygit git-delta

    if (has-cmd tldr) {
        tldr --update
    }
}

# Brew packages installation
export def brew-packages []: nothing -> nothing {
    brew-install

    bi git gcc make file
    brew-good-packages
}

# Shell-slim installation
export def shell-slim-install []: nothing -> nothing {
    if (has-cmd brew) {
        brew-shell-slim-install
    } else {
        pixi-install
        pixi-shell-slim-install
    }
    pkgx-install | ignore
}

# Shell installation
export def shell-install []: nothing -> nothing {
    shell-slim-install
    if (has-cmd brew) {
        brew-shell-install
    } else {
        pixi-shell-install
    }
}

# Pixi installation
export def pixi-install []: nothing -> bool {
    if ("~/.pixi/bin/pixi" | path exists) {
        return true
    }

    slog "Installing pixi"
    if (has-cmd curl) {
        curl -fsSL https://pixi.sh/install.sh | bash
    } else if (has-cmd wget) {
        wget -qO- https://pixi.sh/install.sh | bash
    } else {
        warn "curl or wget not installed, skipping pixi installation"
        return false
    }

    slog "pixi installation done!"

    cmd-check ~/.pixi/bin/pixi
    cmd-check pixi

    true
}

# UV installation
export def uv-install []: nothing -> nothing {
    if (has-cmd uv) {
        return
    }

    if (has-cmd pipx) {
        pipx install uv
    } else {
        curl -LsSf https://astral.sh/uv/install.sh | sh
    }

    if not (has-cmd pipx) {
        if (has-cmd uv) {
            uv tool install pipx
        }
    }
}

# Python installation
export def python-install []: nothing -> nothing {
    slog "Installing python tools"

    # Check if system-python_install exists in scope
    let system_fn = (active-installer-command-exists "system-python-install")
    if $system_fn {
        run-active-installer-command "system-python-install"
        return
    }

    uv-install

    slog "Python tools installation done!"
    cmd-check pipx uv
}

# Flathub installation
export def flathub-install []: nothing -> nothing {
    if not (has-cmd flatpak) {
        # Try to install via si if available
        let si_fn = (active-installer-command-exists si)
        if $si_fn {
            run-active-installer-command si flatpak
        }
    }

    if (has-cmd flatpak) {
        slog "Adding flathub remote"
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user
    } else {
        warn "flatpak not installed! Ignoring flathub config."
    }
}

# Kitty binary installation
export def kitty-binstall []: nothing -> nothing {
    if not (is-desktop) {
        warn "Not running desktop, skipping kitty installation"
        return
    }

    if (has-cmd kitty) {
        return
    }
    if ("~/.local/kitty.app/bin/kitty" | path exists) {
        return
    }

    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    # Force link
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/

    smd ~/.local/share/applications
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/

    # Update paths in desktop files
    let kitty_icon = (readlink -f ~) + "/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png"
    let kitty_exec = (readlink -f ~) + "/.local/kitty.app/bin/kitty"

    sed -i $"s|Icon=kitty|Icon=($kitty_icon)|g" ~/.local/share/applications/kitty*.desktop
    sed -i $"s|Exec=kitty|Exec=($kitty_exec)|g" ~/.local/share/applications/kitty*.desktop

    echo 'kitty.desktop' > ~/.config/xdg-terminals.list

    cmd-check kitty
}

# Kitty full installation
export def kitty-install []: nothing -> nothing {
    kitty-binstall
    kitty-confstall
}

# Ghostty binary installation
export def ghostty-binstall []: nothing -> nothing {
    if (has-cmd ghostty) {
        return
    }

    let version = (curl -s https://api.github.com/repos/pkgforge-dev/ghostty-appimage/releases/latest | from json | get tag_name)
    let arch = (^uname -m)

    wget $"https://github.com/pkgforge-dev/ghostty-appimage/releases/download/($version)/Ghostty-($version)-($arch).AppImage"
    chmod +x $"Ghostty-($version)-($arch).AppImage"
    install $"Ghostty-($version)-($arch).AppImage" ~/.local/bin/ghostty
}

# Ghostty full installation
export def ghostty-install []: nothing -> nothing {
    ghostty-binstall
    ghostty-confstall
}

# Atomic distrobox installation
export def atomic-distrobox-install []: nothing -> nothing {
    if (has-cmd distrobox) {
        return
    }

    slog "Installing distrobox"
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
    slog "distrobox installation done!"
}

# CMake installation
export def cmake-install []: nothing -> nothing {
    if ("~/.local/bin/cmake" | path exists) {
        return
    }

    let cmake_version = "4.1.0"
    let arch = (^uname -m)
    let cmake_binary_name = $"cmake-($cmake_version)-linux-($arch).sh"
    let cmake_checksum_name = $"cmake-($cmake_version)-SHA-256.txt"

    slog "Installing latest cmake"
    let tmp_dir = (mktemp -d -t cmake-XXXXXXXXXX)
    cd $tmp_dir

    curl -sSL $"https://github.com/Kitwe/CMake/releases/download/v($cmake_version)/($cmake_binary_name)" -O
    curl -sSL $"https://github.com/Kitware/CMake/releases/download/v($cmake_version)/($cmake_checksum_name)" -O

    sha256sum -c --ignore-missing $cmake_checksum_name

    let prefix = ~/.cmake | path expand
    sudo mkdir -p $prefix
    sudo sh $"($tmp_dir)/($cmake_binary_name)" --prefix=$prefix --skip-license

    sudo ln -s ($"($prefix)/bin/cmake") ~/.local/bin/cmake
    sudo ln -s ($"($prefix)/bin/ctest") ~/.local/bin/ctest
    frm $tmp_dir

    slog "cmake installation done!"
    cmd-check cmake
}

# Gnome extensions slim installation
export def gnome-extensions-slim-install []: nothing -> nothing {
    if not (has-cmd gext) {
        if not (has-cmd pipx) {
            uv-install
        }
        pipx install gnome-extensions-cli --system-site-packages
    }

    if not (has-cmd gext) {
        warn "gext not found, skipping gnome extensions"
        return
    }

    gext install windowsNavigator@gnome-shell-extensions.gcampax.github.com
    gext install switcher@landau.fi
    gext install CoverflowAltTab@palatis.blogspot.com
}

# Gnome extension install helper
export def gei [...exts: string]: nothing -> nothing {
    for ext in $exts {
        gext install $ext
    }
}

# Gnome PaperWM installation
export def gnome-paperwm-install []: nothing -> nothing {
    if not (has-cmd gext) {
        if not (has-cmd pipx) {
            uv-install
        }
        pipx install gnome-extensions-cli --system-site-packages
    }

    if not (has-cmd gext) {
        warn "gext not found, skipping gnome extensions"
        return
    }

    let exts = [
        paperwm@paperwm.github.com
        switcher@landau.fi
        windowsNavigator@gnome-shell-extensions.gcampax.github.com
        search-light@icedman.github.com
        openbar@neuromorph
    ]

    gei ...$exts
}

# Gnome extensions installation
export def gnome-extensions-install []: nothing -> nothing {
    slog "Installing gnome extensions"

    gnome-extensions-slim-install
    if not (has-cmd gext) {
        return
    }

    let exts = [
        search-light@icedman.github.com
        blur-my-shell@aunetx
        just-perfection-desktop@just-perfection
        undecorate@sun.wxg@gmail.com
        Vitals@CoreCoding.com
        tailscale@joaophi.github.com
        tilingshell@ferrarodomenico.com
        AlphabeticalAppGrid@stuarthayhurst
        extension-list@tu.berry
    ]

    gei ...$exts

    slog "gnome extensions installation done!"
}

# Gnome settings installation
export def gnome-settings-install []: nothing -> nothing {
    if not (has-cmd gsettings) {
        warn "gsettings not found, skipping gnome basic settings"
        return
    }

    slog "gnome settings"

    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"
    gsettings set org.gnome.desktop.interface accent-color 'teal'

    # Use 4 fixed workspaces
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

    # Center new windows
    gsettings set org.gnome.mutter center-new-windows true

    # Set JetBrains Mono as monospace font
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetbrainsMono Nerd Font 11'

    gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true

    slog "gnome settings done!"
}

# Gnome flatpaks installation
export def gnome-flatpaks-install []: nothing -> nothing {
    fpi com.github.PintaProject.Pinta
    fpi com.github.rafostar.Clapper
    fpi io.github.flattool.Ignition
    fpi io.gitlab.adhami3310.Impression
    fpi org.gnome.Firmware
    fpi org.gnome.World.PikaBackup
    fpi io.missioncenter.MissionCenter
}

# Gnome flatpaks slim installation
export def gnome-flatpaks-slim-install []: nothing -> nothing {
    fpi com.mattjakeman.ExtensionManager
    fpi org.gnome.Logs
    fpi org.gtk.Gtk3theme.adw-gtk3
    fpi org.gtk.Gtk3theme.adw-gtk3-dark
    fpi io.github.swordpuffin.rewaita
}

# Gnome configuration
export def gnome-confstall []: nothing -> nothing {
    if not (is-gnome) {
        warn "Not running GNOME, skipping GNOME config"
        return
    }

    slog "gnome config"

    if (is-ubuntu) {
        let si_fn = (active-installer-command-exists si)
        if $si_fn {
            run-active-installer-command si gnome-shell-extension-manager gnome-tweak-tool gnome-sushi gnome-software-plugin-flatpak
        }
    } else if (is-fedora) and not (is-atomic) {
        let si_fn = (active-installer-command-exists si)
        if $si_fn {
            run-active-installer-command si gnome-extensions-app gnome-tweaks
        }
    }

    if (is-ubuntu) {
        gnome-extensions disable tiling-assistant@ubuntu.com
        gnome-extensions disable ubuntu-appindicators@ubuntu.com
        gnome-extensions disable ubuntu-dock@ubuntu.com
        gnome-extensions disable ding@rastersoft.com
    }

    gnome-settings-install
    gnome-extensions-slim-install
    gnome-flatpaks-slim-install

    slog "gnome config done!"
}

# VSCode flatpak configuration
export def vscode-flatpak-confstall []: nothing -> nothing {
    slog "vscode flatpak config"

    let flatpak_code_dir = ~/.var/app/com.visualstudio.code/config/Code/User
    smd $flatpak_code_dir
    safe-cp ($env.DOT_DIR | path join "extras" "vscode" "flatpak-settings.json") $"($flatpak_code_dir)/settings.json"

    vscode-extensions-install

    ^flatpak override --user --socket=wayland "--nosocket=x11" --device=dri --filesystem=host-os --talk-name=org.freedesktop.secrets com.visualstudio.code

    slog "vscode flatpak config done!"
}

# VSCode flatpak installation
export def vscode-flatpak-install []: nothing -> nothing {
    fpi com.visualstudio.code
    fpi com.visualstudio.code.tool.podman/x86_64/stable
    vscode-flatpak-confstall
}

# Ptyxis installation
export def ptyxis-install []: nothing -> nothing {
    if (has-cmd ptyxis) {
        return
    }

    if not (has-cmd flatpak) {
        warn "flatpak not installed, skipping ptyxis installation."
        return
    }

    if not (flatpak list | str contains -i "Ptyxis") {
        slog "Installing Ptyxis"
        fpi app.devsuite.Ptyxis
    }

    slog "Ptyxis installation and configuration done!"
}

# Distrobox UI installation
export def distrobox-ui-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    fpi io.podman_desktop.PodmanDesktop
    fpi io.github.dvlv.boxbuddyrs
}

# Apps slim installation
export def apps-slim-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    if not (has-cmd flatpak) {
        let si_fn = (active-installer-command-exists si)
        if $si_fn {
            run-active-installer-command si flatpak
        } else {
            warn "flatpak not installed, skipping flatpak apps"
            return
        }
    }

    flathub-install

    fpi io.github.flattool.Warehouse
    fpi com.github.tchx84.Flatseal
    fpi page.tesk.Refine
    fpi it.mijorus.gearlever
    if (is-atomic) {
        fpi org.gnome.Boxes
    }

    if not (has-cmd firefox) {
        fpi app.zen_browser.zen
    }
}

# Apps installation
export def apps-install []: nothing -> nothing {
    slog "Installing flatpak apps"

    apps-slim-install

    fpi org.fedoraproject.MediaWriter
    fpi us.zoom.Zoom
    fpi md.obsidian.Obsidian
    fpi org.telegram.desktop
    fpi io.github.getnf.embellish
    fpi com.bitwarden.desktop
    fpi sh.cider.Cider
    fpi org.qbittorrent.qBittorrent
    fpi org.wireshark.Wireshark
    fpi me.iepure.devtoolbox
    fpi io.github.ronniedroid.concessio

    slog "Flatpak apps installation done!"
}

# Incus configuration
export def incus-confstall []: nothing -> nothing {
    slog "incus config"

    if not (has-cmd incus) {
        warn "incus not installed, skipping incus config"
        return
    }

    sudo usermod -aG incus $env.USER
    sudo usermod -aG incus-admin $env.USER

    sudo systemctl enable --now incus.socket

    sudo incus admin init --minimal

    if (has-cmd firewalld) {
        sudo firewall-cmd --zone=trusted --change-interface=incusbr0 --permanent
        sudo firewall-cmd --reload
    } else if (has-cmd ufw) {
        sudo ufw allow in on incusbr0
        sudo ufw route allow in on incusbr0
        sudo ufw route allow out on incusbr0
    }

    slog "incus config done! Re-login or reboot for group changes to apply."
}

# Libvirt configuration
export def libvirt-confstall []: nothing -> nothing {
    sudo systemctl enable --now libvirtd
    sudo systemctl enable --now libvirtd.socket
    sudo systemctl enable --now virtlogd

    add-user-to-groups $env.USER libvirt libvirtd kvm libvirt-qemu

    let libvirt_group = if (group-exists libvirtd) { "libvirtd" } else { "libvirt" }

    if (has-cmd authselect) {
        sudo authselect enable-feature with-libvirt
    }

    sg $libvirt_group -c '
        if ! virsh --connect qemu:///system net-list --all | grep -q default; then
            virsh --connect qemu:///system net-start default
            virsh --connect qemu:///system net-autostart default
        fi

        if ! virsh --connect qemu:///system net-list --all | grep -q default; then
            echo "Failed to create default network" >&2
        fi
    '

    sudo osinfo-db-import --local --latest
}

# Atomic neovim binary installation
export def atomic-nvim-binstall []: nothing -> nothing {
    if (is-mac) {
        return
    }

    if (has-cmd nvim) {
        return
    }

    slog "Installing neovim..."

    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    ./nvim.appimage --appimage-extract

    sudo mv squashfs-root /
    sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
    frm nvim.appimage

    cmd-check nvim
}

# Micro installation
export def micro-install []: nothing -> nothing {
    if (has-cmd micro) {
        return
    }

    slog "Installing micro"
    curl https://getmic.ro | bash
    mv micro ~/.local/bin/

    slog "micro installation done!"
    cmd-check micro
}

# Rust installation
export def rust-install []: nothing -> nothing {
    source-if-exists ~/.cargo/env

    if (has-cmd rustup) {
        return
    }

    slog "Installing rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source-if-exists ~/.cargo/env

    slog "rust installation done!"
    cmd-check rustc
}

# Lazydocker installation
export def lazydocker-install []: nothing -> nothing {
    if (has-cmd lazydocker) {
        return
    }

    slog "Installing lazydocker"

    if (has-cmd brew) {
        bi jesseduffield/lazydocker/lazydocker
        bis lazydocker
    } else if (has-cmd pixi) {
        pis lazydocker
    } else {
        warn "cannot install lazydocker"
    }
}

# Docker configuration
export def docker-confstall []: nothing -> nothing {
    if not (has-cmd docker) {
        warn "docker not installed, skipping docker post install configuration"
        return
    }

    if not (grep -q docker /etc/group 2>/dev/null) {
        sudo groupadd docker
    }

    if not (groups $env.USER | grep -q docker 2>/dev/null) {
        sudo usermod -aG docker $env.USER
    }

    sudo systemctl enable docker
    sudo systemctl start docker
    sudo systemctl enable containerd
    sudo systemctl start containerd
}

# Python pipx/uv install helper
export def pyi [...packages: string]: nothing -> nothing {
    if not (has-cmd pipx) and not (has-cmd uv) {
        warn "neither pipx not uv installed, skipping packages"
        return
    }

    let installer = if (has-cmd uv) { "uv tool" } else { "pipx" }

    for pkg in $packages {
        slog $"Installing ($installer) package ($pkg)"
        if $installer == "uv tool" {
            uv tool install $pkg
        } else {
            pipx install $pkg
        }
    }
}

# Conan installation
export def conan-install []: nothing -> nothing {
    if (has-cmd conan) {
        return
    }

    slog "Installing conan"
    pyi conan
    slog "conan installation done!"

    cmd-check conan
}

# Monaspace font installation
export def monaspace-install []: nothing -> nothing {
    let font_file = ~/.local/share/fonts/MonaspaceRadon-Regular.otf | path expand
    if ($font_file | path exists) {
        return
    }

    smd ~/.local/share/fonts

    frm /tmp/monaspace /tmp/monaspace.zip
    wget -nv https://github.com/githubnext/monaspace/releases/download/v1.000/monaspace-v1.000.zip -O /tmp/monaspace.zip
    unzip -qq -d /tmp/monaspace -o /tmp/monaspace.zip

    cp /tmp/monaspace/monaspace-*/fonts/otf/* ~/.local/share/fonts
    cp /tmp/monaspace/monaspace-*/fonts/variable/* ~/.local/share/fonts

    frm /tmp/monaspace /tmp/monaspace.zip
}

# Cascadia Nerd Font installation
export def cascadia-nerd-font-install []: nothing -> nothing {
    let font_file = ~/.local/share/fonts/CaskaydiaMonoNerdFont-Regular.ttf | path expand
    if ($font_file | path exists) {
        return
    }

    smd ~/.local/share/fonts
    frm /tmp/cascadia /tmp/CascadiaMono.zip
    wget -nv https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaMono.zip -O /tmp/CascadiaMono.zip
    unzip -qq -d /tmp/cascadia -o /tmp/CascadiaMono.zip
    cp /tmp/cascadia/*.ttf ~/.local/share/fonts
    frm /tmp/cascadia /tmp/CascadiaMono.zip
}

# Monaspace Nerd Font installation
export def monaspace-nerd-font-install []: nothing -> nothing {
    let font_file = ~/.local/share/fonts/MonaspiceRnNerdFont-Regular.otf | path expand
    if ($font_file | path exists) {
        return
    }

    smd ~/.local/share/fonts
    frm /tmp/monaspace /tmp/Monaspace.zip
    wget -nv https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Monaspace.zip -O /tmp/Monaspace.zip
    unzip -qq -d /tmp/monaspace -o /tmp/Monaspace.zip
    cp /tmp/monaspace/*.otf ~/.local/share/fonts
    frm /tmp/monaspace /tmp/Monaspace.zip
}

# JetBrains Nerd Font installation
export def jetbrains-nerd-font-install []: nothing -> nothing {
    let font_file = ~/.local/share/fonts/JetBrainsMonoNLNerdFontPropo-Regular.ttf | path expand
    if ($font_file | path exists) {
        return
    }

    slog "Installing JetBrains Mono Nerd Font"
    smd ~/.local/share/fonts
    frm /tmp/jetbrains-mono /tmp/jetbrains-mono.zip
    wget -nv https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip -O /tmp/jetbrains-mono.zip
    unzip -qq -d /tmp/jetbrains-mono -o /tmp/jetbrains-mono.zip
    cp /tmp/jetbrains-mono/*.ttf ~/.local/share/fonts
    frm /tmp/jetbrains-mono /tmp/jetbrains-mono.zip
    slog "JetBrains Mono Nerd Font installation done!"
}

# Font Awesome installation
export def font-awesome-install []: nothing -> nothing {
    let font_file = $"($env.HOME)/.local/share/fonts/Font Awesome 7 Brands-Regular-400.otf" | path expand
    if ($font_file | path exists) {
        return
    }

    smd ~/.local/share/fonts
    frm /tmp/font-awesome /tmp/font-awesome.zip
    wget -nv https://use.fontawesome.com/releases/v7.1.0/fontawesome-free-7.1.0-desktop.zip -O /tmp/font-awesome.zip
    unzip -qq -d /tmp/font-awesome -o /tmp/font-awesome.zip
    cp /tmp/font-awesome/*.otf ~/.local/share/fonts
    frm /tmp/font-awesome /tmp/font-awesome.zip
}

# Maple font installation
export def maple-font-install []: nothing -> nothing {
    let font_file = ~/.local/share/fonts/MapleMono-NF-Regular.ttf | path expand
    if ($font_file | path exists) {
        return
    }

    slog "Installing Maple Mono Font"
    smd ~/.local/share/fonts
    frm /tmp/maple-mono /tmp/maple-mono.zip
    wget -nv https://github.com/subframe7536/maple-font/releases/download/v7.2/MapleMono-NF.zip -O /tmp/maple-mono.zip
    unzip -qq -d /tmp/maple-mono -o /tmp/maple-mono.zip
    cp /tmp/maple-mono/*.ttf ~/.local/share/fonts
    frm /tmp/maple-mono /tmp/maple-mono.zip
    slog "Maple Mono Font installation done!"
}

# Nerd fonts installation
export def nerd-fonts-install []: nothing -> nothing {
    smd ~/.local/share/fonts

    cascadia-nerd-font-install
    jetbrains-mono-install
    monaspace-nerd-font-install
}

# All fonts installation
export def fonts-install []: nothing -> nothing {
    if not (has-cmd wget) or not (has-cmd unzip) {
        warn "wget and unzip not installed, skipping fonts"
        return
    }

    slog "Installing fonts"

    monaspace-install
    nerd-fonts-install
    maple-font-install

    slog "Fonts installation done!"
}

# JetBrains Mono installation (public interface)
export def jetbrains-mono-install []: nothing -> nothing {
    slog "Installing JetBrains Mono Nerd Font..."
    jetbrains-nerd-font-install
    slog "JetBrains Mono Nerd Font installation done!"
}

# Starship installation
export def starship-install []: nothing -> nothing {
    if (has-cmd starship) {
        return
    }

    smd ~/.local/bin
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
}

# Sway waybar configuration
export def sway-waybar-confstall []: nothing -> nothing {
    slog "waybar config"
    if not (has-cmd waybar) {
        return
    }
    stowgf sway-waybar
    slog "waybar config done!"
}

# Wlogout configuration
export def wlogout-confstall []: nothing -> nothing {
    slog "wlogout config"
    if not (has-cmd wlogout) {
        return
    }
    stowgf wlogout
    slog "wlogout config done!"
}

# Rofi configuration
export def rofi-confstall []: nothing -> nothing {
    if not (has-cmd rofi) {
        return
    }

    slog "rofi config"
    stowgf rofi
    slog "rofi config done!"
}

# Sway configuration
export def sway-confstall []: nothing -> nothing {
    if not (has-cmd sway) {
        warn "sway not available, skipping sway config"
        return
    }

    stowgf sway

    sway-waybar-confstall
    foot-confstall
    kitty-confstall
    rofi-confstall
    wlogout-confstall
}

# Hyprland waybar configuration
export def hypr-waybar-confstall []: nothing -> nothing {
    if not (has-cmd waybar) {
        return
    }

    slog "waybar config"
    stowgf hypr-waybar
    slog "waybar config done!"
}

# Hyprland configuration
export def hyprland-confstall []: nothing -> nothing {
    slog "hypr config install"

    hypr-waybar-confstall
    wlogout-confstall
    rofi-confstall
    kitty-confstall

    slog "hypr config done!"
}

# Ublue common installation
export def ublue-common-install []: nothing -> nothing {
    if (is-ublue) and (has-cmd git) and (has-cmd brew) and (has-cmd flatpak) {
        slog "Prerequisites met, installing uBlue OS"
    } else {
        die "Prerequisites not met. You need Aurora/Bluefin/Bazzite with git, brew and flatpak installed."
    }

    if not (has-cmd code) and not (has-cmd virt-install) and not (has-cmd docker) {
        # ujust devmode would go here if available
        warn "Consider enabling devmode with ujust"
    }

    if not (current-user-in-group docker) {
        warn "User not in docker group, add with: ujust dx-group"
        incus-confstall
    }

    dotfiles-install
    python-install
    npm-install
    ai-cli-install
    brew-shell-slim-install
    apps-slim-install
    jetbrains-mono-install
    vscode-confstall
    if (is-gnome) {
        gnome-settings-install
    }
}

# Ublue mainstall
export def ublue-mainstall []: nothing -> nothing {
    ublue-common-install

    if $env.USER == "pervez" {
        shell-confstall
    } else {
        if (is-bluefin) { ujust bluefin-cli }
        if (is-aurora) { ujust aurora-cli }
        if (is-bazzite) { ujust bazzite-cli }
    }
}

# Ensure nix mount
export def ensure-nix-mount []: nothing -> nothing {
    if not ("/nix" | path exists) {
        die "/nix does not exist, cannot mount nix store"
    }

    let subvol_path = "/home/nix"
    let mount_point = "/nix"

    let subvol_exists = (try { sudo btrfs subvolume show $subvol_path | complete | get exit_code | $in == 0 } catch { false })

    if $subvol_exists {
        slog $"Subvolume ($subvol_path) already exists, skipping creation"
    } else {
        sudo btrfs subvolume create $subvol_path
    }

    let mounted = (try { findmnt -rno TARGET $mount_point | complete | get exit_code | $in == 0 } catch { false })

    if $mounted {
        slog $"($mount_point) already mounted, skipping"
        return
    }

    let source = (df --output=source (dirname $subvol_path) | lines | last)
    sudo mount -o $"subvol=(basename $subvol_path)" $source $mount_point
}

# Bluenix installation (ublue + nix)
export def bluenix-mainstall []: nothing -> nothing {
    ublue-common-install
    ensure-nix-mount
    nix-groupstall
}

# Distrobox group installation
export def distrobox-groupstall []: nothing -> nothing {
    if (is-distrobox) {
        warn "Installing distrobox inside distrobox is not recommended, skipping"
        return
    }

    distrobox-install
    if not (is-distrobox) {
        distrobox-ui-install
    }
}

# Generic container mainstall
export def generic-ct-mainstall []: nothing -> nothing {
    if not (has-cmd curl) and not (has-cmd wget) {
        die "Install curl and run this script again."
    }

    pixi-install
    pis git curl wget

    pkgx-install

    slog "Installing shell tools with pixi"
    pixi-shell-slim-install

    slog "Installing shell tools with pixi done!"

    dotfiles-install

    starship-install
    bash-confstall
    git-confstall
}

# Generic mainstall
export def generic-mainstall []: nothing -> nothing {
    generic-ct-mainstall

    if (has-cmd zsh) { zsh-boxstall }
    if (has-cmd tmux) { tmux-boxstall }

    if (has-cmd podman) or (has-cmd docker) {
        atomic-distrobox-install
    } else {
        fail "No container runtime(docker or podman) installed, skipping distrobox installation"
    }

    if not (is-desktop) {
        return
    }
    if (is-distrobox) {
        return
    }

    jetbrains-mono-install
    flathub-install
    apps-slim-install
    ptyxis-install
    vscode-flatpak-install
}

# Fedora Atomic distrobox mainstall
export def fedora-atomic-dt-mainstall []: nothing -> nothing {
    generic-mainstall

    # dt-docker and dt-nix would be called from dt-fns module
    warn "Consider running dt-docker and dt-nix separately"
}

# Fedora Atomic toolbox mainstall
export def fedora-atomic-tbox-mainstall []: nothing -> nothing {
    if not (is-std-atomic) {
        die "This script is only for Atomic Host"
    }

    slog "Fedora Atomic Host setup"

    jetbrains-mono-install

    slog "Installing apps"
    apps-slim-install

    slog "Setting up default distrobox for development"
    # tbox-dev would be called from dt-fns module

    slog "Fedora Atomic Host With default toolbox setup done!"
}

# Fedora Atomic mainstall
export def fedora-atomic-mainstall []: nothing -> nothing {
    if not (is-std-atomic) {
        die "This script is only for Atomic Host"
    }

    slog "Fedora Atomic Host setup"

    generic-ct-mainstall
    jetbrains-mono-install
    atomic-distrobox-install

    slog "Installing apps"
    apps-slim-install

    python-install
    if (is-gnome) { gnome-confstall }
    if (is-sway) { sway-confstall }

    slog "Fedora Atomic Host setup done!"
}

# Fedora layered mainstall
export def fedora-layered-mainstall []: nothing -> nothing {
    if not (is-std-atomic) {
        die "This script is only for Atomic Host"
    }

    slog "Fedora Atomic Host setup"

    pixi-install
    pkgx-install

    pis wget
    pixi-shell-slim-install

    dotfiles-install
    bash-confstall
    zsh-boxstall

    jetbrains-mono-install
    atomic-distrobox-install
    vscode-confstall

    apps-slim-install

    if (is-gnome) { gnome-confstall }
    if (is-sway) { sway-confstall }

    slog "Fedora layered setup done! Reboot your system."
}

# Portainer installation
export def portainer-install []: nothing -> nothing {
    if not (has-cmd docker) {
        warn "docker not installed, skipping portainer"
        return
    }

    if (docker ps -a | str contains portainer) {
        slog "Portainer is already installed"
        return
    }

    sg docker -c '
        if ! docker volume inspect portainer_data &>/dev/null; then
            echo "Creating portainer_data volume"
            docker volume create portainer_data
            docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
        fi
    '
    slog "Portainer installation done!"
}

# Apps slim groupstall
export def apps-slim-groupstall []: nothing -> nothing {
    flathub-install
    apps-slim-install
}

# Apps groupstall
export def apps-groupstall []: nothing -> nothing {
    flathub-install
    apps-install
}

# Enable SSH service
export def enable-ssh-service []: nothing -> nothing {
    if (has-cmd systemctl) {
        try { sudo systemctl enable sshd } catch { sudo systemctl enable ssh }
    } else if (has-cmd rc-update) {
        sudo rc-update add sshd default
    } else {
        warn "Cannot enable ssh service: no systemctl or rc-update found"
    }
}

# Wallpapers installation
export def wallpapers-install []: nothing -> nothing {
    let walldir = ($env.XDG_DATA_HOME? | default ($env.HOME | path join ".local" "share")) | path join "ilm" "wallpapers"

    if (dir-exists $walldir) {
        return
    }

    slog "Installing wallpapers"

    smd $walldir
    wget -nv https://github.com/mylinuxforwork/wallpaper/archive/refs/heads/main.zip -O /tmp/wallpapers.zip
    unzip -qq -d $walldir /tmp/wallpapers.zip
    mv ($walldir | path join "wallpaper-main")/* $"($walldir)/"
    frm /tmp/wallpapers.zip
    rm -rf ($walldir | path join "wallpaper-main")

    if (dir-exists ~/Pictures) {
        sln $walldir (~/Pictures | path join "Wallpapers")
    }

    slog "Wallpapers installation done!"
}

# Foot configuration (defined in linux.nu but referenced here)
export def foot-confstall []: nothing -> nothing {
    slog "foot config"
    stowgf foot
    slog "foot config done!"
}

# pkgx installation
export def pkgx-install []: nothing -> bool {
    if ("~/.local/bin/pkgx" | path exists) {
        return true
    }

    if (has-cmd brew) {
        brew install pkgx
        return true
    }

    let platform = (uname).kernel-name
    let arch = (uname).machine
    let url = $"https://pkgx.sh/($platform)/($arch).tgz"

    try {
        if (has-cmd curl) {
            curl -fsSL $url | tar xz -C ~/.local/bin
        } else if (has-cmd wget) {
            wget -qO- $url | tar xz -C ~/.local/bin
        } else {
            warn "curl or wget not installed, skipping pkgx installation"
            return false
        }

        cmd-check pkgx
        true
    } catch {
        false
    }
}

# Nix installation
export def nix-install []: nothing -> nothing {
    if (has-cmd nix) {
        return
    }

    slog "Installing nix"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm

    source-if-exists /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    slog "nix installation done!"

    cmd-check nix nix-shell nix-env
}

# Home-manager installation
export def home-manager-install []: nothing -> nothing {
    if not (has-cmd nix) {
        warn "nix not installed, skipping home-manager installation"
        return
    }

    if (dir-exists ~/nix-config) {
        slog "$HOME/nix-config exists, skipping home-manager installation"
        return
    }

    let hm_dir = $env.DOT_DIR | path join "extras" "home-manager"
    if not (dir-exists $hm_dir) {
        nix-dotfiles-install
    }

    if not (dir-exists $hm_dir) {
        warn "could not setup dotfiles, cannot install home-manager."
        return
    }

    if not (cp -r $hm_dir ~/nix-config) {
        warn "Failed to copy home-manager config to $HOME/nix-config"
        return
    }

    # nix-vars-create would be called here

    slog "nix-config copied to ~/nix-config. Running hms to apply configuration."

    hms | ignore
}

# Nix groupstall
export def nix-groupstall []: nothing -> nothing {
    nix-install
    home-manager-install
}

# Nix check
export def nix-check []: nothing -> nothing {
    min-check
    cmd-check home-manager nix devbox
}

# Nix mainstall
export def nix-mainstall []: nothing -> nothing {
    min-mainstall
    let si_fn = (active-installer-command-exists si)
    if $si_fn and not (has-cmd zsh) {
        run-active-installer-command si zsh
    }
    nix-groupstall
    nix-check
}

# Docker groupstall
export def docker-groupstall []: nothing -> nothing {
    docker-install

    if not (is-linux) {
        return
    }
    if not (is-distrobox) {
        fpi sh.loft.devpod
    }
    docker-confstall
    lazydocker-install
}

# Work groupstall
export def work-groupstall []: nothing -> nothing {
    shell-slim-groupstall
    vscode-groupstall
    docker-groupstall
}

# VM groupstall
export def vm-groupstall []: nothing -> nothing {
    let vm_fn = (active-installer-command-exists vm-install)
    if $vm_fn {
        run-active-installer-command vm-install
    } else {
        warn "vm-install not available, skipping vm installation"
        return
    }

    if not (is-distrobox) {
        let vm_ui_fn = (active-installer-command-exists vm-ui-install)
        if $vm_ui_fn {
            run-active-installer-command vm-ui-install
        }
    }

    if not (is-linux) {
        return
    }

    cockpit-install
    libvirt-confstall
    if (has-cmd osinfo-db-import) {
        sudo osinfo-db-import --system --latest
    }
}

# Base config install
export def base-config-install []: nothing -> nothing {
    dotfiles-install
    if (has-cmd git) { git-confstall }
    if (is-linux) { bash-confstall }
    if (is-mac) { zsh-confstall }
}

# Min config install
export def min-config-install []: nothing -> nothing {
    base-config-install
}

# Shell-slim config install
export def shell-slim-config-install []: nothing -> nothing {
    min-config-install
    zsh-confstall
}

# Shell config install
export def shell-config-install []: nothing -> nothing {
    shell-slim-config-install
    tmux-confstall
    nvim-confstall astro
    yazi-confstall
}

# Groupstall helper
export def groupstall [name: string]: nothing -> nothing {
    let fn_name = $"($name)-groupstall"
    if (installer-command-exists $fn_name) {
        run-installer-command $fn_name
    } else {
        warn $"Groupstall function ($fn_name) not found"
    }
}

# Mainstall helper
export def mainstall [name: string]: nothing -> nothing {
    let fn_name = $"($name)-mainstall"
    if (installer-command-exists $fn_name) {
        run-installer-command $fn_name
    } else {
        warn $"Mainstall function ($fn_name) not found"
    }
}

# Base binstall
export def base-binstall []: nothing -> nothing {
    let core_fn = (active-installer-command-exists core-install)
    if $core_fn {
        run-active-installer-command core-install
    } else {
        warn "core-install not available, skipping core installation"
    }
}

# Bash config check
export def bash-config-check []: nothing -> nothing {
    if not (bash-config-exists) {
        warn "bash config is not setup correctly"
    }
}

# Base check
export def base-check []: nothing -> nothing {
    cmd-check curl wget git trash stow tree tar unzip
    dir-check $env.DOT_DIR
    bash-config-check
}

# DF confstall
export def df-confstall []: nothing -> nothing {
    slog "Configuring bash"

    let bashrc = ~/.bashrc | path expand
    let has_config = if ($bashrc | path exists) {
        let content = open $bashrc
        ($content | str contains ".ilm/share/shellrc") or ($content | str contains "source ${DOT_DIR}/share/shellrc")
    } else {
        false
    }

    if not $has_config {
        echo $"export DOT_DIR=($env.DOT_DIR)" >> ~/.bashrc
        echo 'source ${DOT_DIR}/share/shellrc' >> ~/.bashrc
    }

    slog "bash config done!"
}

# DF mainstall
export def df-mainstall []: nothing -> nothing {
    base-binstall
    dotfiles-install
    df-confstall
}

# Base mainstall
export def base-mainstall []: nothing -> nothing {
    base-binstall
    base-config-install
    base-check

    let key = (ssh-key-path)
    if ($key | is-not-empty) {
        slog $"SSH key at: ($key)"
    } else {
        warn "Could not generate ssh key"
    }
}

# Min binstall
export def min-binstall []: nothing -> nothing {
    base-binstall
    let essential_fn = (active-installer-command-exists essential-install)
    if $essential_fn {
        run-active-installer-command essential-install
    } else {
        warn "essential-install not available, skipping essential installation"
    }

    if (is-distrobox) {
        return
    }

    let ui_fn = (active-installer-command-exists ui-install)
    if $ui_fn {
        run-active-installer-command ui-install
    }
}

# Shell-slim binstall
export def shell-slim-binstall []: nothing -> nothing {
    let cli_fn = (active-installer-command-exists cli-slim-install)
    if $cli_fn {
        run-active-installer-command cli-slim-install
    } else {
        warn "cli-slim-install not available, skipping cli installation"
    }
    shell-slim-install
}

# Shell binstall
export def shell-binstall []: nothing -> nothing {
    let cli_fn = (active-installer-command-exists cli-install)
    if $cli_fn {
        run-active-installer-command cli-install
    } else {
        warn "cli-install not available, skipping cli installation"
    }

    if not (is-distrobox) {
        terminal-groupstall
    }

    shell-install
    brew-install
}

# Shell-slim groupstall
export def shell-slim-groupstall []: nothing -> nothing {
    shell-slim-binstall
    shell-slim-config-install
}

# Terminal config install
export def terminal-config-install []: nothing -> nothing {
    alacritty-confstall
    kitty-confstall
    ghostty-confstall
    wezterm-confstall
}

# Terminal groupstall
export def terminal-groupstall []: nothing -> nothing {
    if not (is-desktop) {
        warn "Not running desktop, skipping terminal installation"
        return
    }

    jetbrains-mono-install
    terminal-binstall
    terminal-config-install

    if (is-linux) {
        ptyxis-install
    }
}

# Shell groupstall
export def shell-groupstall []: nothing -> nothing {
    shell-binstall
    if not (is-distrobox) {
        terminal-groupstall
    }
    shell-config-install
    brew-install
}

# Brew groupstall
export def brew-groupstall []: nothing -> nothing {
    brew-install
    brew-shell-install
}

# Min check
export def min-check []: nothing -> nothing {
    base-check
    cmd-check micro zip gcc make whiptail
}

# Min mainstall
export def min-mainstall []: nothing -> nothing {
    min-binstall
    min-config-install
    min-check
}

# Shell-slim check
export def shell-slim-check []: nothing -> nothing {
    min-check
    cmd-check zsh rg starship zoxide eza gh fzf
}

# Shell-slim mainstall
export def shell-slim-mainstall []: nothing -> nothing {
    min-binstall
    shell-slim-binstall
    shell-slim-config-install
    shell-slim-check
}

# Shell check
export def shell-check []: nothing -> nothing {
    shell-slim-check
    cmd-check tmux nvim lazygit sd bat htop atuin gawk carapace direnv shellcheck shfmt ug tldr direnv jq yq gum bat delta just dialog btm yazi

    if not (has-cmd fd) and not (has-cmd fdfind) {
        warn "fd or fdfind not found"
    }
}

# Shell mainstall
export def shell-mainstall []: nothing -> nothing {
    min-binstall
    shell-binstall
    shell-config-install
    terminal-config-install
    shell-check
}

# VM check
export def vm-check []: nothing -> nothing {
    min-check

    if (is-linux) {
        cmd-check virt-install virt-xml virsh jq virt-cat qemu-img wget xorriso
        if (is-desktop) {
            cmd-check virt-viewer virt-manager
        }
    } else if (is-mac) {
        cmd-check jq colima orbstack
    }
}

# VM mainstall
export def vm-mainstall []: nothing -> nothing {
    min-mainstall
    vm-groupstall
    vm-check
}

# Work check
export def work-check []: nothing -> nothing {
    shell-slim-check
    cmd-check code docker
}

# Work mainstall
export def work-mainstall []: nothing -> nothing {
    min-mainstall
    work-groupstall
    apps-slim-install
    work-check
}

# Desktop-slim mainstall
export def desktop-slim-mainstall []: nothing -> nothing {
    shell-slim-mainstall
    vm-groupstall
    vscode-groupstall

    apps-slim-install

    vm-check
    work-check
}

# Desktop mainstall
export def desktop-mainstall []: nothing -> nothing {
    shell-mainstall
    vm-groupstall
    vscode-groupstall

    apps-install

    vm-check
    work-check
}

# VSCode groupstall
export def vscode-groupstall []: nothing -> nothing {
    # This would call the OS-specific vscode_binstall
    # Then jetbrains-mono-install and vscode-confstall
    jetbrains-mono-install
    vscode-confstall
}

# Nix dotfiles install (placeholder)
export def nix-dotfiles-install []: nothing -> nothing {
    # Implementation would clone/copy nix dotfiles
    slog "Nix dotfiles install placeholder"
}
