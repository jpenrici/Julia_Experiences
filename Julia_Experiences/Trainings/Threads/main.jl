# main.jl

using BenchmarkTools
using Base.Threads


"""
compute_heavy_power(range_end::Int)
Performs serial computation using BigInt to avoid overflow.
"""
function compute_heavy_power(range_end::Int)
    results = Vector{BigInt}(undef, range_end)
    for i in 1:range_end
        results[i] = BigInt(i)^50
    end
    return results
end


"""
compute_parallel_power(range_end::Int)
Performs the same computation but distributed across CPU threads.
"""
function compute_parallel_power(range_end::Int)
    results = Vector{BigInt}(undef, range_end)
    @threads for i in 1:range_end
        results[i] = BigInt(i)^50
    end
    return results
end


const ARRAY_SIZE = 5000

function main()

    # Verification of BigInt power
    sample_val = compute_parallel_power(10)[10]
    println("\nValue of 10^50: ", sample_val)
    println("Type of result: ", typeof(sample_val))
    println("-" ^ 80)

    println("Running Benchmarks for $ARRAY_SIZE elements...")
    println("Number of threads available: ", nthreads())

    println("\nSerial Execution Time:")
    @btime compute_heavy_power($ARRAY_SIZE);

    println("\nParallel Execution Time:")
    @btime compute_parallel_power($ARRAY_SIZE);

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

#=
    Run:
        julia -t auto main.jl
=#
