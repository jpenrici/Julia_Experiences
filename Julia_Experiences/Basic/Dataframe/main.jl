# main.jl

# Use local environment
using Pkg
Pkg.activate(".")
Pkg.instantiate()

# Main dependencies
using DataFrames
using XLSX

# Local module
include("sales_module.jl")
using .SalesModule


function export_xlsx(df::DataFrame)

    # 1. Check DataFrame
    if isempty(df)
        println("Error: Dataframe is empty.")
        return false
    end

    # Export to XLSX
    println("--- Exporting to XLSX ---")

    filename = "sales_report.xlsx"
    num_rows = nrow(df)

    XLSX.writetable(filename, "Report" => df, overwrite=true)

    XLSX.openxlsx(filename, mode="rw") do xf
        sheet = xf["Report"]

        # Columns: A(Date), B(Product), C(Quantity), D(Price), E(Currency), F(Total)
        sheet[1, 6] = "Total" # Column 6 is 'F'

        for i in 1:num_rows
            row_idx = i + 1
            # Excel/LibreOffice will interpret this as a formula
            formula_str = "=C$row_idx*D$row_idx"
            sheet[row_idx, 6] = formula_str
        end
    end

    println("Successfully exported $num_rows records to $filename")
    println("Check the 'Total' column in Excel to see the live formulas!")

    return true
end


function main()

    println("Using environment: ", Base.active_project())
    println("--- Starting Sales Report Generator ---")

    num_to_generate = 10
    df = SalesModule.generate_sales_data(num_to_generate)
    println(df)

    if export_xlsx(df)
        println("--- Finished Successfully ---")
    else
        println("--- Finished with Errors ---")
    end
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

# Run - Optional
# julia --project=. main.jl
