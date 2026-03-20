# src/generate.jl

module Generate

export run!

const SRC_DIR = dirname(abspath(@__FILE__))
include(joinpath(SRC_DIR, "types.jl"));

struct MessageError <: Exception
    message::String
    line::Int
end

Base.showerror(io::IO, e::MessageError) =
    print(io, "$(string(@__MODULE__)) Error at line $(e.line): $(e.message)")

function DFS(maze::MazeGrid)::Union{MazeGrid,Nothing}
    # TO DO
end

function run!(maze::MazeGrid)::Union{MazeGrid,Nothing}
    # TO DO
    return # Union{MazeGrid,Nothing}
end

end # module Generate


# Guard: this module is not meant to be the PROGRAM_FILE.
if abspath(PROGRAM_FILE) == @__FILE__
    @info "generate.jl is a module and is part of Maze.jl."
end

