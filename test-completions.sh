#!/usr/bin/env bash

echo "Testing vm-create completion scripts..."
echo

# Test bash completion
echo "=== Testing Bash Completion ==="
if source bash/completions/vm-create.bash 2>/dev/null; then
  echo "✓ Bash completion script loaded successfully"

  # Check if completion is registered
  if complete -p vm-create | grep -q "_vm_create_completions"; then
    echo "✓ Bash completion registered for vm-create"
  else
    echo "✗ Bash completion not registered"
  fi
else
  echo "✗ Failed to load bash completion script"
fi

echo

# Test zsh completion syntax
echo "=== Testing Zsh Completion Syntax ==="
if zsh -n zsh/completions/_vm-create 2>/dev/null; then
  echo "✓ Zsh completion script has valid syntax"
else
  echo "✗ Zsh completion script has syntax errors"
fi

echo

# Test if files exist and have correct permissions
echo "=== Checking File Permissions ==="
if [[ -f bash/completions/vm-create.bash ]]; then
  echo "✓ Bash completion file exists"
  if [[ -r bash/completions/vm-create.bash ]]; then
    echo "✓ Bash completion file is readable"
  else
    echo "✗ Bash completion file is not readable"
  fi
else
  echo "✗ Bash completion file does not exist"
fi

if [[ -f zsh/completions/_vm-create ]]; then
  echo "✓ Zsh completion file exists"
  if [[ -r zsh/completions/_vm-create ]]; then
    echo "✓ Zsh completion file is readable"
  else
    echo "✗ Zsh completion file is not readable"
  fi
else
  echo "✗ Zsh completion file does not exist"
fi

echo
echo "=== Installation Instructions ==="
echo "To install the completions:"
echo
echo "For Bash (system-wide):"
echo "  sudo cp bash/completions/vm-create.bash /etc/bash_completion.d/"
echo
echo "For Bash (user):"
echo "  mkdir -p ~/.local/share/bash-completion/completions"
echo "  cp bash/completions/vm-create.bash ~/.local/share/bash-completion/completions/"
echo
echo "For Zsh (system-wide):"
echo "  sudo cp zsh/completions/_vm-create /usr/share/zsh/site-functions/"
echo
echo "For Zsh (user):"
echo "  mkdir -p ~/.zsh/completions"
echo "  cp zsh/completions/_vm-create ~/.zsh/completions/"
echo "  # Add to ~/.zshrc:"
echo "  fpath=(~/.zsh/completions \$fpath)"
echo "  autoload -U compinit && compinit"
echo
echo "See docs/vm-create-completion.md for more details."
