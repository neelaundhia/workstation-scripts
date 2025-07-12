#!/bin/bash

# =============================================================================
# Helm Installation Script
# =============================================================================
# This script installs Helm (Kubernetes package manager)
# 
# Dependencies: curl, tar, chmod, ln
# Supported OS: Linux, macOS
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# =============================================================================
# Helm Installation Functions
# =============================================================================
setup_helm_directories() {
    log_step "Setting up Helm directories..."
    
    create_directories ~/.zshrc.d ~/.oh-my-zsh/completions ~/bin ~/tools/helm
}

get_helm_version() {
    log_step "Getting latest Helm version..."
    
    local version=$(get_latest_github_release "helm/helm")
    
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest Helm version"
        exit 1
    fi
    
    log_info "Latest Helm version: ${version}"
    echo "$version"
}

build_helm_download_url() {
    local version="$1"
    local os=$(get_os)
    local arch=$(get_arch)
    
    echo "https://get.helm.sh/helm-${version}-${os}-${arch}.tar.gz"
}

download_and_extract_helm() {
    local version="$1"
    local download_url="$2"
    local output_path="~/tools/helm/helm-${version}"
    
    log_step "Downloading and extracting Helm ${version}..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    trap 'cleanup_temp_dir "$temp_dir"' EXIT
    
    # Download tarball
    download_file "$download_url" "${temp_dir}/helm-${version}.tar.gz" "Helm tarball"
    
    # Extract helm binary
    cd "${temp_dir}"
    tar xzf "helm-${version}.tar.gz"
    
    # Move to final location
    local os=$(get_os)
    local arch=$(get_arch)
    mv "${os}-${arch}/helm" "$output_path"
    
    log_success "Helm binary extracted successfully"
}

install_helm_binary() {
    local version="$1"
    local binary_path="~/tools/helm/helm-${version}"
    local symlink_path="~/bin/helm"
    
    log_step "Installing Helm binary..."
    
    install_binary "$binary_path" "$symlink_path" "$version" "Helm"
}

setup_helm_completion() {
    log_step "Setting up Helm shell completion..."
    
    setup_shell_completion "helm" "~/.oh-my-zsh/completions"
}

verify_helm_installation() {
    log_step "Verifying Helm installation..."
    
    if command_exists helm; then
        local version=$(helm version --short 2>/dev/null || echo "unknown")
        log_success "Helm installed successfully (version: ${version})"
    else
        log_error "Helm installation verification failed"
        exit 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================
main() {
    log_info "Starting Helm installation..."
    
    # Check if not running as root
    check_root
    
    # Check dependencies
    check_dependencies curl tar
    
    # Check if Helm is already installed
    if command_exists helm; then
        log_warning "Helm appears to be already installed"
        read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Setup directories
    setup_helm_directories
    
    # Get latest version
    local version=$(get_helm_version)
    
    # Build download URL
    local download_url=$(build_helm_download_url "$version")
    
    # Download, extract and install
    download_and_extract_helm "$version" "$download_url"
    install_helm_binary "$version"
    
    # Setup completion
    setup_helm_completion
    
    # Verify installation
    verify_helm_installation
    
    log_success "Helm installation completed!"
    log_info "Helm is now available at: ~/bin/helm"
    log_info "To test Helm, run: helm version"
    log_info "To add a repository, run: helm repo add"
}

# Run main function
main "$@" 