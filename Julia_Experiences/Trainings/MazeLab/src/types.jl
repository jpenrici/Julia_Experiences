# src/types.jl
#
# Shared type definitions for the MazeLab project.
# Included once by Maze.jl — all other submodules inherit these
# definitions via `using ..` without re-including this file.

# ---------------------------------------------------------------------------
# CellType — fixed set of named cell states
# ---------------------------------------------------------------------------

"""
CellType

Enumeration of every state a maze cell can hold.

| Value    | CSV char | Meaning                  |
|----------|----------|--------------------------|
| Wall     | `#`      | Solid wall — impassable  |
| Path     | `.`      | Open corridor            |
| Start    | `S`      | Entry point              |
| Finish   | `F`      | Exit point               |
| Solution | `*`      | Part of the solved path  |
"""
@enum CellType begin
    Wall = 1
    Path = 2
    Start = 3
    Finish = 4
    Solution = 5
end

# Maps each CellType to its CSV character representation.
const CELL_CHAR = Dict{CellType,Char}(
    Wall => '#',
    Path => '.',
    Start => 'S',
    Finish => 'F',
    Solution => '*',
)

# Reverse map: CSV character → CellType (derived automatically).
const CHAR_CELL = Dict{Char,CellType}(v => k for (k, v) in CELL_CHAR)

# ---------------------------------------------------------------------------
# Position — immutable (row, col) coordinate
# ---------------------------------------------------------------------------

"""
Position(row, col)

Immutable grid coordinate. Follows Julia's (row, col) / (i, j) convention.
"""
struct Position
    row::Int
    col::Int
end

# ---------------------------------------------------------------------------
# MazeGrid — central data structure
# ---------------------------------------------------------------------------

"""
MazeGrid

Full maze state: grid of cells, dimensions, entry and exit positions.

Fields
------
- `grid`   : `Matrix{CellType}` indexed as `[row, col]`
- `rows`   : number of rows (height)
- `cols`   : number of columns (width)
- `start`  : entry `Position`
- `finish` : exit `Position`
"""
mutable struct MazeGrid
    grid::Matrix{CellType}
    rows::Int
    cols::Int
    start::Position
    finish::Position
end

"""
MazeGrid(rows, cols) -> MazeGrid

Convenience constructor. Returns an all-`Wall` grid with start at (1,1)
and finish at (rows, cols) — the blank slate before generation.
"""
function MazeGrid(rows::Int, cols::Int)
    grid = fill(Wall, rows, cols)
    start = Position(1, 1)
    finish = Position(rows, cols)
    return MazeGrid(grid, rows, cols, start, finish)
end

Base.showerror(io::IO, maze::MazeGrid) = println ("# TO DO")
