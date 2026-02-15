# main.jl

include("svgProcessor.jl")

using .SVGProcessor

function process(filepath::String)
    println("--- Starting SVG/XML Processing ---")

    if !isfile(filepath)
        println("Invalid file!")
        return
    end

    try
        elements = SVGProcessor.parse_svg_file(FilePath(filepath))

        println("\nFound $(length(elements)) elements in SVG:")
        for el in elements
            println("Tag: <$(el.tag_name)> | Attributes: $(el.attributes)")
        end
    catch e
        @warn "Error details: $e"
    end

    try
        df = SVGProcessor.parse_svg_dataframe(FilePath(filepath))
        println(df)
    catch e
        @warn "Error details: $e"
    end

    println("\n--- Task Completed ---")
end

if abspath(PROGRAM_FILE) == @__FILE__
    process("drawing.svg")
end
