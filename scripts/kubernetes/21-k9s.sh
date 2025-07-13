#!/bin/bash

# =============================================================================
# k9s Installation Script
# =============================================================================
# This script installs k9s (Kubernetes CLI to manage clusters)
# 
# Dependencies: curl, tar, chmod, ln
# Supported OS: Linux, macOS
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# =============================================================================
# k9s Installation Functions
# =============================================================================
setup_k9s_directories() {
    log_step "Setting up k9s directories..."
    
    create_directories ~/bin ~/tools/k9s
}

get_k9s_version() {
    log_step "Getting latest k9s version..."
    
    local version=$(get_latest_github_release "derailed/k9s")
    
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest k9s version"
        exit 1
    fi
    
    log_info "Latest k9s version: ${version}"
    echo "$version"
}

build_k9s_download_url() {
    local version="$1"
    local os=$(get_os)
    local arch=$(get_arch)
    
    echo "https://github.com/derailed/k9s/releases/download/${version}/k9s_${os}_${arch}.tar.gz"
}

download_and_extract_k9s() {
    local version="$1"
    local download_url="$2"
    local output_path="~/tools/k9s/k9s-${version}"
    
    log_step "Downloading and extracting k9s ${version}..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    trap 'cleanup_temp_dir "$temp_dir"' EXIT
    
    # Download tarball
    download_file "$download_url" "${temp_dir}/k9s-${version}.tar.gz" "k9s tarball"
    
    # Extract k9s binary
    tar -xzf "${temp_dir}/k9s-${version}.tar.gz" -C "${temp_dir}"
    
    # Move to final location
    mv "${temp_dir}/k9s" "$output_path"
    
    log_success "k9s binary extracted successfully"
}

install_k9s_binary() {
    local version="$1"
    local binary_path="~/tools/k9s/k9s-${version}"
    local symlink_path="~/bin/k9s"
    
    log_step "Installing k9s binary..."
    
    install_binary "$binary_path" "$symlink_path" "$version" "k9s"
}

setup_k9s_completion() {
    log_step "Setting up k9s shell completion..."
    
    # k9s completion might not be available in all versions
    if ~/bin/k9s completion zsh &>/dev/null; then
        setup_shell_completion "k9s" "~/.oh-my-zsh/completions"
    else
        log_warning "k9s shell completion not available in this version"
    fi
}

verify_k9s_installation() {
    log_step "Verifying k9s installation..."
    
    if command_exists k9s; then
        local version=$(k9s version --short 2>/dev/null || echo "unknown")
        log_success "k9s installed successfully (version: ${version})"
    else
        log_error "k9s installation verification failed"
        exit 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================
main() {
    log_info "Starting k9s installation..."
    
    # Check if not running as root
    check_root
    
    # Check dependencies
    check_dependencies curl tar
    
    # Check if k9s is already installed
    if command_exists k9s; then
        log_warning "k9s appears to be already installed"
        read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Setup directories
    setup_k9s_directories
    
    # Get latest version
    local version=$(get_k9s_version)
    
    # Build download URL
    local download_url=$(build_k9s_download_url "$version")
    
    # Download, extract and install
    download_and_extract_k9s "$version" "$download_url"
    install_k9s_binary "$version"
    
    # Setup completion
    setup_k9s_completion
    
    # Verify installation
    verify_k9s_installation
    
    log_success "k9s installation completed!"
    log_info "k9s is now available at: ~/bin/k9s"
    log_info "To test k9s, run: k9s version"
    log_info "To start k9s, run: k9s"
}

# Run main function
main "$@" 