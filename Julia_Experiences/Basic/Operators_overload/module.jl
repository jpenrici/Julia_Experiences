# module.jl

module BankSystem

    import Base: +, -, ==, isless

    export CustomerAccount, apply_bonus!

    struct CustomerAccount
        id::Int
        name::String
        balance::Float64
    end

    # Overloads
    function +(acc::CustomerAccount, amount::Real)::CustomerAccount
        return CustomerAccount(acc.id, acc.name, acc.balance + amount)
    end

    function -(acc::CustomerAccount, amount::Real)::CustomerAccount
        return CustomerAccount(acc.id, acc.name, acc.balance - amount)
    end

    function ==(acc1::CustomerAccount, acc2::CustomerAccount)::Boll
        return acc1.id == acc2.id
    end

    function isless(acc1::CustomerAccount, acc2::CustomerAccount)::Bool
        return acc1.balance < acc2.balance
    end

    # Broadcasting
    function apply_bonus!(accs::Vector{CustomerAccount}, bonus::Real)::Vector{CustomerAccount}
        return accs .= accs .+ bonus
    end

    # Anonymous function dispatch
    function apply_bonus!(accs::Vector{T}, logic::Function) where T <: CustomerAccount
        return map!(acc -> CustomerAccount(acc.id, acc.name, acc.balance + logic(acc.balance)), accs, accs)
    end

end  # BankSystem
