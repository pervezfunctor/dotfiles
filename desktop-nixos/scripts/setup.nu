#!/usr/bin/env nu

const REPO_URL = "https://github.com/pervezfunctor/niri-config.git"

def repo-dir [] {
  $"($env.HOME)/niri-config"
}

def confirm-prompt [prompt: string] {
  let answer = (input $prompt | str trim | str downcase)
  $answer == "y"
}

def confirm-overwrite [file: string] {
  if not (confirm-prompt $"($file) already exists. Overwrite? [y/N]: ") {
    error make {msg: "Aborted."}
  }
}

def clone-or-update-repo [repo_dir: string] {
  print $"Cloning/Updating repository from ($REPO_URL)..."

  if ($repo_dir | path exists) {
    print "Repository directory exists. Pulling latest changes..."
    let result = (do -i {
      ^nix run nixpkgs#git -- -C $repo_dir pull
    } | complete)
    if ($result.exit_code != 0) {
      error make {
        msg: $"Failed to pull latest changes.\n($result.stderr)"
      }
    }
  } else {
    let result = (do -i { git clone $REPO_URL $repo_dir } | complete)
    if ($result.exit_code != 0) {
      error make {
        msg: $"Failed to clone repository.\n($result.stderr)"
      }
    }
    if not ($repo_dir | path exists) {
      error make {
        msg: $"Clone succeeded but directory not found: ($repo_dir)"
      }
    }
  }

  print $"Working directory: ($repo_dir)"
}

def generate-vars [repo_dir: string] {
  let username = (whoami | str trim)
  let homeDirectory = ($env.HOME | str trim)
  let hostname = (hostname | str trim)
  let vars_file = $"($repo_dir)/vars.nix"

  if ($username | is-empty) {
    error make {msg: "Username is empty."}
  }

  if ($homeDirectory | is-empty) or not ($homeDirectory | path exists) {
    error make {
      msg: $"Invalid home directory: ($homeDirectory)"
    }
  }

  if ($hostname | is-empty) {
    error make {msg: "Hostname is empty."}
  }

  if ($vars_file | path exists) {
    confirm-overwrite $vars_file
  }

  let nix_content = $"
{
  username = \"($username)\";
  homeDirectory = \"($homeDirectory)\";
  hostname = \"($hostname)\";
}
"

  let result = (do -i {
    $nix_content | save -f $vars_file
  } | complete)

  if ($result.exit_code != 0) {
    error make {
      msg: $"Failed to write ($vars_file).\n($result.stderr)"
    }
  }

  print $"Generated ($vars_file): username=($username), home=($homeDirectory), hostname=($hostname)"
}

def ensure-nixos-files [target_dir: string, hardware_only: bool] {
  if $hardware_only {
    print $"Generating hardware-configuration.nix in ($target_dir)..."
    let hw_file = $"($target_dir)/hardware-configuration.nix"
    let result = (do -i { nixos-generate-config --dir $target_dir --show-hardware-config | save -f $hw_file } | complete)
    if ($result.exit_code != 0) {
      error make {
        msg: $"Failed to generate hardware configuration.\n($result.stderr)"
      }
    }
    print $"Generated ($hw_file) (hardware-only mode)"
  } else {
    print $"Regenerating NixOS configuration files in ($target_dir)..."
    let result = (do -i { nixos-generate-config --dir $target_dir } | complete)
    if ($result.exit_code != 0) {
      error make {
        msg: $"Failed to generate NixOS configuration.\n($result.stderr)"
      }
    }
  }
}

def add-to-git [repo_dir: string] {
  print ""
  print "Adding generated files to git..."

  let is_repo = (do -i {
    ^nix run nixpkgs#git -- -C $repo_dir rev-parse --git-dir
  } | complete | get exit_code) == 0

  if not $is_repo {
    print "Not in a git repository. Skipping git operations."
    return
  }

  let vars_file = $"($repo_dir)/vars.nix"
  let hw_file = $"($repo_dir)/hardware-configuration.nix"
  let cfg_file = $"($repo_dir)/configuration.nix"

  let result = (do -i {
    ^nix run nixpkgs#git -- -C $repo_dir add $vars_file $hw_file $cfg_file 2>/dev/null
  } | complete)

  if ($result.exit_code != 0) {
    error make {
      msg: $"Failed to add files to git.\n($result.stderr)"
    }
  }

  print "Files added to git. Review with: git status"
}

def prompt-rebuild [repo_dir: string, target: string] {
  print ""

  if (confirm-prompt "Rebuild NixOS system now? [y/N]: ") {
    print $"Running: sudo nixos-rebuild switch --flake ($repo_dir)/#($target)"
    sudo nixos-rebuild switch --flake $"($repo_dir)/#($target)"

    if ($env.LAST_EXIT_CODE? | default 0) != 0 {
      error make {
        msg: $"Failed to rebuild NixOS system"
      }
    }

    print "NixOS system rebuilt successfully."
  } else {
    print "Skipped rebuild. Run manually later:"
    print $"  sudo nixos-rebuild switch --flake ($repo_dir)/#($target)"
  }
}

def print-help [] {
  print ""
  print "Usage:"
  print "  nu setup.nu [--target <name>] [--skip-clone] [--skip-generate] [--skip-rebuild] [--hardware-only]"
  print ""
  print "Description:"
  print "  1. Clones niri-config repository to ~/niri-config"
  print "  2. Generates vars.nix with current user info"
  print "  3. Regenerates NixOS hardware and configuration files"
  print "  4. Adds generated files to git"
  print "  5. Prompts to rebuild the system"
  print ""
  print "Options:"
  print "  --target <name>   Flake target to rebuild (default: nixos)"
  print "  --skip-clone      Skip cloning/pulling repository"
  print "  --skip-generate   Skip generating NixOS config files"
  print "  --skip-rebuild    Skip rebuild prompt"
  print "  --hardware-only   Only generate hardware-configuration.nix"
  print "  -h, --help        Show this help message"
  print ""
}

def main [
  --target: string = "nixos"
  --skip-clone
  --skip-generate
  --skip-rebuild
  --hardware-only
  --help
] {
  if $help {
    print-help
    return
  }

  let repo_dir = (repo-dir)

  if not $skip_clone {
    clone-or-update-repo $repo_dir
  }

  if not ($repo_dir | path exists) {
    error make {
      msg: $"Repository directory does not exist: ($repo_dir)"
    }
  }

  generate-vars $repo_dir

  if not $skip_generate {
    ensure-nixos-files $repo_dir $hardware_only
  }

  add-to-git $repo_dir

  if not $skip_rebuild {
    prompt-rebuild $repo_dir $target
  }
}
