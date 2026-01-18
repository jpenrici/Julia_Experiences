# basic.jl

# Primitives types
x::Int64 = 42
y::Float64 = 3.14
flag::Bool = true
c::Char = '@'
s::String = "Word"

println("x + y = $x + $y = ", x + y)
println("Character: ", c)
println("Status: $flag")
println("$s -> ", uppercase(s))
println("Length of $s = ", length(s))

# Derived types
arr::Vector{Int64} = [1, 2, 3, 4, 5]
mat::Matrix{Char} = ['a' 'b' 'c'; '1' '2' '3'] # 2 x 3

println("Array: ", arr)
for item in arr
    print(item, " ")
end
println("")

println("Matrix: $mat")
print("{ ")
for row in eachrow(mat)
    print(row, " ")
end
println("}")

tuple = (10, arr, mat)
println(tuple)

struct Person
    name::String
    age::Int
end

p = Person("Juan", 54)
println("Struct:\n Name: $(p.name), Age: $(p.age)")

# Extra
println(isa(x, Number))
println(isa(c, Number))
println(isa(arr, AbstractArray))
println(isa(mat, AbstractArray))

println(supertype(Int64))

print("s = '$s' ")
if isa(s, String)
    println("is a String")
elseif isa(s, Number)
    println("is a Number")
else
    println("It's not a string or a number.")
end
