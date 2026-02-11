# main.jl

const FACTOR = 1000

function calc(number1::Real, number2::Int)::Real

    result = let  # random expression
        a = abs(number1)
        b = iseven(number2) ? number2 : number2 + 1 # iseven check only integer
        c = number1 * number2

        r = a + b + c + FACTOR # global constant usage
        r > 100 ? r : -r # use of ternary operator
    end

    return result
end

function calc(data::AbstractVector, number::Int)::Vector
    # taking advantage of precedence
    return data .|> x -> calc(x, number) |> sum
end

function calc2(data::AbstractVector, number::Int)::Real
    # studying pipe behavior
    return (data .|> x -> calc(x, number)) |> sum
end

function calc(data::AbstractVector)::Real
    return sum(calc.(data, 0))
end

function main()

    # compact function
    separator() = println('-' ^ 80)

    println("Result: ", calc(1, 20))
    separator()

    println("Result: ", calc([-5, 2, 10, -3], 5))
    println("Result: ", calc2([-5, 2, 10, -3], 5))
    separator()

    println("Result: ", calc([-1.5, 2, 10, -3]))
    separator()

    # compact function, chaining of commands
    f1(n1, n2) = calc(n1, n2) + 1000; println("Result: ", f1(1, 20))
    separator()

    # Short-Circuit Evaluation
    r = f1(100, 200)
    r < 5000 && (println("Result: $r"); separator())
    
    # Metaprogramming
    f2 = :(10 + FACTOR)
    println("Result: ",eval(f2), "\t", typeof(f2));
    separator()

    # Block
    f3(x) = map(x) do y
        r = sum(x) * y
        return r + 10
    end
    println("Result: ", f3([1, 2, 3]))
    separator()

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
