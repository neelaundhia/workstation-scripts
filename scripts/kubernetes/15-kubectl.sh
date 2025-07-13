#!/bin/bash

# =============================================================================
# kubectl Installation Script
# =============================================================================
# This script installs kubectl (Kubernetes command-line tool)
# 
# Dependencies: curl, chmod, ln
# Supported OS: Linux, macOS
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# =============================================================================
# kubectl Installation Functions
# =============================================================================
setup_kubectl_directories() {
    log_step "Setting up kubectl directories..."
    
    create_directories ~/.zshrc.d ~/.oh-my-zsh/completions ~/bin ~/tools/kubectl
}

get_kubectl_version() {
    log_step "Getting latest stable kubectl version..."
    
    local version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest kubectl version"
        exit 1
    fi
    
    log_info "Latest kubectl version: ${version}"
    echo "$version"
}

build_kubectl_download_url() {
    local version="$1"
    local os=$(get_os)
    local arch=$(get_arch)
    
    echo "https://dl.k8s.io/release/${version}/bin/${os}/${arch}/kubectl"
}

download_kubectl_binary() {
    local version="$1"
    local download_url="$2"
    local output_path="~/tools/kubectl/kubectl-${version}"
    
    log_step "Downloading kubectl ${version}..."
    
    download_file "$download_url" "$output_path" "kubectl binary"
}

install_kubectl_binary() {
    local version="$1"
    local binary_path="~/tools/kubectl/kubectl-${version}"
    local symlink_path="~/bin/kubectl"
    
    log_step "Installing kubectl binary..."
    
    install_binary "$binary_path" "$symlink_path" "$version" "kubectl"
}

setup_kubectl_completion() {
    log_step "Setting up kubectl shell completion..."
    
    setup_shell_completion "kubectl" "~/.oh-my-zsh/completions"
}

setup_kubectl_configuration() {
    log_step "Setting up kubectl configuration..."
    
    copy_config_file \
        "config/zsh/.zshrc.d/kubectl.source" \
        "~/.zshrc.d/kubectl.source" \
        "kubectl configuration"
}

verify_kubectl_installation() {
    log_step "Verifying kubectl installation..."
    
    if command_exists kubectl; then
        local version=$(kubectl version --client --short 2>/dev/null || echo "unknown")
        log_success "kubectl installed successfully (version: ${version})"
    else
        log_error "kubectl installation verification failed"
        exit 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================
main() {
    log_info "Starting kubectl installation..."
    
    # Check if not running as root
    check_root
    
    # Check dependencies
    check_dependencies curl
    
    # Check if kubectl is already installed
    if command_exists kubectl; then
        log_warning "kubectl appears to be already installed"
        read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Setup directories
    setup_kubectl_directories
    
    # Get latest version
    local version=$(get_kubectl_version)
    
    # Build download URL
    local download_url=$(build_kubectl_download_url "$version")
    
    # Download and install
    download_kubectl_binary "$version" "$download_url"
    install_kubectl_binary "$version"
    
    # Setup completion and configuration
    setup_kubectl_completion
    setup_kubectl_configuration
    
    # Verify installation
    verify_kubectl_installation
    
    log_success "kubectl installation completed!"
    log_info "kubectl is now available at: ~/bin/kubectl"
    log_info "To test kubectl, run: kubectl version --client"
    log_info "To configure kubectl, run: kubectl config set-cluster"
}

# Run main function
main "$@" 