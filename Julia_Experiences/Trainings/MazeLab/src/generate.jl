# src/generate.jl

module Generate

struct MessageError <: Exception
    message::String
    line::Int
end

Base.showerror(io::IO, e::MessageError) =
    print(io, "$(string(@__MODULE__)) Error at line $(e.line): $(message)")

end # module Generate

if abspath(PROGRAM_FILE) == @__FILE__
    @info "Module $(string(@__MODULE__)) is not accessible for direct execution!"
end
