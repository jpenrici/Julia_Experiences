# math_module.jl

module MathModule

    export sum_squares

    function sum_squares(n::Int)::Float64
        result = 0.0
        # Use Single Instruction, Multiple Data
        @simd for i in 1:n
            @inbounds result += Float64(i)^2
        end
        return result
    end

end

if abspath(PROGRAM_FILE) == @__FILE__

    @assert MathModule.sum_squares(2)  == 5
    @assert MathModule.sum_squares(10) == 385

end
