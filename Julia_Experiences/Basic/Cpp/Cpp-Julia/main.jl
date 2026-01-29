# main.jl

using Libdl

# --- Constants ---
const LIB_NAME = "libcalc.so"
const LIB_CPP = joinpath(@__DIR__, "lib", LIB_NAME)

# --- Wrapper Module ---
module CppLib

    import ..LIB_CPP

    # --- Private Low-Level Calls (Internal) ---

    # float sum(float a, float b)
    function _sum(a::Float32, b::Float32)
        return ccall((:sum, LIB_CPP), Float32, (Float32, Float32), a, b)
    end

    # long pow(int base, int exp)
    function _pow(base::Int32, exp::Int32)
        return ccall((:power, LIB_CPP), Clong, (Int32, Int32), base, exp)
    end

    # --- Public API using Multiple Dispatch ---

    function sum(a::Real, b::Real)
        return _sum(Float32(a), Float32(b))
    end

    function pow(base::Integer, exp::Integer)
        return _pow(Int32(base), Int32(exp))
    end

end # CppLib

function main()

    if !isfile(LIB_CPP)
        error("Library not found at $LIB_CPP. Please run CMake build first.")
    end

    value_a, value_b = 14.5f0, 5.5f0 # 'f0' for Float32 literals
    result = CppLib.sum(value_a, value_b)
    println("Sum Test: $value_a + $value_b = $result") # 20.0

    base = 5
    exp = 3
    result = CppLib.pow(base, exp)
    println("Pow Test: $base^$exp = $result") # 125

    bases = [1, 2, 3, 4, 5]
    exp = 2
    result = CppLib.pow.(bases, exp) # using Julia's broadcasting
    println("Array Pow Test: ", result) # [1, 4, 9, 16, 25]

end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
