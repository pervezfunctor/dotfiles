#!/usr/bin/env nu

# Nix Darwin/Home-Manager/NixOS deployment helper
# Usage: ndh.nu [flake_path]
# If no flake_path is provided, uses current directory

let flake_path = if ($env.ARGS | length) > 0 {
    $env.ARGS | get 0
} else {
    "."
}

def require [cmd: string] {
    if (which $cmd | length) == 0 {
        print $"Missing dependency: ($cmd)"
        exit 1
    }
}

def has_attr [attr: string, flake: string] {
    let result = do { nix eval --json $"($flake)#($attr)" } | complete
    $result.exit_code == 0
}

# Check required dependencies upfront
require nix
require jq
require fzf

mut targets = {}

if (has_attr "nixosConfigurations" $flake_path) {
    $targets = ($targets | merge { nixos: "nixosConfigurations" })
}

if (has_attr "darwinConfigurations" $flake_path) {
    $targets = ($targets | merge { darwin: "darwinConfigurations" })
}

if (has_attr "homeConfigurations" $flake_path) {
    $targets = ($targets | merge { home: "homeConfigurations" })
}

if ($targets | columns | length) == 0 {
    print "No supported flake outputs found"
    exit 1
}

# Check for darwin-rebuild and home-manager early if those targets exist
if ($targets | columns | any {|it| $it == "darwin"}) {
    require darwin-rebuild
}

if ($targets | columns | any {|it| $it == "home"}) {
    require home-manager
}

let target_columns = $targets | columns | sort
let type_result = do { $target_columns | to text | fzf --prompt="Config type ❯ " } | complete

if $type_result.exit_code != 0 {
    exit 0
}

let type = $type_result.stdout | str trim

if ($type | is-empty) {
    exit 0
}

let attr = $targets | get $type

let eval_result = do { nix eval --json $"($flake_path)#($attr)" } | complete
if $eval_result.exit_code != 0 {
    print $"Failed to evaluate ($attr)"
    exit 1
}
let names = $eval_result.stdout | from json | columns

if ($names | length) == 0 {
    print $"No targets found for ($type)"
    exit 1
}

let name_result = do { $names | to text | fzf --prompt=($"($type) target ❯ ") } | complete

if $name_result.exit_code != 0 {
    exit 0
}

let name = $name_result.stdout | str trim

if ($name | is-empty) {
    exit 0
}

match $type {
    "nixos" => {
        print $"Deploying NixOS configuration: ($name)"
        let result = do { sudo nixos-rebuild switch --flake $"($flake_path)#($name)" } | complete
        if $result.exit_code != 0 {
            print $"Error: nixos-rebuild failed with exit code ($result.exit_code)"
            exit $result.exit_code
        }
        print "✓ NixOS deployment successful"
    }
    "darwin" => {
        print $"Deploying Darwin configuration: ($name)"
        let result = do { darwin-rebuild switch --flake $"($flake_path)#($name)" } | complete
        if $result.exit_code != 0 {
            print $"Error: darwin-rebuild failed with exit code ($result.exit_code)"
            exit $result.exit_code
        }
        print "✓ Darwin deployment successful"
    }
    "home" => {
        print $"Deploying Home Manager configuration: ($name)"
        let result = do { home-manager switch --flake $"($flake_path)#($name)" } | complete
        if $result.exit_code != 0 {
            print $"Error: home-manager failed with exit code ($result.exit_code)"
            exit $result.exit_code
        }
        print "✓ Home Manager deployment successful"
    }
    _ => {
        print $"Error: Unknown configuration type: ($type)"
        exit 1
    }
}
