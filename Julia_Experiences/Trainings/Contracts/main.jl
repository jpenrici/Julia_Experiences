# main.jl

# Type Hierarchy
abstract type Shape end

# Holy Traits Pattern
abstract type GeometryStyle end
struct IsPolygonal <: GeometryStyle end
struct IsCurved <: GeometryStyle end

# Default fallback for any Shape
geometry_style(::Type{T}) where {T<:Shape} =
    error("Interface Error: Define geometry_style for $T")

# Concrete Struct
struct Circle <: Shape
    radius::Float64
end

struct Square <: Shape
    side::Float64
end

struct Triangle <: Shape
    base::Float64
    height::Float64
end

# Trait Assigment
geometry_style(::Type{Circle}) = IsCurved()
geometry_style(::Type{Square}) = IsPolygonal()
geometry_style(::Type{Triangle}) = IsPolygonal()

# Contracts
area(c::Circle) = pi * (c.radius ^ 2)
area(s::Square) = s.side ^ 2
area(t::Triangle) = (t.base * t.height) / 2

perimeter(c::Circle) = 2 * pi * c.radius
perimeter(s::Square) = 4 * s.side

# Trait-based Dispatch
function describe_border(s::T) where {T<:Shape}
    return _describe_border(geometry_style(T), s)
end

_describe_border(
    ::IsPolygonal,
    s::Shape,
) = "This $(typeof(s)) has straight edges and vertices."

_describe_border(
    ::IsCurved,
    s::Shape,
) = "This $(typeof(s)) has a smooth, continuous boundary."


function main()

    shapes = [Circle(5.0), Square(4.0), Triangle(3.0, 6.0)]

    println("--- Geometry System Report ---")
    for s in shapes
        println()
        println("Shape: ", typeof(s))
        println("Area: ", area(s))
        println("Border Style: ", describe_border(s))
    end

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
