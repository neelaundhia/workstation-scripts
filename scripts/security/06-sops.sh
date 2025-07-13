#!/bin/bash

# =============================================================================
# SOPS Installation Script
# =============================================================================
# This script installs SOPS (Secrets OPerationS) for encrypted file management
# 
# Dependencies: curl, chmod, ln
# Supported OS: Linux, macOS
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# =============================================================================
# SOPS Installation Functions
# =============================================================================
setup_sops_directories() {
    log_step "Setting up SOPS directories..."
    
    create_directories ~/bin ~/tools/sops
}

get_sops_version() {
    log_step "Getting latest SOPS version..."
    
    local version=$(get_latest_github_release "getsops/sops")
    
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest SOPS version"
        exit 1
    fi
    
    log_info "Latest SOPS version: ${version}"
    echo "$version"
}

build_sops_binary_name() {
    local version="$1"
    local os=$(get_os)
    local arch=$(get_arch)
    
    # Handle OS-specific cases
    case "${os}" in
        darwin|linux)
            echo "sops-v${version}.${os}.${arch}"
            ;;
        *)
            log_error "Unsupported operating system: ${os}"
            exit 1
            ;;
    esac
}

download_sops_binary() {
    local version="$1"
    local binary_name="$2"
    local download_url="https://github.com/getsops/sops/releases/download/v${version}/${binary_name}"
    local output_path="~/tools/sops/sops-v${version}"
    
    log_step "Downloading SOPS ${version}..."
    
    download_file "$download_url" "$output_path" "SOPS binary"
}

install_sops_binary() {
    local version="$1"
    local binary_path="~/tools/sops/sops-v${version}"
    local symlink_path="~/bin/sops"
    
    log_step "Installing SOPS binary..."
    
    install_binary "$binary_path" "$symlink_path" "$version" "SOPS"
}

verify_sops_installation() {
    log_step "Verifying SOPS installation..."
    
    if command_exists sops; then
        local version=$(sops --version 2>/dev/null || echo "unknown")
        log_success "SOPS installed successfully (version: ${version})"
    else
        log_error "SOPS installation verification failed"
        exit 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================
main() {
    log_info "Starting SOPS installation..."
    
    # Check if not running as root
    check_root
    
    # Check dependencies
    check_dependencies curl
    
    # Check if SOPS is already installed
    if command_exists sops; then
        log_warning "SOPS appears to be already installed"
        read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Setup directories
    setup_sops_directories
    
    # Get latest version
    local version=$(get_sops_version)
    
    # Build binary name
    local binary_name=$(build_sops_binary_name "$version")
    
    # Download and install
    download_sops_binary "$version" "$binary_name"
    install_sops_binary "$version"
    
    # Verify installation
    verify_sops_installation
    
    log_success "SOPS installation completed!"
    log_info "SOPS is now available at: ~/bin/sops"
    log_info "To test SOPS, run: sops --version"
}

# Run main function
main "$@" 