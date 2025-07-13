#!/bin/bash

# =============================================================================
# Flux Installation Script
# =============================================================================
# This script installs Flux (GitOps toolkit for Kubernetes)
# 
# Dependencies: curl, tar, chmod, ln
# Supported OS: Linux, macOS
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# =============================================================================
# Flux Installation Functions
# =============================================================================
setup_flux_directories() {
    log_step "Setting up Flux directories..."
    
    create_directories ~/.zshrc.d ~/.oh-my-zsh/completions ~/bin ~/tools/flux
}

get_flux_version() {
    log_step "Getting latest Flux version..."
    
    local version=$(get_latest_github_release "fluxcd/flux2")
    
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest Flux version"
        exit 1
    fi
    
    log_info "Latest Flux version: ${version}"
    echo "$version"
}

build_flux_download_url() {
    local version="$1"
    local os=$(get_os)
    local arch=$(get_arch)
    
    # Remove 'v' prefix from version for download URL
    local version_clean=${version#v}
    
    echo "https://github.com/fluxcd/flux2/releases/download/${version}/flux_${version_clean}_${os}_${arch}.tar.gz"
}

download_and_extract_flux() {
    local version="$1"
    local download_url="$2"
    local output_path="~/tools/flux/flux-${version}"
    
    log_step "Downloading and extracting Flux ${version}..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    trap 'cleanup_temp_dir "$temp_dir"' EXIT
    
    # Download tarball
    download_file "$download_url" "${temp_dir}/flux.tar.gz" "Flux tarball"
    
    # Extract flux binary
    tar -xzf "${temp_dir}/flux.tar.gz" -C "${temp_dir}" flux
    
    # Move to final location
    cp "${temp_dir}/flux" "$output_path"
    
    log_success "Flux binary extracted successfully"
}

install_flux_binary() {
    local version="$1"
    local binary_path="~/tools/flux/flux-${version}"
    local symlink_path="~/bin/flux"
    
    log_step "Installing Flux binary..."
    
    install_binary "$binary_path" "$symlink_path" "$version" "Flux"
}

setup_flux_completion() {
    log_step "Setting up Flux shell completion..."
    
    setup_shell_completion "flux" "~/.oh-my-zsh/completions"
}

verify_flux_installation() {
    log_step "Verifying Flux installation..."
    
    if command_exists flux; then
        local version=$(flux version --client 2>/dev/null || echo "unknown")
        log_success "Flux installed successfully (version: ${version})"
    else
        log_error "Flux installation verification failed"
        exit 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================
main() {
    log_info "Starting Flux installation..."
    
    # Check if not running as root
    check_root
    
    # Check dependencies
    check_dependencies curl tar
    
    # Check if Flux is already installed
    if command_exists flux; then
        log_warning "Flux appears to be already installed"
        read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Setup directories
    setup_flux_directories
    
    # Get latest version
    local version=$(get_flux_version)
    
    # Build download URL
    local download_url=$(build_flux_download_url "$version")
    
    # Download, extract and install
    download_and_extract_flux "$version" "$download_url"
    install_flux_binary "$version"
    
    # Setup completion
    setup_flux_completion
    
    # Verify installation
    verify_flux_installation
    
    log_success "Flux installation completed!"
    log_info "Flux is now available at: ~/bin/flux"
    log_info "To test Flux, run: flux version"
    log_info "To bootstrap Flux in a cluster, run: flux bootstrap"
}

# Run main function
main "$@" 