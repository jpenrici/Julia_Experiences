#!/bin/bash
# script/setup.sh

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # Reset

# Script
readonly SCRIPT=$(basename $0)

# Time
readonly TODAY=$(date +%Y-%m-%d)
readonly NOW=$(date +%Y-%m-%d-%H:%M:%S)

# Messages
log_info()  { echo -e "${CYAN}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[Error]${NC} $1" >&2; }

# Main
log_info "$SCRIPT : $TODAY - $NOW"
log_info "Checking Julia Environment..."

# Check if Julia is instaled
if command -v julia >/dev/null 2>&1; then
    julia_version=$(julia --version)
    log_success "Julia found: $julia_version"
else
    log_error "Julia is not installed. Please install it from julialang.org."
    exit 1
fi

# Custom dependency manager
log_info "Synchronizing Julia dependencies..."
julia dependencies.jl

JULIA_STATUS=$?
if [ $JULIA_STATUS -eq 0 ]; then
    log_success "Environment ready! Use 'julia --project=. main.jl' to run."
else
    log_error "Dependency sync failed (Exit code: $JULIA_STATUS)."
    exit $JULIA_STATUS
fi
