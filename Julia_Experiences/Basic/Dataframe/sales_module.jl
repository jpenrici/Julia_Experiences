# sales_module.jl

module SalesModule

    using Random
    using Dates
    using DataFrames

    export Product, generate_sales_data, USD, BRL, EUR

    abstract type Currency end

    struct USD <: Currency end
    struct BRL <: Currency end
    struct EUR <: Currency end

    struct Product
        name::String
        base_price::Float64
        currency::Currency
    end

    format_symbol(::USD) = "\$"
    format_symbol(::BRL) = "R\$"
    format_symbol(::EUR) = "€"

    const TECH_PRODUCTS = [
        Product("Laptop Pro", 1200.0, USD()),
        Product("Mechanical Keyboard", 150.0, BRL()),
        Product("Ultrawide Monitor", 450.0, EUR()),
        Product("Wireless Mouse", 50.0, USD()),
        Product("USB-C Hub", 80.0, BRL())
        ]

    """
    Generates a DataFrame with random sales records.
    Exploits Julia's broadcasting and functional approach.
    """
    function generate_sales_data(num_records::Int)
        # Equivalent to Python's random.choice
        products = [rand(TECH_PRODUCTS) for _ in 1:num_records]

        names = [p.name for p in products]
        prices = [p.base_price for p in products]
        quantities = rand(1:10, num_records)

        symbols = [format_symbol(p.currency) for p in products]

        # Generating random dates within the last 30 days
        dates = [today() - Day(rand(0:30)) for _ in 1:num_records]

        # Create the DataFrame
        df = DataFrame(Date = dates,
                    Product = names,
                    Quantity = quantities,
                    Price = prices,
                    Currency = symbols
                    )

        return df
    end

end # SalesModule
