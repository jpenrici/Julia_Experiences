# charCounter.jl

module CharCounterModule

using DataFrames, CSV

export process_text_file


"""
process_text_file(input_path::String, output_path::String)

Reads a text file, counts character frequencies (including ASCII codes),
and saves the result to a CSV file.
"""
function process_text_file(input_path::String, output_path::String)
    # Store character counts
    counts = Dict{Char, Int}()

    # Reading and counting
    open(input_path, "r") do file
        for line in eachline(file)
            for char in line
                counts[char] = get(counts, char, 0) + 1
            end
        end
    end

    # Building the DataFrame
    df = DataFrame(
        Character = collect(keys(counts)),
        Count = collect(values(counts))
    )

    # Adding ASCII Information
    df.ASCII_Code = Int.(df.Character)

    # Reordering columns for better readability
    select!(df, :ASCII_Code, :Character, :Count)

    # Sorting by ASCII Code
    sort!(df, :ASCII_Code)

    # Exporting to CSV
    CSV.write(output_path, df)

    println("Success! Processed $(nrow(df)) unique characters.")
end

end # CharCounterModule
