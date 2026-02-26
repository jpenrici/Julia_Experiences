# generate_test_images.jl
# Generates synthetic test images for ImageDSL test suite
# Run this once before running main.jl

using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Images
using FileIO
using ColorTypes

# ─────────────────────────────────────────────
# SETUP — create input/output directories
# ─────────────────────────────────────────────

function setup_dirs()
    mkpath("input")
    mkpath("output")
    @info "Directories ready: input/ output/"
end


# ─────────────────────────────────────────────
# GENERATORS
# ─────────────────────────────────────────────

# Generates a colorful RGB gradient image (horizontal + vertical blend)
function generate_rgb(path::String; width = 256, height = 256)
    img = [
        RGB{N0f8}(
            Float32(x) / width,         # red channel   — left to right
            Float32(y) / height,        # green channel — top to bottom
            0.4f0,                      # blue channel  — fixed
        ) for y = 1:height, x = 1:width
    ]

    FileIO.save(path, img)
    @info "Generated RGB image: $path ($(width)x$(height))"
end

# Generates a grayscale gradient image (diagonal blend)
function generate_gray(path::String; width = 256, height = 256)
    img = [Gray{N0f8}(
        Float32(x + y) / (width + height),   # diagonal gradient
    ) for y = 1:height, x = 1:width]

    FileIO.save(path, img)
    @info "Generated Gray image: $path ($(width)x$(height))"
end

# ─────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────

function main()
    @info "=== Generating test images ==="
    setup_dirs()

    generate_rgb("input/foto.png")
    generate_gray("input/foto_gray.png")

    @info "=== Done. Ready to run main.jl ==="
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
