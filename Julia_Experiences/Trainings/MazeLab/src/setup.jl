# src/setup.jl
#
# Setup library — intended to be included by run.jl, not executed directly.
# Responsibilities:
#   - Verify that all required source files are present
#   - Ensure all required packages are installed and precompiled

using Pkg

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# Absolute path to the directory where this file lives.
# Because this file is included (not run directly), @__FILE__ resolves
# correctly relative to the including script's working directory.
const SETUP_DIR = dirname(abspath(@__FILE__))

# ---------------------------------------------------------------------------
# Package management
# ---------------------------------------------------------------------------

"""
install_missing_packages() -> Bool

Checks whether all required packages are present in the active project.
Installs any that are missing, then precompiles the environment.
Returns `true` on success, `false` if any error occurs.
"""
function install_missing_packages()::Bool
    try
        required = String["Colors", "Images"]

        if isempty(required)
            @info "No external packages required at this stage."
            return true
        end

        project_deps = Pkg.project().dependencies

        @info "Checking dependencies..."
        for pkg in required
            if haskey(project_deps, pkg)
                @info "$pkg ... already installed."
            else
                @info "Installing $pkg..."
                Pkg.add(pkg)
            end
        end

        @info "Precompiling environment..."
        Pkg.precompile()

        return true

    catch e
        @error "Failed to set up dependencies." exception = e
        return false
    end
end

# ---------------------------------------------------------------------------
# File verification
# ---------------------------------------------------------------------------

"""
check_files() -> Bool

Verifies that every required source file exists under SETUP_DIR.
Logs a warning for the first missing file and returns `false`.
Returns `true` only when all files are present.
"""
function check_files()::Bool
    # All paths are resolved relative to the directory of this setup file,
    # which is expected to be the same `src/` folder as the other modules.
    required = ["Maze.jl", "generate.jl", "solve.jl", "render.jl", "types.jl"]

    for filename in required
        filepath = joinpath(SETUP_DIR, filename)
        if !isfile(filepath)
            @warn "Required file not found: $filename"
            return false
        end
        @info "$filename ... OK"
    end

    return true
end
