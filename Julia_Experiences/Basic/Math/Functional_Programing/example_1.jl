# main.jl

using Plots

function main()

    # Wave function
    wave_logic(x, y) = sin(x) * cos(y) + sin(y)

    # Matrix
    grid_size = 10
    range_vals = range(start = 0, stop = 2π, length = grid_size)
    raw_matrix = zeros(Float64, grid_size, grid_size)

    # Option 1 - Iterative method
    # for i in 1:grid_size
    #    for j in 1:grid_size
    #        raw_matrix[i, j] = wave_logic(range_vals[i], range_vals[j])
    #    end
    #end

    # Option 2 - Broadcast
    # range_vals (Column Vector) size: (10,)
    # range_vals' (Row Vector) size: (1, 10)
    # Result: A 10x10 matrix where every combination of (x, y) is calculated.
    raw_matrix = wave_logic.(range_vals, range_vals')

    # Normalize
    min_val = minimum(raw_matrix)
    max_val = maximum(raw_matrix)

    normalize(val) = (val - min_val) / (max_val - min_val)
    normalized_matrix = map(normalize, raw_matrix)

    # Display
    display(normalized_matrix[1:3, 1:3])

    # Plot
    # Heatmap: 2D representation where color intensity shows the value
    p1 = heatmap(range_vals, range_vals, normalized_matrix,
                 title = "Wave Pattern (Heatmap)",
                 xlabel = "X axis", ylabel = "Y axis",
                 color = :viridis) # A high-contrast color palette

    # Surface: 3D representation
    p2 = surface(range_vals, range_vals, normalized_matrix,
                 title = "Wave Surface (3D)",
                 camera = (30, 30)) # Setting the viewing angle

    # Combine both plots in a single window
    display(plot(p1, p2, layout = (1, 2), size = (800, 480)))

    # Keep the window open if running from terminal
    println("Press Enter to close the plot...")
    readline()

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
