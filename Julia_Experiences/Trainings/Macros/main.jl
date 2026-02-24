# main.jl
# TDD-style consumer of ImageDSL
# Uses Test.jl for structured assertions
# Uses Meta.parse + eval to catch macro expansion errors at runtime

include("ImageDSL.jl")
using .ImageDSL
using Test


# ─────────────────────────────────────────────────────────────────────────────
# WHY Meta.parse + eval FOR MACRO TESTS?
#
# Macros expand at parse time — before any try/catch is active.
# If @apply is called directly in source, a bad call crashes the entire file
# during loading, not during execution.
#
# Meta.parse("@apply ...") keeps the code as a String until eval() is called.
# At that point, expansion happens inside a controlled runtime context,
# where @test_throws and try/catch can intercept the error normally.
# ─────────────────────────────────────────────────────────────────────────────


# ─────────────────────────────────────────────
# SECTION 1 — @apply (single operation)
# ─────────────────────────────────────────────

@testset "@apply — single operation" begin

    # Valid call — should not throw
    @test_nowarn @apply blur("input/foto.png", radius = 3, output = "output/blur.png")

    # Invalid: negative radius — macro should throw at expansion
    @test_throws Exception eval(
        Meta.parse(
            """@apply blur("input/foto.png", radius=-1, output="output/blur.png")""",
        ),
    )

    # Invalid: unknown operation — macro should throw at expansion
    @test_throws Exception eval(
        Meta.parse("""@apply explode("input/foto.png", output="output/x.png")"""),
    )

end


# ─────────────────────────────────────────────
# SECTION 2 — @pipeline (chained operations)
# ─────────────────────────────────────────────

@testset "@pipeline — ordering rules" begin

    # Valid pipeline — should not throw
    @test_nowarn @pipeline :grayscale_blur begin
        load("input/foto.png")
        grayscale()
        blur(radius = 2)
        resize(width = 800, height = 600)
        save("output/result.png")
    end

    # Invalid: save() before last step
    @test_throws Exception eval(Meta.parse("""
                                           @pipeline :bad_order begin
                                               load("input/foto.png")
                                               save("output/result.png")
                                               grayscale()
                                           end
                                           """))

    # Invalid: load() not in first position
    @test_throws Exception eval(Meta.parse("""
                                           @pipeline :bad_order2 begin
                                               grayscale()
                                               load("input/foto.png")
                                               save("output/result.png")
                                           end
                                           """))

end


# ─────────────────────────────────────────────
# SECTION 3 — @generated dispatch by image type
# ─────────────────────────────────────────────

@testset "@generated — type specialization" begin

    # load_typed should return a typed struct
    @test_throws Exception ImageDSL.load_typed("input/foto.png")   # not implemented yet

    # These will be meaningful once load_typed is implemented:
    # img_rgb  = ImageDSL.load_typed("input/rgb.png")
    # img_gray = ImageDSL.load_typed("input/gray.png")
    # @test img_rgb  isa ImageDSL.RGBImage
    # @test img_gray isa ImageDSL.GrayImage

    # apply_contrast should specialize per type — no runtime branching
    # result = ImageDSL.apply_contrast(img_rgb, factor=1.5)
    # @test result isa ImageDSL.RGBImage

end


# ─────────────────────────────────────────────
# SECTION 4 — validate() as standalone contract
# ─────────────────────────────────────────────

@testset "validate() — public contract" begin

    # Valid calls — should return :ok once implemented
    @test_throws Exception ImageDSL.validate(:blur, radius = 3)         # not implemented yet
    @test_throws Exception ImageDSL.validate(:resize, width = 800, height = 600)

    # Invalid: missing required param
    @test_throws Exception ImageDSL.validate(:resize, width = 800)

    # Once implemented, valid calls should look like:
    # @test ImageDSL.validate(:blur, radius=3)                    == :ok
    # @test ImageDSL.validate(:resize, width=800, height=600)     == :ok

end


# ─────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────

function main()
    @info "ImageDSL test run starting..."
    # Test.jl @testset blocks above run automatically when the file is loaded.
    # This function exists for explicit invocation if needed.
    @info "Done. Check test results above."
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
