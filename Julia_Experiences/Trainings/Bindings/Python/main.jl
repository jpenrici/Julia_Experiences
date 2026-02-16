# main.jl

if haskey(ENV, "VIRTUAL_ENV")
    ENV["JULIA_PYTHONCALL_EXE"] = joinpath(ENV["VIRTUAL_ENV"], Sys.iswindows() ? "Scripts/python.exe" : "bin/python")
end

using PythonCall
using BenchmarkTools

pyimport("sys").path.append(".")
py_mod = pyimport("math_module")

function sum_squares_py(n::Int)
    result = py_mod.sum_squares(n)
    println("n = $n, result = $result")
end

function test()
    sum_squares_py(2)
    sum_squares_py(10)
end

function main()
    n = 10^6
    println("Benchmarking Python function from Julia:")
    @btime py_mod.sum_squares($n)
    println("Benchmarking Numpy function from Julia:")
    @btime py_mod.sum_squares_np($n)
end

if abspath(PROGRAM_FILE) == @__FILE__
    test()
    main()
end
