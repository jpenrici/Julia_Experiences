# main.jl

macro inspect(args...)

    for arg in args
        if !(arg isa Symbol)
            error("The @inspect macro only accepts variable names. Received: $arg")
        end
    end

    return quote
        println("="^30)
        $(
            (
                quote
                    local name = $(string(arg))
                    # Runtime inspect
                    try
                        local value = $(esc(arg))
                        println("Name : ", name)
                        println("Type : ", typeof(value))
                        println("Value: ", value)
                    catch e
                        if e isa UndefVarError
                            println("Name : ", name, " (Undefined in this local scope)")
                        else
                            rethrow(e)
                        end
                    end
                    println("-"^10)
                end for arg in args
            )...
        )
    end
end

function main()

    x::Int64 = 42
    y::Float64 = 3.14
    message::String = "Learning Julia Metaprogramming"

    arr::Vector{Int64} = [1, 2, 3, 4, 5]

    # Testing the macro with multiple arguments
    @inspect x y message arr undefined_var
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
