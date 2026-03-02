# main.jl
# TDD-style consumer of ImageDSL
# Uses Test.jl for structured assertions
# Uses Meta.parse + eval to catch macro expansion errors at runtime

using Pkg
Pkg.activate(".")
Pkg.instantiate()

include("ImageDSL.jl")
using .ImageDSL
using Test


# ─────────────────────────────────────────────
# SECTION 1 — @apply (single operation)
# ─────────────────────────────────────────────

@testset "@apply — single operation" begin

    # Valid call — should not throw
    @test begin
        @apply blur("input/foto.png", radius = 3, output = "output/blur.png")
        true
    end

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
    @test begin
        @pipeline :grayscale_blur begin
            load("input/foto.png")
            grayscale()
            blur(radius = 2)
            resize(width = 800, height = 600)
            save("output/result.png")
        end
        true
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

    # load_typed returns typed structs — dispatch depends on image color space
    img_rgb = ImageDSL.load_typed("input/foto.png")
    img_gray = ImageDSL.load_typed("input/foto_gray.png")

    @test img_rgb isa ImageDSL.RGBImage
    @test img_gray isa ImageDSL.GrayImage

    # apply_contrast specializes per type — no runtime branching
    result_rgb = ImageDSL.apply_contrast(img_rgb, factor = 1.5)
    result_gray = ImageDSL.apply_contrast(img_gray, factor = 1.5)

    @test result_rgb isa ImageDSL.RGBImage
    @test result_gray isa ImageDSL.GrayImage

    # describe prints which specialization is active
    ImageDSL.describe(img_rgb)
    ImageDSL.describe(img_gray)

end


# ─────────────────────────────────────────────
# SECTION 4 — validate() as standalone contract
# ─────────────────────────────────────────────

@testset "validate() — public contract" begin

    # Valid calls — should return :ok
    @test ImageDSL.validate(:blur, radius = 3) == :ok
    @test ImageDSL.validate(:resize, width = 800, height = 600) == :ok
    @test ImageDSL.validate(:grayscale) == :ok

    # Invalid: negative radius
    @test_throws Exception ImageDSL.validate(:blur, radius = -1)

    # Invalid: unknown operation
    @test_throws Exception ImageDSL.validate(:explode)

    # Invalid: missing required param
    @test_throws Exception ImageDSL.validate(:resize, width = 800)

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
