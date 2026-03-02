#!/bin/bash
# setup.sh
# Orchestrates the ImageDSL test pipeline
# Usage: ./setup.sh [--force-images] [--skip-tests] [--inspect]
#        --force-images  Regenerate test images even if input/ exists
#        --skip-tests    Run dependencies and images only, skip main.jl
#        --inspect       Run inspect.jl only (AST explorer) — skips all other steps

set -euo pipefail  # exit on error, undefined vars, pipe failures

# ─────────────────────────────────────────────
# CONSTANTS
# ─────────────────────────────────────────────

readonly BLACK='\033[0;30m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly NC='\033[0m'

readonly SCRIPT_FILENAME=$(basename "$0")
readonly TODAY=$(date +%Y-%m-%d)
readonly NOW=$(date +%Y-%m-%d-%H:%M:%S)
readonly LOG_FILE="setup_${TODAY}.log"


# ─────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────

log_info()    { echo -e "${CYAN}[*]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[+]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[Error]${NC} $1" | tee -a "$LOG_FILE" >&2; }
log_step()    { echo -e "${PURPLE}[>]${NC} $1" | tee -a "$LOG_FILE"; }


# ─────────────────────────────────────────────
# FLAGS
# ─────────────────────────────────────────────

FORCE_IMAGES=false
SKIP_TESTS=false
INSPECT=false

for arg in "$@"; do
    case $arg in
        --force-images) FORCE_IMAGES=true ;;
        --skip-tests)   SKIP_TESTS=true ;;
        --inspect)      INSPECT=true ;;
        --help)
            echo "Usage: ./$SCRIPT_FILENAME [--force-images] [--skip-tests] [--inspect]"
            echo "  --force-images  Regenerate test images even if input/ exists"
            echo "  --skip-tests    Run dependencies and images only, skip main.jl"
            echo "  --inspect       Run inspect.jl only (AST explorer) — skips all other steps"
            exit 0
            ;;
        *) log_warn "Unknown flag: $arg — ignoring" ;;
    esac
done


# ─────────────────────────────────────────────
# STEPS
# ─────────────────────────────────────────────

log_info "=== ImageDSL Setup — $NOW ==="

# Step 1 — Julia check
log_step "Checking Julia environment..."
if command -v julia >/dev/null 2>&1; then
    julia_version=$(julia --version)
    log_success "Julia found: $julia_version"
else
    log_error "Julia is not installed. Please install it from julialang.org."
    exit 1
fi

# Step 1.5 — Inspect mode (early exit — independent of other steps)
if [[ "$INSPECT" == true ]]; then
    log_step "Running AST inspector..."
    julia inspect.jl
    log_success "Done."
    exit 0
fi

# Step 2 — Dependencies
log_step "Synchronizing Julia dependencies..."
if julia dependencies.jl; then
    log_success "Dependencies ready."
else
    log_error "Dependency sync failed — aborting."
    exit 1
fi

# Step 3 — Test images
if [[ ! -d "input" ]] || [[ "$FORCE_IMAGES" == true ]]; then
    log_step "Generating test images..."
    if julia generate_test_images.jl; then
        log_success "Test images generated."
    else
        log_error "Image generation failed — aborting."
        exit 1
    fi
else
    log_info "input/ already exists — skipping image generation. (use --force-images to regenerate)"
fi

# Step 4 — Tests
if [[ "$SKIP_TESTS" == true ]]; then
    log_warn "Skipping tests (--skip-tests flag set)."
    exit 0
fi

log_step "Running tests..."
if julia main.jl; then
    log_success "All tests passed."
else
    log_error "Tests failed — check output above."
    exit 1
fi

log_success "=== Done. Log saved to $LOG_FILE ==="
