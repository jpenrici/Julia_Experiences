# src/solver.jl

module Solver

struct MessageError <: Exception
    message::String
    line::Int
end

Base.showerror(io::IO, e::MessageError) =
    print(io, "$(string(@__MODULE__)) Error at line $(e.line): $(e.message)")

end # module Solver

if abspath(PROGRAM_FILE) == @__FILE__
    @info "render.jl is a module and is part of Maze.jl."
end
