#!/bin/bash

# =============================================================================
# Workstation Scripts - Main Installer
# =============================================================================
# This script provides a unified interface to install all workstation tools
# or specific categories of tools.
# =============================================================================

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

# =============================================================================
# Script Categories
# =============================================================================
declare -A SCRIPT_CATEGORIES
SCRIPT_CATEGORIES["core"]="Core system tools (ZSH, Oh My ZSH)"
SCRIPT_CATEGORIES["dev-tools"]="Development tools (Docker)"
SCRIPT_CATEGORIES["security"]="Security tools (SOPS)"
SCRIPT_CATEGORIES["cloud-tools"]="Cloud tools (AWS CLI)"
SCRIPT_CATEGORIES["kubernetes"]="Kubernetes tools (kubectl, Flux, k9s, Helm)"
SCRIPT_CATEGORIES["iac"]="Infrastructure as Code tools (OpenTofu)"

# =============================================================================
# Script Mappings
# =============================================================================
declare -A SCRIPTS
SCRIPTS["01-zsh"]="scripts/core/01-zsh.sh"
SCRIPTS["04-docker"]="scripts/dev-tools/04-docker.sh"
SCRIPTS["06-sops"]="scripts/security/06-sops.sh"
SCRIPTS["08-aws-cli"]="scripts/cloud-tools/08-aws-cli.sh"
SCRIPTS["15-kubectl"]="scripts/kubernetes/15-kubectl.sh"
SCRIPTS["17-flux"]="scripts/kubernetes/17-flux.sh"
SCRIPTS["21-k9s"]="scripts/kubernetes/21-k9s.sh"
SCRIPTS["22-helm"]="scripts/kubernetes/22-helm.sh"
SCRIPTS["24-opentofu"]="scripts/iac/24-opentofu.sh"

# =============================================================================
# Helper Functions
# =============================================================================
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [SCRIPT_NAMES...]

OPTIONS:
    -h, --help              Show this help message
    -a, --all               Install all tools
    -c, --category CAT      Install all tools in a specific category
    -l, --list              List available scripts and categories
    -v, --verbose           Enable verbose output

CATEGORIES:
$(for category in "${!SCRIPT_CATEGORIES[@]}"; do
    printf "    %-15s %s\n" "$category" "${SCRIPT_CATEGORIES[$category]}"
done)

EXAMPLES:
    $0 --all                    # Install all tools
    $0 --category kubernetes    # Install all Kubernetes tools
    $0 01-zsh 04-docker        # Install specific tools
    $0 --list                   # List all available scripts

EOF
}

list_scripts() {
    echo "Available Scripts:"
    echo "=================="
    
    for category in "${!SCRIPT_CATEGORIES[@]}"; do
        echo ""
        echo "Category: $category"
        echo "Description: ${SCRIPT_CATEGORIES[$category]}"
        echo "Scripts:"
        
        for script_name in "${!SCRIPTS[@]}"; do
            if [[ "${SCRIPTS[$script_name]}" == "scripts/${category}/"* ]]; then
                printf "  %-15s %s\n" "$script_name" "${SCRIPTS[$script_name]}"
            fi
        done
    done
}

get_scripts_by_category() {
    local category="$1"
    local scripts=()
    
    for script_name in "${!SCRIPTS[@]}"; do
        if [[ "${SCRIPTS[$script_name]}" == "scripts/${category}/"* ]]; then
            scripts+=("$script_name")
        fi
    done
    
    echo "${scripts[@]}"
}

run_script() {
    local script_name="$1"
    local script_path="${SCRIPTS[$script_name]}"
    
    if [[ -z "$script_path" ]]; then
        log_error "Unknown script: $script_name"
        return 1
    fi
    
    if [[ ! -f "$script_path" ]]; then
        log_error "Script not found: $script_path"
        return 1
    fi
    
    log_info "Running script: $script_name"
    log_info "Script path: $script_path"
    
    if bash "$script_path"; then
        log_success "Script completed successfully: $script_name"
    else
        log_error "Script failed: $script_name"
        return 1
    fi
}

run_scripts() {
    local scripts=("$@")
    local failed_scripts=()
    
    for script_name in "${scripts[@]}"; do
        if ! run_script "$script_name"; then
            failed_scripts+=("$script_name")
        fi
    done
    
    if [[ ${#failed_scripts[@]} -gt 0 ]]; then
        log_error "The following scripts failed: ${failed_scripts[*]}"
        return 1
    fi
    
    return 0
}

# =============================================================================
# Main Function
# =============================================================================
main() {
    local install_all=false
    local category=""
    local script_names=()
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--all)
                install_all=true
                shift
                ;;
            -c|--category)
                category="$2"
                shift 2
                ;;
            -l|--list)
                list_scripts
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                script_names+=("$1")
                shift
                ;;
        esac
    done
    
    # Set verbose mode
    if [[ "$verbose" == true ]]; then
        set -x
    fi
    
    # Check if not running as root
    check_root
    
    # Determine which scripts to run
    local scripts_to_run=()
    
    if [[ "$install_all" == true ]]; then
        # Install all scripts
        scripts_to_run=("${!SCRIPTS[@]}")
        log_info "Installing all tools..."
    elif [[ -n "$category" ]]; then
        # Install scripts by category
        if [[ -z "${SCRIPT_CATEGORIES[$category]}" ]]; then
            log_error "Unknown category: $category"
            log_info "Available categories: ${!SCRIPT_CATEGORIES[*]}"
            exit 1
        fi
        
        scripts_to_run=($(get_scripts_by_category "$category"))
        log_info "Installing tools in category: $category"
    elif [[ ${#script_names[@]} -gt 0 ]]; then
        # Install specific scripts
        scripts_to_run=("${script_names[@]}")
        log_info "Installing specific tools: ${script_names[*]}"
    else
        log_error "No installation target specified"
        show_usage
        exit 1
    fi
    
    # Run the scripts
    if run_scripts "${scripts_to_run[@]}"; then
        log_success "All installations completed successfully!"
    else
        log_error "Some installations failed. Please check the output above."
        exit 1
    fi
}

# Run main function
main "$@" 