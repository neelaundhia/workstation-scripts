#!/bin/bash

# =============================================================================
# ZSH Installation Script
# =============================================================================
# This script installs and configures ZSH with Oh My ZSH and custom theme
# 
# Dependencies: curl, sed, mkdir, cp
# Supported OS: Ubuntu/Debian
# =============================================================================

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Function to install ZSH
install_zsh() {
    log_info "Installing ZSH..."
    
    if ! command_exists zsh; then
        sudo apt update
        sudo apt install zsh -y
        log_success "ZSH installed successfully"
    else
        log_info "ZSH is already installed"
    fi
}

# Function to install Oh My ZSH
install_ohmyzsh() {
    log_info "Installing Oh My ZSH..."
    
    if [[ ! -d ~/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My ZSH installed successfully"
    else
        log_info "Oh My ZSH is already installed"
    fi
}

# Function to setup custom theme
setup_theme() {
    log_info "Setting up custom theme..."
    
    # Create themes directory if it doesn't exist
    mkdir -p ~/.oh-my-zsh/themes
    
    # Copy custom theme
    if [[ -f "config/zsh/themes/tez.zsh-theme" ]]; then
        cp config/zsh/themes/tez.zsh-theme ~/.oh-my-zsh/themes/
        log_success "Custom theme copied successfully"
    else
        log_warning "Custom theme file not found, using default theme"
        return
    fi
    
    # Set theme in .zshrc
    if [[ -f ~/.zshrc ]]; then
        sed -i 's#robbyrussell#tez#g' ~/.zshrc
        log_success "Theme set to 'tez'"
    fi
}

# Function to setup custom configuration
setup_config() {
    log_info "Setting up custom ZSH configuration..."
    
    # Create .zshrc.d directory
    mkdir -p ~/.zshrc.d
    
    # Copy all configuration files in order
    if [[ -d "config/zsh/.zshrc.d" ]]; then
        for config_file in config/zsh/.zshrc.d/*.source; do
            if [[ -f "$config_file" ]]; then
                cp "$config_file" ~/.zshrc.d/
                log_success "Configuration copied: $(basename "$config_file")"
            fi
        done
    fi
    
    # Add source line to .zshrc if not already present
    if [[ -f ~/.zshrc ]] && ! grep -q "source.*\.zshrc\.d" ~/.zshrc; then
        echo $'\n# Source custom scripts from ~/.zshrc.d\nsource <(cat ~/.zshrc.d/*.source)' >> ~/.zshrc
        log_success "Custom source line added to .zshrc"
    fi
}

# Main installation function
main() {
    log_info "Starting ZSH installation and configuration..."
    
    # Check if not running as root
    check_root
    
    # Install ZSH
    install_zsh
    
    # Install Oh My ZSH
    install_ohmyzsh
    
    # Setup custom theme
    setup_theme
    
    # Setup custom configuration
    setup_config
    
    log_success "ZSH installation and configuration completed!"
    log_info "To set ZSH as default shell, run: chsh -s \$(which zsh)"
    log_info "Restart your terminal or run 'exec zsh' to start using ZSH"
}

# Run main function
main "$@" 