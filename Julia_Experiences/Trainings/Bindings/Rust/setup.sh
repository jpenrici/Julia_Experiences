#!/bin/bash
# setup.sh

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

log_info()    { echo -e "${CYAN}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[Error]${NC} $1" >&2; }

show_help() {
    echo "Usage: ./setup.sh [command]"
    echo ""
    echo "Commands:"
    echo "  all     - Build, Test and Run Julia"
    echo "  build   - Build Rust library (release)"
    echo "  test    - Run Rust internal tests"
    echo "  run     - Execute Julia script"
    echo "  help    - Show this help message"
    echo "  (none)  - Open interactive menu"
}

check_env() {
    log_info "Checking Environments..."
    rustc --version >/dev/null 2>&1 || { log_error "Rust not found"; exit 1; }
    julia --version >/dev/null 2>&1 || { log_error "Julia not found"; exit 1; }
    log_success "Environments OK"
}

build_rust() {
    log_info "Building Rust library..."
    cargo build --release
}

test_rust() {
    log_info "Testing Rust library..."
    cargo test -p str_handler
}

run_julia() {
    log_info "Running Julia..."
    julia main.jl
}

run_all() {
    build_rust && test_rust && run_julia
}

interactive_menu() {
    log_info "Select an option:"
    options=("0) All" "1) Build Rust" "2) Test Rust" "3) Run Julia" "*) Exit")

    select opt in "${options[@]}"; do
        case $REPLY in
            0) run_all ;;
            1) build_rust ;;
            2) test_rust ;;
            3) run_julia ;;
            *) log_info "Exiting..."; break ;;
        esac
    done
}

# --- Main Logic ---

check_env

case "$1" in
    all)   run_all ;;
    build) build_rust ;;
    test)  test_rust ;;
    run)   run_julia ;;
    help)  show_help ;;
    "")    interactive_menu ;;
    *)     log_error "Unknown command: $1"; show_help; exit 1 ;;
esac
