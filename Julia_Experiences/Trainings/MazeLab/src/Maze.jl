# src/Maze.jl
#
# Core module of the MazeLab pipeline.
# Defines all shared types and orchestrates the three pipeline stages:
#   Generate → Solve → Render

module Maze

export CellType, MazeGrid, Position
export create, save_maze, load_maze

const SRC_DIR = dirname(abspath(@__FILE__))
include(joinpath(SRC_DIR, "generate.jl"));
import .Generate

include(joinpath(SRC_DIR, "solve.jl"));
import .Solver

include(joinpath(SRC_DIR, "render.jl"));
import .Render

# ---------------------------------------------------------------------------
# Cell type — fixed set of named states
# ---------------------------------------------------------------------------

"""
CellType

Enumeration of every state a maze cell can hold.

| Value      | CSV char | Meaning                        |
|------------|----------|--------------------------------|
| Wall       | `#`      | Solid wall — impassable        |
| Path       | `.`      | Open corridor — passable       |
| Start      | `S`      | Entry point                    |
| Finish     | `F`      | Exit point                     |
| Solution   | `*`      | Part of the solved path        |
"""
@enum CellType begin
    Wall     = 1
    Path     = 2
    Start    = 3
    Finish   = 4
    Solution = 5
end

# Maps each CellType to its CSV character representation.
const CELL_CHAR = Dict{CellType, Char}(
    Wall     => '#',
    Path     => '.',
    Start    => 'S',
    Finish   => 'F',
    Solution => '*'
)

# Reverse map: CSV character → CellType (built automatically from CELL_CHAR).
const CHAR_CELL = Dict{Char, CellType}(v => k for (k, v) in CELL_CHAR)

# ---------------------------------------------------------------------------
# Position — a lightweight (row, col) coordinate
# ---------------------------------------------------------------------------

"""
Position(row, col)

Immutable grid coordinate. Uses (row, col) convention to match
Julia's column-major matrix indexing naturally.
"""
struct Position
    row::Int
    col::Int
end

# ---------------------------------------------------------------------------
# MazeGrid — the central data structure
# ---------------------------------------------------------------------------

"""
MazeGrid

Holds the full state of a maze: its cell grid, dimensions, and
the positions of the start and finish cells.

Fields
------
- `grid`   : 2-D matrix of `CellType` values, indexed [row, col]
- `rows`   : number of rows  (height)
- `cols`   : number of columns (width)
- `start`  : entry `Position`
- `finish` : exit  `Position`
"""
mutable struct MazeGrid
    grid   :: Matrix{CellType}
    rows   :: Int
    cols   :: Int
    start  :: Position
    finish :: Position
end

"""
MazeGrid(rows, cols) -> MazeGrid

Convenience constructor. Returns a `MazeGrid` entirely filled with
`Wall` cells, with start at the top-left and finish at the bottom-right.
This is the canonical blank-slate before the generator runs.
"""
function MazeGrid(rows::Int, cols::Int)
    grid   = fill(Wall, rows, cols)
    start  = Position(1, 1)
    finish = Position(rows, cols)
    return MazeGrid(grid, rows, cols, start, finish)
end

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
    open(filepath, "w") do io
        for row in eachrow(maze.grid)
            println(io, join((CELL_CHAR[c] for c in row), ","))
            end
        end
            @info "Maze saved to $filepath"
    end

"""
load_maze(filepath) -> MazeGrid

Reads a CSV file produced by `save_maze` and reconstructs a `MazeGrid`.
Infers rows and cols from the file content.
Start and finish positions are located by scanning for `S` and `F`.
"""
function load_maze(filepath::String)::MazeGrid
    lines = readlines(filepath)
    rows  = length(lines)
    cols  = length(split(lines[1], ","))
    grid  = Matrix{CellType}(undef, rows, cols)

    for (r, line) in enumerate(lines)
        for (c, ch) in enumerate(split(line, ","))
            grid[r, c] = CHAR_CELL[only(ch)]
        end
    end

    # Locate start and finish by scanning the grid once.
    start  = Position(1, 1)
    finish = Position(rows, cols)
    for r in 1:rows, c in 1:cols
        grid[r, c] == Start  && (start  = Position(r, c))
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
2. Generate — fill the grid via DFS (delegated to `Generate`)
3. Save the generated maze to CSV
4. Solve  — find the shortest path via A* (delegated to `Solver`,  if `solve`)
5. Render — produce a visual output          (delegated to `Render`, if `render`)
"""
function create(cols::Int, rows::Int, solve::Bool, render::Bool)

    @info "Creating maze ($cols × $rows)  solve=$solve  render=$render"

    maze = MazeGrid(rows, cols)

    # Stage 1 — Generate
    # Generate.run!(maze)

    # Stage 2 — Persist
    # save_maze(maze, "data/maze.csv")

    # Stage 3 — Solve (optional)
    # solve && Solver.run!(maze)

    # Stage 4 — Render (optional)
    # render && Render.run(maze)

    return maze
end

end # module Maze


# Guard: this module is not meant to be the PROGRAM_FILE.
if abspath(PROGRAM_FILE) == @__FILE__
    @info "Maze.jl is a module — load it via run.jl, not directly."
end
