#!/bin/bash

# Test all environments script
# This script tests the workstation scripts in all available environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to test a single environment
test_environment() {
    local env_name="$1"
    local service_name="$2"
    
    log_info "Testing $env_name environment..."
    
    # Build and run the container
    if docker-compose -f docker-compose.test.yml build "$service_name" > /dev/null 2>&1; then
        if docker-compose -f docker-compose.test.yml run --rm "$service_name" > /tmp/test_${env_name}.log 2>&1; then
            log_success "$env_name: Test passed"
            echo "✅ $env_name" >> /tmp/test_summary.txt
        else
            log_error "$env_name: Test failed"
            echo "❌ $env_name" >> /tmp/test_summary.txt
        fi
    else
        log_error "$env_name: Build failed"
        echo "❌ $env_name (build failed)" >> /tmp/test_summary.txt
    fi
}

# Main function
main() {
    log_info "Starting tests for all environments..."
    
    # Clear previous test summary
    > /tmp/test_summary.txt
    
    # Test all environments
    test_environment "Ubuntu" "test-ubuntu"
    test_environment "Debian" "test-debian"
    test_environment "Alpine" "test-alpine"
    test_environment "macOS Sim" "test-macos-sim"
    
    # Display summary
    echo ""
    log_info "Test Summary:"
    echo "=============="
    cat /tmp/test_summary.txt
    
    # Display detailed logs if any failed
    echo ""
    log_info "Detailed logs for failed tests:"
    echo "=================================="
    for env in ubuntu debian alpine macos-sim; do
        if [ -f "/tmp/test_${env}.log" ]; then
            if grep -q "ERROR\|FAILED" "/tmp/test_${env}.log" 2>/dev/null; then
                echo "--- $env ---"
                cat "/tmp/test_${env}.log"
                echo ""
            fi
        fi
    done
    
    # Cleanup
    rm -f /tmp/test_*.log /tmp/test_summary.txt
    
    log_success "All environment tests completed!"
}

# Run main function
main "$@" 