# inspect.jl
# Interactive exploration of Julia's AST via ImageDSL.inspect_ast
#
# Usage (REPL):
#   include("inspect.jl"); samples()

using Pkg
Pkg.activate(".")
Pkg.instantiate()

include("ImageDSL.jl")
using .ImageDSL


# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────

# Prints a titled section separator
section(title::String) = println("\n", "─"^50, "\n  $title\n", "─"^50)

# Compares AST representations of two equivalent expressions side by side
function compare_ast(label_a::String, expr_a, label_b::String, expr_b)
    println("\n>>> $label_a")
    dump(expr_a)
    println("\n>>> $label_b")
    dump(expr_b)
    println()
end


# ─────────────────────────────────────────────
# SAMPLES
# ─────────────────────────────────────────────

function samples()

    section("1 — if expression")
    ImageDSL.inspect_ast(:(
        if x > 0
            x
        end
    ))

    section("2 — assignment")
    ImageDSL.inspect_ast(:(x = blur("foto.png")))

    section("3 — pipe operator |>")
    ImageDSL.inspect_ast(:(load("a.png") |> grayscale))

    section("4 — function call with kwargs (comma syntax)")
    ImageDSL.inspect_ast(:(blur("foto.png", radius=3)))

    section("5 — macro call inside quote (meta!)")
    ImageDSL.inspect_ast(:(@apply blur("foto.png", radius=3)))

    section("6 — begin...end block (what @pipeline receives)")
    ImageDSL.inspect_ast(:(
        begin
            load("a.png")
            grayscale()
            save("b.png")
        end
    ))

    section("7 — comma kwargs vs semicolon kwargs (are they the same AST?)")
    compare_ast(
        "comma   → blur(\"f.png\", radius=3)",  :(blur("f.png", radius=3)),
        "semicolon → blur(\"f.png\"; radius=3)", :(blur("f.png"; radius=3)),
    )

end


# ─────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────

if abspath(PROGRAM_FILE) == @__FILE__
    @info """
    AST Inspector — ImageDSL

    Open the REPL and run:
        include("inspect.jl"); samples()
    """
end
