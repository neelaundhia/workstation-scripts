#!/bin/bash

# =============================================================================
# Common Utilities for Workstation Scripts
# =============================================================================
# This file contains shared functions and utilities used across all
# installation scripts in the workstation-scripts project.
# =============================================================================

set -euo pipefail

# =============================================================================
# Color Constants
# =============================================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# Logging Functions
# =============================================================================
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# =============================================================================
# System Detection Functions
# =============================================================================
get_os() {
    uname -s | tr '[:upper:]' '[:lower:]'
}

get_arch() {
    local arch=$(uname -m)
    case "${arch}" in
        x86_64)
            echo "amd64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        *)
            echo "${arch}"
            ;;
    esac
}

get_os_arch() {
    local os=$(get_os)
    local arch=$(get_arch)
    echo "${os}_${arch}"
}

# =============================================================================
# Validation Functions
# =============================================================================
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

check_dependencies() {
    local missing_deps=()
    
    for dep in "$@"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and try again"
        exit 1
    fi
}

# =============================================================================
# Directory Management Functions
# =============================================================================
create_directories() {
    for dir in "$@"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        fi
    done
}

# =============================================================================
# Download Functions
# =============================================================================
download_file() {
    local url="$1"
    local output_path="$2"
    local description="${3:-file}"
    
    log_info "Downloading ${description}..."
    
    if curl -fsSL -o "$output_path" "$url"; then
        log_success "${description} downloaded successfully"
    else
        log_error "Failed to download ${description}"
        return 1
    fi
}

get_latest_github_release() {
    local repo="$1"
    local version=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "$version"
}

# =============================================================================
# Installation Functions
# =============================================================================
install_binary() {
    local binary_path="$1"
    local symlink_path="$2"
    local version="$3"
    local tool_name="$4"
    
    # Make binary executable
    chmod +x "$binary_path"
    
    # Create/update symlink
    ln -sf "$binary_path" "$symlink_path"
    
    log_success "${tool_name} ${version} installed successfully"
}

setup_shell_completion() {
    local tool_name="$1"
    local completion_dir="$2"
    
    if [[ -d "$completion_dir" ]] && command_exists "$tool_name"; then
        if "$tool_name" completion zsh &>/dev/null; then
            "$tool_name" completion zsh > "${completion_dir}/_${tool_name}"
            log_info "Shell completion for ${tool_name} configured"
        fi
    fi
}

# =============================================================================
# Configuration Functions
# =============================================================================
copy_config_file() {
    local source="$1"
    local destination="$2"
    local description="${3:-configuration file}"
    
    if [[ -f "$source" ]]; then
        cp "$source" "$destination"
        log_success "${description} copied successfully"
    else
        log_warning "${description} not found at: $source"
    fi
}

# =============================================================================
# Cleanup Functions
# =============================================================================
cleanup_temp_dir() {
    local temp_dir="$1"
    if [[ -d "$temp_dir" ]]; then
        rm -rf "$temp_dir"
        log_info "Cleaned up temporary directory"
    fi
}

# =============================================================================
# Error Handling
# =============================================================================
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Error occurred in script at line ${line_number}"
    log_error "Exit code: ${exit_code}"
    exit $exit_code
}

# Set up error handling
trap 'handle_error $LINENO' ERR 