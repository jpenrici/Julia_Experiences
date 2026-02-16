# main.jl

using Libdl

# --- Constants ---
const LIB_NAME = "libcalc.so"
const LIB_FORTRAN = joinpath(@__DIR__, "lib", LIB_NAME)

if !isfile(LIB_FORTRAN)
    error("Library not found at $LIB_FORTRAN. Please run CMake build first.")
end

# --- Wrapper Module ---
module FortranLib

    import ..LIB_FORTRAN

    function call_fortran_dot_product(vec1::Vector{Float64}, vec2::Vector{Float64})

        if length(vec1) != length(vec2)
            error("The vectors must be the same size!")
        end

        n = Int32(length(vec1))

        GC.@preserve vec1 vec2 begin
            # Fortran: dot_product_fortran(n, vector1_ptr, vector2_ptr)
            result = @ccall LIB_FORTRAN.dot_product_fortran(n::Int32, vec1::Ptr{Float64}, vec2::Ptr{Float64})::Float64
        end

        return result
    end
end # FortranLib

# Test
function main()

    v1 = [1.0, 2.0, 3.0, 4.0]
    v2 = [5.0, 6.0, 7.0, 8.0]

    res = FortranLib.call_fortran_dot_product(v1, v2)

    println("Fortran result: ", res)
    println("Julia result: ", sum(v1 .* v2))
    
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
