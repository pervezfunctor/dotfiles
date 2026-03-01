# generate-readme.nix
{ builtins }:

let
  vscodeSettings = builtins.readFile ./config/vscode/settings.json;

in
''
  # NixOS Configuration

  ## Manual Installation

  Get this config on your system with the following commands.

  \`\`\`bash
  nix-shell -p git micro # use your favorite editor instead of micro
  git clone https://github.com/pervezfunctor/nix-config.git
  \`\`\`

  Exit nix-shell with Ctrl+D. Execute the following commands.

  \`\`\`bash
  cd nix-config
  rm -rf .git
  mkdir -p hosts/$(hostname)
  cp /etc/nixos/* hosts/$(hostname)/
  micro flake.nix
  \`\`\`

  Copy a section for nixos config like nuc-vm and modify it as you need it. For example minimal configuration would be the following (You could get your hostname with `hostname` command).

  \`\`\`nix
  "<your-host-name>" = mkOS [ ./hosts/<your-host-name>/configuration.nix ] [];
  \`\`\`

  Now execute the following commands.

  \`\`\`bash
  git init
  git add .
  sudo nixos-rebuild switch --flake .#
  \`\`\`

  Create an empty `zsh` rc file.

  \`\`\`bash
  touch ~/.zshrc
  \`\`\`

  Optionally, install the following `vscode` extensions.

  \`\`\`bash
  code --install-extension jnoortheen.nix-ide
  code --install-extension github.github-vscode-theme
  \`\`\`

  Add the following vscode settings (Optional)

  \`\`\`json
  ${vscodeSettings}
  \`\`\`

  Reboot your system. Remember to commit and push your code to a new repository (github/codeberg).

  ## Automated setup

  To automate the entire setup process, download and run the provided `setup.sh` script:

  \`\`\`bash
  curl -O https://raw.githubusercontent.com/pervezfunctor/nix-config/main/setup.sh
  chmod +x setup.sh
  ./setup.sh
  \`\`\`
''
