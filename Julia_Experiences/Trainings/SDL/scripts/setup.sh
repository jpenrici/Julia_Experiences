#!/bin/bash

readonly BLACK='\033[0;30m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly NC='\033[0m' # No Color (Reset)

readonly SCRIPT_FILENAME=$(basename $0)
readonly TODAY=$(date +%Y-%m-%d)
readonly NOW=$(date +%Y-%m-%d-%H:%M:%S)

log_info()  { echo -e "${CYAN}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[Error]${NC} $1" >&2; }

# Main
log_info "Checking Julia Paint Environment..."

if command -v julia >/dev/null 2>&1; then
    julia_version=$(julia --version)
    log_success "Julia found: $julia_version"
else
    log_error "Julia is not installed. Please install it from julialang.org."
    exit 1
fi

if pkg-config --exists sdl2; then
    log_success "SDL2 found."
else
    log_warn "SDL2 not found on the system. Julia can try to download JLL, but it is recommended to have the libraries installed."
fi

log_info "Synchronizing Julia dependencies..."
julia dependencies.jl

JULIA_STATUS=$?
if [ $JULIA_STATUS -eq 0 ]; then
    log_success "Environment ready! Use 'julia --project=. main.jl' to run."
else
    log_error "Dependency sync failed (Exit code: $JULIA_STATUS)."
    exit $JULIA_STATUS
fi
