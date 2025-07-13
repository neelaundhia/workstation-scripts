#!/bin/bash

# =============================================================================
# Workstation Scripts - Complete Environment Test Suite
# =============================================================================
# This script tests the workstation scripts in all available environments
# including Ubuntu, Debian, Alpine, and macOS simulation.
# =============================================================================

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Test results storage
declare -A TEST_RESULTS
declare -A TEST_LOGS
declare -A BUILD_TIMES

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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

log_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '#'
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %d%%" $percentage
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or not accessible"
        log_info "Please start Docker and try again"
        exit 1
    fi
    log_success "Docker is running"
}

# Function to test a single environment
test_environment() {
    local env_name="$1"
    local dockerfile="$2"
    local service_name="$3"
    local test_number="$4"
    local total_tests="$5"
    
    log_step "Testing $env_name environment ($test_number/$total_tests)..."
    
    # Start timer
    local start_time=$(date +%s)
    
    # Create temporary log file
    local log_file="/tmp/test_${env_name,,}.log"
    
    # Build the container
    log_info "Building $env_name container..."
    if docker build -f "$dockerfile" -t "workstation-test-${env_name,,}" . > "$log_file" 2>&1; then
        log_success "$env_name: Build completed"
        BUILD_TIMES["$env_name"]=$(($(date +%s) - start_time))
        
        # Test the container
        log_info "Running $env_name tests..."
        if docker run --rm "workstation-test-${env_name,,}" > "$log_file" 2>&1; then
            log_success "$env_name: Test PASSED"
            TEST_RESULTS["$env_name"]="PASS"
            TEST_LOGS["$env_name"]="$(cat "$log_file")"
        else
            log_error "$env_name: Test FAILED"
            TEST_RESULTS["$env_name"]="FAIL"
            TEST_LOGS["$env_name"]="$(cat "$log_file")"
        fi
    else
        log_error "$env_name: Build FAILED"
        TEST_RESULTS["$env_name"]="BUILD_FAIL"
        TEST_LOGS["$env_name"]="$(cat "$log_file")"
        BUILD_TIMES["$env_name"]=$(($(date +%s) - start_time))
    fi
    
    # Show progress
    show_progress "$test_number" "$total_tests"
    echo ""
    
    # Cleanup
    rm -f "$log_file"
}

# Function to generate test report
generate_report() {
    local report_file="TEST_REPORT_$(date +%Y%m%d_%H%M%S).md"
    
    log_header "Generating Test Report: $report_file"
    
    cat > "$report_file" << EOF
# Workstation Scripts Test Report

**Generated:** $(date)
**Total Environments Tested:** ${#TEST_RESULTS[@]}

## Summary

| Environment | Status | Build Time | Details |
|-------------|--------|------------|---------|
EOF
    
    local passed=0
    local failed=0
    
    for env in "${!TEST_RESULTS[@]}"; do
        local status="${TEST_RESULTS[$env]}"
        local build_time="${BUILD_TIMES[$env]:-0}s"
        
        case "$status" in
            "PASS")
                echo "| $env | ✅ PASS | ${build_time} | All tests passed |" >> "$report_file"
                ((passed++))
                ;;
            "FAIL")
                echo "| $env | ❌ FAIL | ${build_time} | Tests failed |" >> "$report_file"
                ((failed++))
                ;;
            "BUILD_FAIL")
                echo "| $env | 🔨 BUILD_FAIL | ${build_time} | Build failed |" >> "$report_file"
                ((failed++))
                ;;
        esac
    done
    
    cat >> "$report_file" << EOF

## Statistics
- **Passed:** $passed
- **Failed:** $failed
- **Success Rate:** $((passed * 100 / (passed + failed)))%

## Detailed Logs

EOF
    
    for env in "${!TEST_RESULTS[@]}"; do
        local status="${TEST_RESULTS[$env]}"
        local log="${TEST_LOGS[$env]}"
        
        cat >> "$report_file" << EOF
### $env Environment

**Status:** $status
**Build Time:** ${BUILD_TIMES[$env]:-0}s

\`\`\`
$log
\`\`\`

---
EOF
    done
    
    log_success "Test report generated: $report_file"
    echo "$report_file"
}

# Function to display summary
display_summary() {
    log_header "Test Summary"
    
    local passed=0
    local failed=0
    
    for env in "${!TEST_RESULTS[@]}"; do
        local status="${TEST_RESULTS[$env]}"
        case "$status" in
            "PASS")
                log_success "$env: ✅ PASSED"
                ((passed++))
                ;;
            "FAIL")
                log_error "$env: ❌ FAILED"
                ((failed++))
                ;;
            "BUILD_FAIL")
                log_error "$env: 🔨 BUILD FAILED"
                ((failed++))
                ;;
        esac
    done
    
    echo ""
    log_info "Statistics:"
    echo "  - Passed: $passed"
    echo "  - Failed: $failed"
    echo "  - Success Rate: $((passed * 100 / (passed + failed)))%"
    
    if [ $failed -eq 0 ]; then
        log_success "All environments passed! 🎉"
    else
        log_warning "Some environments failed. Check the detailed report."
    fi
}

# Function to cleanup Docker images
cleanup_images() {
    log_info "Cleaning up test images..."
    for env in "${!TEST_RESULTS[@]}"; do
        docker rmi "workstation-test-${env,,}" >/dev/null 2>&1 || true
    done
    log_success "Cleanup completed"
}

# Main function
main() {
    log_header "Workstation Scripts Environment Test Suite"
    
    # Check prerequisites
    check_docker
    
    # Define test environments
    declare -A ENVIRONMENTS=(
        ["Ubuntu"]="Dockerfile"
        ["Debian"]="Dockerfile.debian"
        ["Alpine"]="Dockerfile.alpine"
        ["macOS-Sim"]="Dockerfile.macos-sim"
    )
    
    local total_tests=${#ENVIRONMENTS[@]}
    local current_test=0
    
    log_info "Testing $total_tests environments..."
    echo ""
    
    # Test each environment
    for env_name in "${!ENVIRONMENTS[@]}"; do
        ((current_test++))
        local dockerfile="${ENVIRONMENTS[$env_name]}"
        local service_name="test-${env_name,,}"
        
        test_environment "$env_name" "$dockerfile" "$service_name" "$current_test" "$total_tests"
    done
    
    echo ""
    log_header "Test Results"
    
    # Display summary
    display_summary
    
    # Generate report
    local report_file=$(generate_report)
    
    # Ask if user wants to see detailed logs
    echo ""
    read -p "Do you want to see detailed logs for failed tests? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_header "Detailed Logs for Failed Tests"
        for env in "${!TEST_RESULTS[@]}"; do
            if [[ "${TEST_RESULTS[$env]}" != "PASS" ]]; then
                echo "=== $env ==="
                echo "${TEST_LOGS[$env]}"
                echo ""
            fi
        done
    fi
    
    # Ask if user wants to cleanup
    echo ""
    read -p "Do you want to cleanup Docker test images? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_images
    fi
    
    log_success "Test suite completed! Report saved to: $report_file"
}

# Run main function
main "$@" 