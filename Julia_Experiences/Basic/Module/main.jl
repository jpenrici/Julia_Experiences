# main.jl

include("ColorConverter.jl")

using .ColorConverter

function display_helper()
    println("""
    Usage: julia main.jl <R> <G> <B> <A>

    Arguments:
      R, G, B, A : Integers between 0 and 255

    Example:
      julia main.jl 255 128 0 255
    """)
end

function main()
    # Check if we have exactly 4 arguments
    if length(ARGS) != 4
        display_helper()
        return
    end

    try
        # Converting ARGS (Strings) to Integers
        r = parse(Int, ARGS[1])
        g = parse(Int, ARGS[2])
        b = parse(Int, ARGS[3])
        a = parse(Int, ARGS[4])

        color = RGBA(r, g, b, a)

        # Display results
        println("Object : ", color)
        println("Input  : $(to_str(color))")
        println("Output : $(to_hex(color))")

        catch e
        if isa(e, ArgumentError)
            println("Error: Arguments must be valid integers (e.g., 255).")
            elseif isa(e, ErrorException)
            println("Error: $(e.msg)")
        else
            println("An unexpected error occurred: $e")
        end

        println()
        display_helper()
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
