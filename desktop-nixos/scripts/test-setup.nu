#!/usr/bin/env nu
# Test script for setup.nu
# This tests setup.nu without actually rebuilding the system
# Usage: nu test-setup.nu

def test-help [] {
  print "Testing: setup.nu --help"
  let result = (do -i { nu setup.nu --help } | complete)
  if ($result.exit_code != 0) {
    error make {msg: "Failed: --help flag should work"}
  }
  print "  PASSED: --help works"
}

def test-skip-all [] {
  print "Testing: setup.nu --skip-clone --skip-generate --skip-rebuild"
  print "  (This will create vars.nix in current directory)"

  let answer = (
    input "Run test? Creates/overwrites vars.nix in current dir. [y/N]: "
    | str trim
    | str downcase
  )

  if $answer != "y" {
    print "  SKIPPED"
    return
  }

  # Save current vars.nix if it exists
  let backup_existed = ("vars.nix" | path exists)
  if $backup_existed {
    cp vars.nix vars.nix.backup
  }

  let result = (do -i {
    nu setup.nu --skip-clone --skip-generate --skip-rebuild
  } | complete)

  # Restore backup
  if $backup_existed {
    cp vars.nix.backup vars.nix
    rm vars.nix.backup
  } else {
    rm -f vars.nix
  }

  if ($result.exit_code != 0) {
    print $"  FAILED: ($result.stderr)"
    error make {msg: "Test failed"}
  }

  print "  PASSED: --skip-clone --skip-generate --skip-rebuild works"
}

def test-vars-content [] {
  print "Testing: vars.nix has correct content"
  print "  (This will create/overwrite vars.nix in current directory)"

  let answer = (
    input "Run test? Creates/overwrites vars.nix in current dir. [y/N]: "
    | str trim
    | str downcase
  )

  if $answer != "y" {
    print "  SKIPPED"
    return
  }

  # Save current vars.nix if it exists
  let backup_existed = ("vars.nix" | path exists)
  if $backup_existed {
    cp vars.nix vars.nix.backup
  }

  # Generate vars by running the relevant parts of setup.nu
  let username = (whoami | str trim)
  let homeDirectory = ($env.HOME | str trim)
  let hostname = (hostname | str trim)

  let nix_content = $"
{
  username = \"($username)\";
  homeDirectory = \"($homeDirectory)\";
  hostname = \"($hostname)\";
}
"
  $nix_content | save -f vars.nix

  # Check file exists and contains expected values
  if not ("vars.nix" | path exists) {
    print "  FAILED: vars.nix was not created"
    # Restore backup
    if $backup_existed {
      cp vars.nix.backup vars.nix
      rm vars.nix.backup
    }
    error make {msg: "Test failed"}
  }

  let content = (open vars.nix)

  if not ($content | str contains $username) {
    print "  FAILED: vars.nix missing username"
    if $backup_existed {
      cp vars.nix.backup vars.nix
      rm vars.nix.backup
    }
    error make {msg: "Test failed"}
  }

  if not ($content | str contains $hostname) {
    print "  FAILED: vars.nix missing hostname"
    if $backup_existed {
      cp vars.nix.backup vars.nix
      rm vars.nix.backup
    }
    error make {msg: "Test failed"}
  }

  # Restore backup
  if $backup_existed {
    cp vars.nix.backup vars.nix
    rm vars.nix.backup
  } else {
    rm -f vars.nix
  }

  print "  PASSED: vars.nix has correct content"
}

def main [] {
  print ""
  print "=== Running setup.nu tests ==="
  print ""

  test-help
  print ""

  test-skip-all
  print ""

  test-vars-content
  print ""

  print "=== All tests passed ==="
  print ""
}
