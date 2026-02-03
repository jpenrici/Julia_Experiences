# main.jl

# Use local environment
using Pkg
Pkg.activate(".")
Pkg.instantiate()

# Local module
include("src/paint.jl")
using .JuliaPaint


function main()

    @info "Starting Julia Paint..."

    JuliaPaint.run_app() # Loop

    @info "Finished."
    
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

# Run - Optional
# julia --project=. main.jl
