# src/charCounter.jl

module CharCounterModule

using DataFrames, CSV

export process_text, count_chars, FilePath


struct FilePath
    path::String

    function FilePath(path::String)
        if isfile(path) || endswith(path, ".csv")
            return new(path)
        else
            error("File not found at: $path")
        end
    end
end


"""
filter(char::Char, config::Dict)

Applies transformation rules based on the config dictionary.
Returns the modified char or 'nothing' if it should be ignored.
"""
function filter(char::Char, config::Dict)
    # 1. Case sensitivity check
    target_char = get(config, "uppercase", false) ? uppercase(char) : char

    # 2. Ignore spaces check
    if get(config, "ignore_spaces", false) && isspace(target_char)
        return nothing
    end

    # 3. Ignore punctuation check
    if get(config, "ignore_punctuation", false) && ispunct(target_char)
        return nothing
    end

    return target_char
end


"""
count_chars(content::String, config::Dict)

Counts character frequency directly from a string.
"""
function count_chars(content::String, config::Dict = Dict())
    counts = Dict{Char, Int}()
    for char in content
        processed = filter(char, config)
        if !isnothing(processed)
            counts[processed] = get(counts, processed, 0) + 1
        end
    end
    return counts
end


"""
count_chars(io::IO, config::Dict)

Counts character frequency from an IO stream (efficient for large files).
    """
function count_chars(io::IO, config::Dict = Dict())
    counts = Dict{Char, Int}()
    for line in eachline(io)
        for char in line
            processed = filter(char, config)
            if !isnothing(processed)
                counts[processed] = get(counts, processed, 0) + 1
            end
        end
    end
    return counts
end


"""
build_dataframe(counts::Dict{Char, Int})

Converts the frequency dictionary into a structured and sorted DataFrame.
"""
function build_dataframe(counts::Dict{Char, Int})
    df = DataFrame(
        Character = collect(keys(counts)),
        Count = collect(values(counts))
    )

    # Using broadcast to get ASCII codes
    df.ASCII_Code = Int.(df.Character)

    # Organizing and sorting
    select!(df, :ASCII_Code, :Character, :Count)
    sort!(df, :ASCII_Code)

    println("Processed $(nrow(df)) unique characters.")

    return df
end


"""
process_text(input::FilePath, output_csv::FilePath, config::Dict = Dict())

Reads a text file, counts character frequencies (including ASCII codes),
and saves the result to a CSV file.
"""
function process_text(input::FilePath, output_csv::FilePath, config::Dict = Dict())
    println("Mode: Reading from FILE path...")
    counts = open(input.path, "r") do f
        count_chars(f, config) # Calls the IO version of count_chars
    end
    df = build_dataframe(counts)
    output = output_csv.path
    CSV.write(output, df)
    println("Exporting to CSV: $output")
    return df
end


"""
process_text(input::String, output_csv::FilePath, config::Dict = Dict())

Reads text via String, counts the frequency of characters (including ASCII codes)
and saves the result to a CSV file.
"""
function process_text(input::String, output_csv::FilePath, config::Dict = Dict())
    println("Mode: Processing String...")
    counts = count_chars(input, config) # Calls the String version
    df = build_dataframe(counts)
    output = output_csv.path
    CSV.write(output, df)
    println("Exporting to CSV: $output")
    return df
end


"""
process_text(raw_data::Vector{UInt8}, output_csv::FilePath, config::Dict = Dict())

Reads text via Vector{UInt8}, counts the frequency of characters (including ASCII codes)
and saves the result to a CSV file.
"""
function process_text(raw_data::Vector{UInt8}, output_csv::FilePath, config::Dict = Dict())
    println("Mode: Processing RAW BYTES...")
    return process_text(String(raw_data), output_csv, config)
end

end # CharCounterModule
