# main.jl

include("module.jl")
using .BankSystem


function main()

    separator() = println("-" ^ 80)

    accounts = [
        CustomerAccount(1, "Alice", 1000.0),
        CustomerAccount(2, "Bob", 1500.0),
        CustomerAccount(3, "Charlie", 500.0)
    ]

    println("Original list:")
    foreach(println, accounts)
    separator()

    # Operator Overloading + Broadcasting
    accounts = accounts .+ 60.0
    accounts = accounts .- 10.0

    display(accounts)
    separator()

    # Multiple Dispatch with Fixed Bonus
    apply_bonus!(accounts, 100.0)

    display(accounts)
    separator()

    # Multiple Dispatch with Anonymous Functions
    apply_bonus!(accounts, bal -> bal > 1200.0 ? bal * 0.10 : bal * 0.05)

    display(accounts)
    separator()

    # Sorting via Overload
    sorted_accs = sort(accounts, rev=true)
    println("Sorted (Highest to Lowest) by sort():")
    foreach(println, sorted_accs)
    separator()

    # Manual Filter/Sort style
    high_value_names = [a.name for a in sorted_accs if a.balance > 1000]
    println("\nHigh value names (iterative comprehension): ", high_value_names)
    separator()

    # Anonymous Function Sorting (Ignoring the overload)
    sorted_by_name = sort(accounts, by = x -> length(x.name)) # Lowest to Highest
    println("\nSorted by name length:")
    foreach(println, sorted_by_name)

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
