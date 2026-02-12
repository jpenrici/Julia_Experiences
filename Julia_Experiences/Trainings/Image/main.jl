# main.jl

using Images, Statistics, Random

ENV["GKSwstype"] = "100" # Set GR backend to headless mode
using Plots


function generate(width::Int, height::Int)

    # Image with disproportionate noise
    img = [RGB(rand()*0.2, rand()*0.6, rand()*0.3) for r in 1:height, c in 1:width]

    # Red zone
    red_h = (height ÷ 10):(height ÷ 3)
    red_w = (width ÷ 10):(width ÷ 3)
    img[red_h, red_w] .= RGB(0.9, 0.1, 0.1)

    # Blue gradient bar
    for i in 1:height
        for j in (width - 50):width
            img[i, j] = RGB(0.0, 0.0, Float32(i / height))
        end
    end

    # White square
    start_h, end_h = floor(Int, height / 2), floor(Int, height / 1.2)
    start_w, end_w = floor(Int, width / 2), floor(Int, width / 1.2)
    img[start_h:end_h, start_w:end_w] .= RGB(1.0, 1.0, 1.0)

    println("Generated biased image of size: ", size(img))

    return img
end

function process(img::AbstractMatrix)

    # Image
    h, w = size(img)
    raw_data = channelview(img) # channelview returns a 3xHxW array

    # Flatten the 2D dimensions into 1D for plotting histograms
    # Each row (1, 2, 3) represents R, G, B
    r_values = vec(Float32.(raw_data[1, :, :]))
    g_values = vec(Float32.(raw_data[2, :, :]))
    b_values = vec(Float32.(raw_data[3, :, :]))

    # Calculate means
    m_r, m_g, m_b = mean(r_values), mean(g_values), mean(b_values)

    # Plot
    # Use a histogram for each channel with its respective color
    p = histogram(r_values, bins=50, label="Red Channel", color=:red, fillalpha=0.3, title="Color Frequency")
    histogram!(p, g_values, bins=50, label="Green Channel", color=:green, fillalpha=0.3)
    histogram!(p, b_values, bins=50, label="Blue Channel", color=:blue, fillalpha=0.3)

    # Add vertical lines for the means (The "Cherry on top")
    vline!(p, [m_r], color=:darkred, linestyle=:dash, linewidth=2, label="Mean R")
    vline!(p, [m_g], color=:darkgreen, linestyle=:dash, linewidth=2, label="Mean G")
    vline!(p, [m_b], color=:darkblue, linestyle=:dash, linewidth=2, label="Mean B")

    xlabel!(p, "Intensity (0.0 - 1.0)")
    ylabel!(p, "Frequency")

    # Round
    m_r = round(m_r, digits=2)
    m_g = round(m_g, digits=2)
    m_b = round(m_b, digits=2)

    # Count how many pixels are "bright" (sum of RGB > 1.5)
    bright_pixels = count(p -> (Float32(p.r) + Float32(p.g) + Float32(p.b)) > 1.5, img)

    println("--- Image Statistics ---")
    println("Dimensions: $w x $h")
    println("Color Channels: ", size(raw_data, 1))
    println("Mean Colors -> R: $m_r, G: $m_g, B: $m_b")
    println("Bright Pixels Count: $bright_pixels")

    # Return the plot object
    return p

end

function main()

    # Generate Image
    filename = "test.png"
    img_out = generate(500, 500)

    # Save Image
    save(filename, img_out)
    println("Image saved to: $filename")

    # Load Image
    img_in = load(filename)
    println("Image loaded: $filename")

    # Process Image
    histogram_plot = process(img_in)

    # Save Plot
    plot_filename = "color_distribution.png"
    savefig(histogram_plot, plot_filename)
    println("Histogram saved to: $plot_filename")

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end


