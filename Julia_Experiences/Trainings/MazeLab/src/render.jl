# src/render.jl

module Render

using Images
using Colors

export run

# This module is an internal component of Maze, not a generic library.
using ..Maze:
    MazeGrid, Position, CellType, Wall, Path, Start, Finish, Solution, Display, CELL_COLOR

function add_border(maze::MazeGrid)::Tuple{Int,Int,Matrix{CellType}}
    rows = maze.rows + 2
    cols = maze.cols + 2
    bordered = fill(Wall, rows, cols)
    bordered[2:(end-1), 2:(end-1)] = maze.grid
    return rows, cols, bordered
end

function run(maze::MazeGrid)
    display = Display(maze) # Display(maze::MazeGrid; width=800, height=800, title="MazeLab")
    rows, cols, grid = add_border(maze)
    img = fill(RGB{N0f8}(0, 0, 0), rows * display.cell_size, cols * display.cell_size)
    for r = 1:rows, c = 1:cols
        color = parse(RGB{N0f8}, CELL_COLOR[grid[r, c]])
        row_range = ((r-1)*display.cell_size+1):(r*display.cell_size)
        col_range = ((c-1)*display.cell_size+1):(c*display.cell_size)
        img[row_range, col_range] .= color
    end

    save("../output/maze.png", img)
    @info "Maze rendered to output/maze.png"
end

end # module Render

if abspath(PROGRAM_FILE) == @__FILE__
    @info "render.jl is a module and is part of Maze.jl."
end
