# src/run.jl
#
# Entry point for the MazeLab pipeline.
# Responsibilities:
#   - Activate the Julia project environment
#   - Delegate setup checks to setup.jl (treated as a library)
#   - Parse command-line arguments
#   - Invoke the Maze pipeline

using Pkg

# ---------------------------------------------------------------------------
# Environment activation
# ---------------------------------------------------------------------------

# Activate the project located one level above src/.
# Must happen before any `using` or `import` of project packages.
Pkg.activate(joinpath(dirname(abspath(@__FILE__)), ".."))
Pkg.instantiate()

# ---------------------------------------------------------------------------
# Setup — included as a library, not executed as a script
# ---------------------------------------------------------------------------

const RUN_DIR = dirname(abspath(@__FILE__))

include(joinpath(RUN_DIR, "setup.jl"))

# Run environment and file checks before loading any module.
# Abort early if something is missing, avoiding confusing load errors.
if !install_missing_packages() || !check_files()
    @error "Setup failed. Aborting."
    exit(1)
end

# ---------------------------------------------------------------------------
# Load the Maze module
# ---------------------------------------------------------------------------

include(joinpath(RUN_DIR, "Maze.jl"))
import .Maze

# ---------------------------------------------------------------------------
# CLI helpers
# ---------------------------------------------------------------------------

"""
help()

Prints usage instructions to stdout.
"""
function help()
    msg = """
    Usage:
    julia run.jl w=<int> h=<int> [--solve] [--image]

    Arguments:
    w, width    Maze width  (number of columns)
    h, height   Maze height (number of rows)
    --solve     Run the pathfinder after generation
    --image     Render the maze to an image after generation

    --help      It shows the construction of the arguments

    Examples:
    julia run.jl w=30 h=40 --solve
    julia run.jl width=30 height=40 --image
    julia run.jl w=20 h=20 --solve --image
    """
    println(msg)
end

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

"""
parse_args(args) -> (width, height, solve, render)

Parses the raw ARGS vector into typed values.
Returns `(0, 0, false, false)` for any unrecognised or malformed input.
Width and height default to 0, which is treated as invalid by `main`.
"""
function parse_args(args)
    width = 0
    height = 0
    solve = false
    render = false

    for arg in args
        parts = split(arg, "=")
        key = parts[begin]
        value = parts[end]

        # Accept both short (w / h) and long (width / height) forms.
        if startswith(key, "w")
            try
                width = parse(Int, value)
            catch
                width = 0
            end

        elseif startswith(key, "h")
            try
                height = parse(Int, value)
            catch
                height = 0
            end

        elseif key == "--solve"
            solve = true

        elseif key == "--image"
            render = true

        elseif key == "--help"
            help()
            exit(0)
        end
    end

    return width, height, solve, render
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

"""
main(args)

Orchestrates argument parsing and delegates execution to `Maze.create`.
Prints usage help and exits cleanly when arguments are missing or invalid.
"""
function main(args)
    if isempty(args)
        help()
        return
    end

    width, height, solve, render = parse_args(args)

    if width <= 0 || height <= 0
        @warn "Invalid or missing dimensions."
        help()
        return
    end

    Maze.create(width, height, solve, render)
end

main(ARGS)
