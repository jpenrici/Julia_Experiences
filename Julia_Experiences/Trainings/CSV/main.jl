# main.jl

# Use local environment
using Pkg
Pkg.activate(".")
Pkg.instantiate()

# Local module
include("src/charCounter.jl")
using .CharCounterModule


function test()

    config = Dict(
        "uppercase" => true,
        "ignore_spaces" => true,
        "ignore_punctuation" => false
    )

    try
        # By File
        process_text(FilePath("sample.txt"), FilePath("result_by_file.csv"), config)

        # By Text
        text = "Hello Julia! Testing special characters: @#\$%^&* (2026)"
        process_text(Vector{UInt8}(text), FilePath("result_by_uint8.csv"))
        process_text(text, FilePath("result_by_string.csv"), config)
    catch e
        @error "An error occurred during processing" exception=e
    end
end


if abspath(PROGRAM_FILE) == @__FILE__
    test()
end

# Run - Optional
# julia --project=. main.jl
