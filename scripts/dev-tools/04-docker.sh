#!/bin/bash

# =============================================================================
# Docker Installation Script
# =============================================================================
# This script installs Docker CE on Ubuntu/Debian systems
# 
# Dependencies: curl, apt-get, dpkg
# Supported OS: Ubuntu/Debian
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# =============================================================================
# Docker Installation Functions
# =============================================================================
add_docker_gpg_key() {
    log_step "Adding Docker's official GPG key..."
    
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    
    # Create keyrings directory
    sudo install -m 0755 -d /etc/apt/keyrings
    
    # Download and install GPG key
    download_file \
        "https://download.docker.com/linux/ubuntu/gpg" \
        "/etc/apt/keyrings/docker.asc" \
        "Docker GPG key"
    
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    log_success "Docker GPG key added successfully"
}

add_docker_repository() {
    log_step "Adding Docker repository to apt sources..."
    
    # Get Ubuntu codename
    local ubuntu_codename
    if [[ -f /etc/os-release ]]; then
        ubuntu_codename=$(source /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
    else
        log_error "Cannot determine Ubuntu codename"
        exit 1
    fi
    
    # Add repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${ubuntu_codename} stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    log_success "Docker repository added successfully"
}

install_docker_packages() {
    log_step "Installing Docker packages..."
    
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    
    log_success "Docker packages installed successfully"
}

setup_docker_user() {
    log_step "Setting up Docker user permissions..."
    
    # Add current user to docker group
    sudo usermod -aG docker "$(whoami)"
    
    log_success "User added to docker group"
    log_warning "You need to log out and back in for group changes to take effect"
}

verify_docker_installation() {
    log_step "Verifying Docker installation..."
    
    if command_exists docker; then
        log_success "Docker is installed and available"
        
        # Test docker daemon (this will fail if user is not in docker group yet)
        if docker --version &>/dev/null; then
            log_success "Docker daemon is accessible"
        else
            log_warning "Docker daemon not accessible. Please log out and back in"
        fi
    else
        log_error "Docker installation verification failed"
        exit 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================
main() {
    log_info "Starting Docker installation..."
    
    # Check if not running as root
    check_root
    
    # Check dependencies
    check_dependencies curl apt-get dpkg
    
    # Check if Docker is already installed
    if command_exists docker; then
        log_warning "Docker appears to be already installed"
        read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Install Docker
    add_docker_gpg_key
    add_docker_repository
    install_docker_packages
    setup_docker_user
    verify_docker_installation
    
    log_success "Docker installation completed!"
    log_info "To start using Docker, log out and back in, or run: newgrp docker"
    log_info "To test Docker, run: docker run hello-world"
}

# Run main function
main "$@" 