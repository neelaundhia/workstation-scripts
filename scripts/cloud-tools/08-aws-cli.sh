#!/bin/bash

# =============================================================================
# AWS CLI Installation Script
# =============================================================================
# This script installs AWS CLI on Ubuntu/Debian systems
# 
# Dependencies: curl, unzip, apt-get
# Supported OS: Ubuntu/Debian (Linux only)
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# =============================================================================
# AWS CLI Installation Functions
# =============================================================================
setup_aws_directories() {
    log_step "Setting up AWS CLI directories..."
    
    create_directories ~/.zshrc.d ~/.oh-my-zsh/completions ~/bin ~/tools/aws-cli
}

check_os_compatibility() {
    local os=$(get_os)
    
    if [[ "${os}" == "darwin" ]]; then
        log_error "MacOS is not supported for this script. Please use Homebrew instead."
        log_info "Run: brew install awscli"
        exit 1
    fi
}

install_dependencies() {
    log_step "Installing dependencies..."
    
    sudo apt update
    sudo apt install -y unzip
    
    log_success "Dependencies installed successfully"
}

build_aws_installer_name() {
    local os=$(get_os)
    local arch=$(get_arch)
    
    # AWS CLI uses different arch naming
    case "${arch}" in
        amd64)
            arch="x86_64"
            ;;
        arm64)
            arch="aarch64"
            ;;
        *)
            log_error "Unsupported architecture: ${arch}"
            exit 1
            ;;
    esac
    
    echo "awscli-exe-${os}-${arch}.zip"
}

download_aws_installer() {
    local installer_name="$1"
    local download_url="https://awscli.amazonaws.com/${installer_name}"
    local output_path="~/tools/aws-cli/${installer_name}"
    
    log_step "Downloading AWS CLI installer..."
    
    download_file "$download_url" "$output_path" "AWS CLI installer"
}

extract_aws_installer() {
    local installer_name="$1"
    local installer_path="~/tools/aws-cli/${installer_name}"
    
    log_step "Extracting AWS CLI installer..."
    
    cd ~/tools/aws-cli/
    unzip -q "$installer_name"
    
    log_success "AWS CLI installer extracted successfully"
}

install_aws_cli() {
    log_step "Installing AWS CLI..."
    
    ~/tools/aws-cli/aws/install --bin-dir ~/bin --install-dir ~/tools/aws-cli/ --update
    
    log_success "AWS CLI installed successfully"
}

setup_aws_configuration() {
    log_step "Setting up AWS CLI configuration..."
    
    copy_config_file \
        "config/zsh/.zshrc.d/aws-cli.source" \
        "~/.zshrc.d/aws-cli.source" \
        "AWS CLI configuration"
}

verify_aws_installation() {
    log_step "Verifying AWS CLI installation..."
    
    if command_exists aws; then
        local version=$(aws --version 2>/dev/null || echo "unknown")
        log_success "AWS CLI installed successfully (version: ${version})"
    else
        log_error "AWS CLI installation verification failed"
        exit 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================
main() {
    log_info "Starting AWS CLI installation..."
    
    # Check if not running as root
    check_root
    
    # Check dependencies
    check_dependencies curl unzip apt-get
    
    # Check OS compatibility
    check_os_compatibility
    
    # Check if AWS CLI is already installed
    if command_exists aws; then
        log_warning "AWS CLI appears to be already installed"
        read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Setup directories
    setup_aws_directories
    
    # Install dependencies
    install_dependencies
    
    # Build installer name
    local installer_name=$(build_aws_installer_name)
    
    # Download and install
    download_aws_installer "$installer_name"
    extract_aws_installer "$installer_name"
    install_aws_cli
    
    # Setup configuration
    setup_aws_configuration
    
    # Verify installation
    verify_aws_installation
    
    log_success "AWS CLI installation completed!"
    log_info "AWS CLI is now available at: ~/bin/aws"
    log_info "To configure AWS CLI, run: aws configure"
    log_info "To test AWS CLI, run: aws --version"
}

# Run main function
main "$@" 