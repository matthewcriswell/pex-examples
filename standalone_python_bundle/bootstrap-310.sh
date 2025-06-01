#!/usr/bin/env bash
set -xeuo pipefail

# Global defaults
VERBOSE=false
CONFIG_FILE="default.conf"
PYTHON_TARBALL_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20250529/cpython-3.10.17+20250529-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz"
PYTHON_SHA_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20250529/cpython-3.10.17+20250529-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz.sha256"
TARBALL_NAME="cpython-3.10.17+20250529-aarch64-unknown-linux-gnu-install_only.tar.gz"
TARBALL_PATH="$HOME/tools/$TARBALL_NAME"
INSTALL_DIR="$HOME/tools/python3.10.17"

# Usage function
usage() {
  echo "Usage: $0 [-v] [-f config_file] [-h]"
  echo "  -v                Enable verbose mode"
  echo "  -f config_file    Specify custom config file"
  echo "  -h                Show this help message"
  exit 1
}

# Check for required tools
check_requirements() {
  local required=(curl tar sha256sum)
  for util in "${required[@]}"; do
    if ! command -v "$util" >/dev/null 2>&1; then
      echo "Error: '$util' not found."
      exit 1
    fi
  done
}

# Parse command-line arguments
parse_args() {
  while getopts ":vf:h" opt; do
    case $opt in
      v) VERBOSE=true ;;
      f) CONFIG_FILE="$OPTARG" ;;
      h) usage ;;
      \?) echo "Invalid option: -$OPTARG"; usage ;;
      :) echo "Option -$OPTARG requires an argument."; usage ;;
    esac
  done
  shift $((OPTIND -1))
}

# Actual bootstrap logic
bootstrap() {
  if [ "$VERBOSE" = true ]; then
    echo "Verbose mode ON"
    echo "Using config: $CONFIG_FILE"
  fi
  echo "Bootstrapping..."

  # Create the tools directory if it doesn't exist
  mkdir -p "$HOME/tools"

  echo "🟩 Checking for existing tarball..."
  if [[ -f "$TARBALL_PATH" ]]; then
    echo "🟩 Verifying existing tarball checksum..."
    curl -L -o "$TARBALL_PATH.sha256" "$PYTHON_SHA_URL"
    # Remove filename from SHA file if needed (some tools expect only hash)
    SHA_EXPECTED=$(cat "$TARBALL_PATH.sha256")
    SHA_ACTUAL=$(sha256sum "$TARBALL_PATH" | awk '{print $1}')
    if [[ "$SHA_EXPECTED" == "$SHA_ACTUAL" ]]; then
      echo "✅ Tarball checksum matches. No re-download needed."
    else
      echo "⚠️  Checksum mismatch! Re-downloading tarball..."
      curl -L -o "$TARBALL_PATH" "$PYTHON_TARBALL_URL"
    fi
  else
    echo "🟩 Downloading tarball and checksum..."
    curl -L -o "$TARBALL_PATH" "$PYTHON_TARBALL_URL"
    curl -L -o "$TARBALL_PATH.sha256" "$PYTHON_SHA_URL"
  fi
  
  echo "🟩 Verifying checksum after download..."
  #sha256sum -c "$TARBALL_PATH.sha256"
  SHA_EXPECTED=$(cat "$TARBALL_PATH.sha256")
  SHA_ACTUAL=$(sha256sum "$TARBALL_PATH" | awk '{print $1}')
  if [[ "$SHA_EXPECTED" == "$SHA_ACTUAL" ]]; then
    echo "✅ Tarball checksum matches. No re-download needed."
  else
    echo "⚠️  Checksum mismatch! Re-downloading tarball..."
    exit 1
  fi
  
  echo "🟩 Extracting to $INSTALL_DIR..."
  mkdir -p "$INSTALL_DIR"
  tar --zstd -xf "$TARBALL_PATH" -C "$HOME/tools"
}

# Main function
main() {
  parse_args "$@"
  check_requirements
  bootstrap
}

# Call main
main "$@"
