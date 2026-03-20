# src/types.jl
#
# This library defines all shared data structures used across the Maze project.
#
# Usage:
#   include("types.jl")

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
