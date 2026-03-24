# src/generate.jl
#
# Submodule responsible for maze generation via DFS backtracker.
# Types (MazeGrid, Position, CellType, etc.) are inherited from the
# parent module (Maze) via `using ..` — types.jl is NOT re-included here.

module Generate

using Random

export run!

# This module is an internal component of Maze, not a generic library.
using ..Maze: MazeGrid, Position, CellType, Wall, Path, Start, Finish, manhattan, isvalid

# ---------------------------------------------------------------------------
# Internal — DFS backtracker
# ---------------------------------------------------------------------------

"""
DFS!(maze) -> Bool

Fills `maze.grid` using a depth-first search backtracker.
Returns `true` on success, `false` if the grid is too small to generate.
"""
function DFS!(maze::MazeGrid)::Bool

    directions = [
        (-2, 0), # North
        (2, 0),  # South
        (0, -2), # West
        (0, 2),  # East
    ]

    visited = falses(maze.rows, maze.cols)

    function walk!(r, c)
        !visited[r, c] || return
        visited[r, c] = true
        for (dr, dc) in shuffle(directions)
            nr = r + dr # new row
            nc = c + dc # new col
            if isvalid(nr, nc, maze) && !visited[nr, nc] && maze.grid[nr, nc] == Wall
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

    max_attempts = 10

    for attempt = 1:max_attempts
        # Reset
        maze.start = Position(1, 1)
        maze.grid = fill(Wall, maze.rows, maze.cols)

        # Genrerate using DFS
        DFS!(maze) || return nothing

        # Detect candidates at start and end
        top = [Position(1, c) for c = 1:maze.cols if maze.grid[1, c] == Path]
        left = [Position(r, 1) for r = 1:maze.rows if maze.grid[r, 1] == Path]
        bottom =
            [Position(maze.rows, c) for c = 1:maze.cols if maze.grid[maze.rows, c] == Path]
        right =
            [Position(r, maze.cols) for r = 1:maze.rows if maze.grid[r, maze.cols] == Path]

        # Randomize position
        coin = rand(Bool)

        (isempty(top) || isempty(bottom)) && (coin = false)
        (isempty(left) || isempty(right)) && (coin = true)

        if isempty(top) && isempty(bottom) && isempty(left) && isempty(right)
            continue
        end

        if coin
            maze.start = rand(top)
            maze.finish = rand(bottom)
        else
            maze.start = rand(left)
            maze.finish = rand(right)
        end

        min_dist = (maze.rows + maze.cols) ÷ 2
        if manhattan(maze.start, maze.finish) >= min_dist
            break
        end

    end

    if all(==(Wall), maze.grid)
        @warn "Failed to generate a valid maze after $max_attempts attempts."
        return nothing
    end

    # Update grid
    maze.grid[maze.start.row, maze.start.col] = Start
    maze.grid[maze.finish.row, maze.finish.col] = Finish

    # MazeGrid
    return maze
end

end # module Generate


# Guard: this submodule is loaded by Maze.jl, not executed directly.
if abspath(PROGRAM_FILE) == @__FILE__
    @info "generate.jl is a submodule — load it via Maze.jl."
end
