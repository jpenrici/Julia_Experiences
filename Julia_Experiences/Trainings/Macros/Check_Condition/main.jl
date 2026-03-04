# main.jl

"""
@check(condition, fallback_action)

Checks if a `condition` is true.
    If it fails, it executes the `fallback_action`.
    If it passes, it logs a success message including the code of the condition.
"""
macro check(condition, fallback_action)
    # Convert the expression code itself into a string (Metaprogramming)
    condition_text = string(condition)

    return quote
        # Use esc() to ensure variables are resolved in the caller's scope
        if !($(esc(condition)))
            print("FAILURE: [", $condition_text, "] -> ")
            $(esc(fallback_action))
        else
            println("SUCCESS: [", $condition_text, "] is true.")
        end
    end
end

function main()
    println("--- Starting Verification Tests ---\n")

    # 1. Basic Membership Test
    value = 2
    elements = [-1, 0, 1]
    @check(value in elements, println("Value $value is missing from $elements"))

    # 2. Mathematical Expression (AST)
    # Using :(...) creates an expression object
    math_expr = :(1 - 1)
    @check(
        eval(math_expr) in elements,
        println("The result of $math_expr is not in the list")
    )

    # 3. Type Handling (Float vs Integer)
    # Julia's 'in' operator handles value equality across types
    @check(1.0 in elements, println("Float 1.0 was not recognized in the Integer array"))

    # 4. Higher-Order Functions
    # Checking if all elements are less than 5
    @check(all(x -> x < 5, elements), println("Found numbers >= 5 in the array!"))

    # 5. String Literal Test
    raw_text = "1 - 1"
    @check(raw_text in elements, println("The string '$raw_text' is not the number 0"))

    println("\n--- Tests Finished ---")
end

# Standard Julia script entry point
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
