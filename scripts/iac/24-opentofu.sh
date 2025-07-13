#!/bin/bash

# =============================================================================
# OpenTofu Installation Script
# =============================================================================
# This script installs OpenTofu (Infrastructure as Code tool)
# 
# Dependencies: curl, unzip, chmod, ln
# Supported OS: Linux, macOS
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# =============================================================================
# OpenTofu Installation Functions
# =============================================================================
setup_opentofu_directories() {
    log_step "Setting up OpenTofu directories..."
    
    create_directories ~/bin ~/tools/opentofu
}

get_opentofu_version() {
    log_step "Getting latest OpenTofu version..."
    
    local version=$(get_latest_github_release "opentofu/opentofu")
    
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest OpenTofu version"
        exit 1
    fi
    
    log_info "Latest OpenTofu version: ${version}"
    echo "$version"
}

build_opentofu_download_url() {
    local version="$1"
    local os=$(get_os)
    local arch=$(get_arch)
    
    # Remove 'v' prefix from version for download URL
    local version_clean=${version#v}
    
    echo "https://github.com/opentofu/opentofu/releases/download/${version}/tofu_${version_clean}_${os}_${arch}.zip"
}

download_and_extract_opentofu() {
    local version="$1"
    local download_url="$2"
    local output_path="~/tools/opentofu/tofu-${version}"
    
    log_step "Downloading and extracting OpenTofu ${version}..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    trap 'cleanup_temp_dir "$temp_dir"' EXIT
    
    # Download zip file
    download_file "$download_url" "${temp_dir}/opentofu-${version}.zip" "OpenTofu zip file"
    
    # Extract tofu binary
    cd "${temp_dir}"
    unzip -q "opentofu-${version}.zip"
    
    # Move to final location
    mv "tofu" "$output_path"
    
    log_success "OpenTofu binary extracted successfully"
}

install_opentofu_binary() {
    local version="$1"
    local binary_path="~/tools/opentofu/tofu-${version}"
    local symlink_path="~/bin/tofu"
    
    log_step "Installing OpenTofu binary..."
    
    install_binary "$binary_path" "$symlink_path" "$version" "OpenTofu"
}

verify_opentofu_installation() {
    log_step "Verifying OpenTofu installation..."
    
    if command_exists tofu; then
        local version=$(tofu version 2>/dev/null || echo "unknown")
        log_success "OpenTofu installed successfully (version: ${version})"
    else
        log_error "OpenTofu installation verification failed"
        exit 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================
main() {
    log_info "Starting OpenTofu installation..."
    
    # Check if not running as root
    check_root
    
    # Check dependencies
    check_dependencies curl unzip
    
    # Check if OpenTofu is already installed
    if command_exists tofu; then
        log_warning "OpenTofu appears to be already installed"
        read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Setup directories
    setup_opentofu_directories
    
    # Get latest version
    local version=$(get_opentofu_version)
    
    # Build download URL
    local download_url=$(build_opentofu_download_url "$version")
    
    # Download, extract and install
    download_and_extract_opentofu "$version" "$download_url"
    install_opentofu_binary "$version"
    
    # Verify installation
    verify_opentofu_installation
    
    log_success "OpenTofu installation completed!"
    log_info "OpenTofu is now available at: ~/bin/tofu"
    log_info "To test OpenTofu, run: tofu version"
    log_info "To initialize a project, run: tofu init"
}

# Run main function
main "$@" 