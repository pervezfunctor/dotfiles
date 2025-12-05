#!/usr/bin/env bash

set -euo pipefail -o errtrace

usage() {
  cat <<EOF
Usage: $0 [-t TARGET_DIR] SOURCE_DIR

A simple GNU Stow equivalent that transforms dot-* files/folders to .*

Options:
    -t TARGET_DIR   Target directory for symlinks (default: \$HOME)
    -h              Show this help message

Examples:
    $0 dotfiles/
    $0 -t /home/user dotfiles/

The script will:
- Transform dot-config/dot-zshrc to .config/.zshrc
- Create necessary parent directories
- Handle conflicts intelligently
- Create symlinks to the original files in SOURCE_DIR
EOF
}

transform_dot_name() {
  local name="$1"
  if [[ "$name" =~ ^dot-(.+)$ ]]; then
    echo ".${BASH_REMATCH[1]}"
  else
    echo "$name"
  fi
}

get_transformed_path() {
  local source_path="$1"
  local source_dir="$2"

  # Remove the source directory prefix and leading slash
  local rel_path="${source_path#"$source_dir"}"
  rel_path="${rel_path#/}"

  # Split path into components and transform each
  IFS='/' read -ra path_parts <<<"$rel_path"
  local transformed_parts=()

  for part in "${path_parts[@]}"; do
    if [[ -n "$part" ]]; then
      transformed_parts+=("$(transform_dot_name "$part")")
    fi
  done

  # Join the transformed parts
  local transformed_path=""
  for part in "${transformed_parts[@]}"; do
    if [[ -n "$transformed_path" ]]; then
      transformed_path="$transformed_path/$part"
    else
      transformed_path="$part"
    fi
  done

  echo "$transformed_path"
}

has_dot_transformation() {
  local path="$1"
  [[ "$path" =~ dot- ]]
}

ensure_directory() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    log_info "Creating directory: $dir"
    mkdir -p "$dir"
  fi
}

handle_conflict() {
  local target="$1"
  local source="$2"

  if [[ -L "$target" ]]; then
    local current_link
    current_link=$(readlink "$target")
    if [[ "$current_link" == "$source" ]]; then
      log_info "Symlink already exists and points to correct location: $target"
      return 0
    else
      log_warning "Symlink exists but points to different location:"
      log_warning "  Current: $target -> $current_link"
      log_warning "  Wanted:  $target -> $source"
      return 1
    fi
  elif [[ -e "$target" ]]; then
    log_error "Target exists and is not a symlink: $target"
    log_error "Please resolve this conflict manually"
    return 1
  fi

  return 0
}

create_symlink() {
  local source="$1"
  local target="$2"

  # Ensure target directory exists
  local target_dir
  target_dir=$(dirname "$target")
  ensure_directory "$target_dir"

  # Handle conflicts
  if [[ -e "$target" ]] || [[ -L "$target" ]]; then
    if ! handle_conflict "$target" "$source"; then
      return 1
    fi
    if [[ -L "$target" ]]; then
      return 0 # Already linked correctly
    fi
  fi

  # Create the symlink
  log_info "Creating symlink: $target -> $source"
  ln -s "$source" "$target"
  log_success "Created: $target -> $source"
}

process_item() {
  local source_path="$1"
  local source_dir="$2"
  local target_dir="$3"

  # Skip if source doesn't exist
  if [[ ! -e "$source_path" ]]; then
    log_warning "Source does not exist: $source_path"
    return 1
  fi

  # Get transformed relative path
  local transformed_rel_path
  transformed_rel_path=$(get_transformed_path "$source_path" "$source_dir")
  local target_path="$target_dir/$transformed_rel_path"

  # Log transformation if it occurred
  if has_dot_transformation "$source_path"; then
    local original_rel_path="${source_path#"$source_dir"}"
    original_rel_path="${original_rel_path#/}"
    log_info "Transforming: $original_rel_path -> $transformed_rel_path"
  fi

  # Create symlink
  create_symlink "$source_path" "$target_path"
}

stow_directory() {
  local source_dir="$1"
  local target_dir="$2"

  log_info "Stowing from '$source_dir' to '$target_dir'"

  # Find all files and directories in source
  local items_processed=0
  local items_failed=0

  while IFS= read -r -d '' item; do
    if process_item "$item" "$source_dir" "$target_dir"; then
      ((items_processed++))
    else
      ((items_failed++))
    fi
  done < <(find "$source_dir" -mindepth 1 -print0)

  log_success "Processed $items_processed items"
  if [[ $items_failed -gt 0 ]]; then
    log_warning "$items_failed items failed"
    return 1
  fi
}

validate_args() {
  if [[ -z "$SOURCE_DIR" ]]; then
    log_error "Source directory is required"
    usage
    exit 1
  fi

  if [[ ! -d "$SOURCE_DIR" ]]; then
    log_error "Source directory does not exist: $SOURCE_DIR"
    exit 1
  fi

  if [[ ! -d "$TARGET_DIR" ]]; then
    log_error "Target directory does not exist: $TARGET_DIR"
    exit 1
  fi

  # Convert to absolute paths
  SOURCE_DIR=$(realpath "$SOURCE_DIR")
  TARGET_DIR=$(realpath "$TARGET_DIR")

  log_info "Source directory: $SOURCE_DIR"
  log_info "Target directory: $TARGET_DIR"
}

parse_args() {
  while getopts "t:h" opt; do
    case $opt in
    t)
      TARGET_DIR="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      log_error "Invalid option: -$OPTARG"
      usage
      exit 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ $# -eq 1 ]]; then
    SOURCE_DIR="$1"
  else
    log_error "Exactly one source directory is required"
    usage
    exit 1
  fi
}

main() {
  validate_args
  parse_args "$@"

  stow_directory "$SOURCE_DIR" "$TARGET_DIR"
}

main "$@"
