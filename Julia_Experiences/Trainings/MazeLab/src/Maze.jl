# src/Maze.jl
#
# Core module — owns the type definitions and orchestrates the pipeline.

module Maze

export CellType, MazeGrid, Position, Display
export create, save_maze, load_maze

const SRC_DIR = dirname(abspath(@__FILE__))

# ---------------------------------------------------------------------------
# Types — included once, owned by this module
# ---------------------------------------------------------------------------

include(joinpath(SRC_DIR, "types.jl"))

# ---------------------------------------------------------------------------
# Submodules — receive types via `using ..Maze` declared inside each file
# ---------------------------------------------------------------------------

include(joinpath(SRC_DIR, "generate.jl"))
import .Generate

include(joinpath(SRC_DIR, "solve.jl"))
import .Solver

include(joinpath(SRC_DIR, "render.jl"))
import .Render

# ---------------------------------------------------------------------------
# CSV I/O
# ---------------------------------------------------------------------------

"""
save_maze(maze, filepath)

Serialises `maze` to a plain CSV file where every character is a cell symbol.
Each row of the grid becomes one line; cells are comma-separated.

Example output (5 × 5):

    #,#,#,#,#
    #,S,.,.,#
    #,.,#,.,#
    #,.,.,F,#
    #,#,#,#,#

"""
function save_maze(maze::MazeGrid, filepath::String)

    try
        open(filepath, "w") do io
            for row in eachrow(maze.grid)
                println(io, join((CELL_CHAR[c] for c in row), ","))
            end
        end
        @info "Maze saved to $filepath"
    catch e
        @warn "Cannot save to '$filepath': $e"
    end
end

"""
load_maze(filepath) -> MazeGrid

Reads a CSV file produced by `save_maze` and reconstructs a `MazeGrid`.
Infers dimensions from the file. Locates `Start` and `Finish` by scanning.
"""
function load_maze(filepath::String)::MazeGrid
    lines = readlines(filepath)
    rows = length(lines)
    cols = length(split(lines[1], ","))
    grid = Matrix{CellType}(undef, rows, cols)

    for (r, line) in enumerate(lines)
        for (c, ch) in enumerate(split(line, ","))
            grid[r, c] = CHAR_CELL[only(ch)]
        end
    end

    start = Position(1, 1)
    finish = Position(rows, cols)
    for r = 1:rows, c = 1:cols
        grid[r, c] == Start && (start = Position(r, c))
        grid[r, c] == Finish && (finish = Position(r, c))
    end

    return MazeGrid(grid, rows, cols, start, finish)
end

# ---------------------------------------------------------------------------
# Pipeline entry point
# ---------------------------------------------------------------------------

"""
create(cols, rows, solve, render)

Orchestrates the full MazeLab pipeline:
  1. Build a blank `MazeGrid`
  2. Generate maze via DFS
  3. Persist to CSV
  4. Solve via A*   (if `solve`)
  5. Render output  (if `render`)
"""
function create(cols::Int, rows::Int, solve::Bool, render::Bool)

    # Minimum dimension
    rows < 5 && (@warn "Minimum size is 5×5. Adjusting."; rows = 5)
    cols < 5 && (@warn "Minimum size is 5×5. Adjusting."; cols = 5)

    # Expected dimensions to accommodate walls and paths.
    iseven(rows) && (@info "Adjusting rows: $rows → $(rows + 1)"; rows += 1)
    iseven(cols) && (@info "Adjusting cols: $cols → $(cols + 1)"; cols += 1)

    @info "Creating maze ($cols × $rows)  solve=$solve  render=$render"

    # Initialize
    maze = MazeGrid(rows, cols)

    # Stage 1 — Generate
    if Generate.run!(maze) === nothing
        @warn "Error generating the maze."
        return nothing
    end

    # Stage 2 — Persist

    # Save
    filepath = "../output/maze.csv"
    save_maze(maze, filepath)

    # Load (Optional Test)
    maze == load_maze(filepath) ||
        @warn "Different MazeGrids. Change detected in the CSV file."

    # Stage 3 — Solve (Optional)
    if solve
        if Solver.run!(maze) === nothing
            @warn "The pathfinding process failed!"
        else
            # Save
            save_maze(maze, replace(filepath, ".csv" => "_solution.csv"))
        end
    end

    # Stage 4 — Render (optional)
    render && Render.run(maze)

    # Show MazeGrid - Debug
    @show maze

    return maze
end

end # module Maze


# Guard: this module is not meant to be the PROGRAM_FILE.
if abspath(PROGRAM_FILE) == @__FILE__
    @info "Maze.jl is a module — load it via run.jl, not directly."
end
