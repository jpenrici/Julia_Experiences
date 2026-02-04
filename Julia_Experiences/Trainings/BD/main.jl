# main.jl

# Use local environment
using Pkg
Pkg.activate(".")
Pkg.instantiate()

# Local module
include("db_manager.jl")


function main()
    db_file = "my_activities.db"
    db = init_database(db_file)

    println("--- Activities ---")
    println("1. Register Activity")
    println("2. View Activity by Date Range")
    print("Choose an option: ")

    choice = readline()

    if choice == "1"
        print("Enter User ID: ")
        user = readline()
        print("Enter Activity Description: ")
        act = readline()
        insert_activity(db, user, act)

        elseif choice == "2"
        println("Enter range (Format: YYYY-MM-DD)")
        print("Start Date: ")
        s_date = readline() * " 00:00:00"
        print("End Date: ")
        e_date = readline() * " 23:59:59"

        df = query_activities_by_date(db, s_date, e_date)

        if isempty(df)
            println("No activities found for this period.")
            else
                println("\n", df)
            end
        else
            println("Invalid option.")
        end
    end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
