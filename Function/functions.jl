# functios.jl

# Point structure
struct Point
    x::Float64
    y::Float64
end

# Standard function definition
function calculate_distance(p1::Point, p2::Point)

    dx = p2.x - p1.x
    dy = p2.y - p2.y

    return sqrt(dx ^ 2 + dy ^ 2)
end

# Short-form function
calculate_midpoint(p1, p2) = Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)

# Multiple Dispatch
function scale(p::Point, offset::Int64)
    return Point(p.x * offset, p.y * offset)
end

function scale(p::Point, offset::Float64)
    return Point(p.x * offset, p.y * offset)
end

function move(p::Point, offset::Int64)
    return Point(p.x + offset, p.y + offset)
end

function move(p::Point, offset::Float64)
    return Point(p.x + offset, p.y + offset)
end

function move(p::Point, offset::Point)
    return Point(p.x + offset, p.y + offset)
end

function main()
    p1 = Point(0, 0) # origin
    p2 = Point(10, 10)

    dist = calculate_distance(p1, p2)
    mid = calculate_midpoint(p1, p2)

    println("Distance: $dist")
    println("Midle point: $mid")

    points = [move(p1, 1), move(p2, 20), Point(100, 100)]
    println(points)

    # Anonymous function and pipe operator (|>)
    scaled_points = points .|> p -> scale(p, 250)
    println(scaled_points)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end


