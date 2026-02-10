# main.jl

# Use local environment
using Pkg
Pkg.activate(".")
Pkg.instantiate()

# Local module
include("src/charCounter.jl")
using .CharCounterModule


function main(input_path::String, output_path::String)

    @info "Starting..."

    try
        process_text_file(input_file, output_file)
        println("Analysis saved to: $output_file")
    catch e
        @error "An error occurred during processing" exception=e
    end

    @info "Finished."
    
end


if abspath(PROGRAM_FILE) == @__FILE__
    input_file = "sample.txt"
    output_file = "result.csv"
    main(input_file, output_file)
end

# Run - Optional
# julia --project=. main.jl
