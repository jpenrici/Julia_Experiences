# src/generate.jl
#
# Submodule responsible for maze generation via DFS backtracker.
# Types (MazeGrid, Position, CellType, etc.) are inherited from the
# parent module (Maze) via `using ..` — types.jl is NOT re-included here.

module Generate

using Random

export run!

# This module is an internal component of Maze, not a generic library.
using ..Maze: MazeGrid, Position, CellType, Wall, Path, Start, Finish

# ---------------------------------------------------------------------------
# Internal — DFS backtracker
# ---------------------------------------------------------------------------

"""
DFS!(maze) -> Bool

Fills `maze.grid` using a depth-first search backtracker.
Returns `true` on success, `false` if the grid is too small to generate.
"""
function DFS!(maze::MazeGrid)::Bool
    visited = falses(maze.rows, maze.cols)

    directions = [
        (-2, 0), # North
        (2, 0),  # South
        (0, -2), # West
        (0, 2),  # East
    ]

    function walk!(r, c)
        !visited[r, c] || return
        visited[r, c] = true
        for (dr, dc) in Random.shuffle(directions)
            nr = r + dr # new row
            nc = c + dc # new col
            if nr >= 1 &&
               nr <= maze.rows &&
               nc >= 1 &&
               nc <= maze.cols &&
               !visited[nr, nc] &&
               maze.grid[nr, nc] == Wall
                maze.grid[r+dr÷2, c+dc÷2] = Path
                maze.grid[nr, nc] = Path
                walk!(nr, nc)
            end
        end
    end

    walk!(maze.start.row, maze.start.col)

    return true
end

# ---------------------------------------------------------------------------
# Public entry point
# ---------------------------------------------------------------------------

"""
run!(maze) -> Union{MazeGrid, Nothing}

Runs the maze generator. Modifies `maze` in place and returns it.
Returns `nothing` if generation fails.
"""
function run!(maze::MazeGrid)::Union{MazeGrid,Nothing}
    # Start point
    coin = rand(Bool)
    door = coin ? rand(1:2:maze.cols) : rand(1:2:maze.rows)
    maze.start = coin ? Position(1, door) : Position(door, 1)
    maze.grid[maze.start.row, maze.start.col] = Start

    # Searching
    DFS!(maze) || return nothing

    # Finish point
    borders = vcat(
        [Position(1, c) for c = 1:maze.cols if maze.grid[1, c] == Path],
        [Position(r, 1) for r = 1:maze.rows if maze.grid[r, 1] == Path],
        [Position(maze.rows, c) for c = 1:maze.cols if maze.grid[maze.rows, c] == Path],
        [Position(r, maze.cols) for r = 1:maze.rows if maze.grid[r, maze.cols] == Path],
    )
    filter!(p -> p != maze.start, borders)
    isempty(borders) && return nothing
    maze.finish = rand(borders)
    println(borders)
    for p in borders
        p != maze.finish && (maze.grid[p.row, p.col] = Wall)
    end
    maze.grid[maze.finish.row, maze.finish.col] = Finish

    return maze
end

end # module Generate


# Guard: this submodule is loaded by Maze.jl, not executed directly.
if abspath(PROGRAM_FILE) == @__FILE__
    @info "generate.jl is a submodule — load it via Maze.jl."
end
