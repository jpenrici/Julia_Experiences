# src/solve.jl

module Solver

export run!

# This module is an internal component of Maze, not a generic library.
using ..Maze:
    MazeGrid, Position, CellType, Wall, Path, Start, Finish, Solution, manhattan, isvalid

# ---------------------------------------------------------------------------
# Internal — A* pathfinding algorithm
# ---------------------------------------------------------------------------

"""
Astar!(MazeGrid) -> Bool

Find the minimal path that connects the starting point with the finish point.
"""
function Astar!(maze::MazeGrid)::Bool

    directions = [
        (-1, 0), # North
        (1, 0),  # South
        (0, -1), # West
        (0, 1),  # East
    ]

    open_set = [(0, maze.start)] # Vector{Tuple{Int, Position}}
    came_from = Dict{Position,Position}()
    g_score = Dict{Position,Float64}(maze.start => 0.0)
    f_score = Dict{Position,Float64}(maze.start => manhattan(maze.start, maze.finish))

    function reconstruct_path!(came_from::Dict{Position,Position}, current::Position)
        maze.grid[current.row, current.col] = Finish
        while haskey(came_from, current)
            current = came_from[current]
            maze.grid[current.row, current.col] = Solution
        end
    end

    while !isempty(open_set)

        sort!(open_set, by = x -> x[1]) # lowest f_score
        _, current = popfirst!(open_set)
        if current == maze.finish
            reconstruct_path!(came_from, current)
            return true
        end

        for (dx, dy) in directions
            neighbor = Position(current.row + dx, current.col + dy)
            if isvalid(neighbor, maze) && maze.grid[neighbor.row, neighbor.col] != Wall
                attempt = g_score[current] + 1
                if attempt < get(g_score, neighbor, Inf)
                    came_from[neighbor] = current
                    g_score[neighbor] = attempt
                    # f(n) = g(n) + h(n), where h(n) is a heuristic function
                    f = attempt + manhattan(neighbor, maze.finish)
                    if !any(x -> x[2] == neighbor, open_set)
                        push!(open_set, (f, neighbor))
                    end
                end
            end
        end
    end

    return false
end

# ---------------------------------------------------------------------------
# Public entry point
# ---------------------------------------------------------------------------

function run!(maze::MazeGrid)::Union{MazeGrid,Nothing}

    @info "Solving with A* pathfinding algorithm..."
    Astar!(maze) || return nothing

    maze.grid[maze.start.row, maze.start.col] = Start

    return maze
end

end # module Solver

if abspath(PROGRAM_FILE) == @__FILE__
    @info "solve.jl is a module and is part of Maze.jl."
end
