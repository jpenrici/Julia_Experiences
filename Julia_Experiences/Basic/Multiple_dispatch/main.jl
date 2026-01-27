# main.jl

# Structures
struct ProcessConfig
    id::Int
    name::Symbol
end

mutable struct ProcessLog
    config::ProcessConfig
    status::Symbol
    # Store as (level=:info, msg="...")
    history::Vector{NamedTuple{(:level, :msg), Tuple{Symbol, String}}}
end

# Functions
function handle_event(log::ProcessLog, status::Symbol, message::String)
    log.status = status
    push!(log.history, "New Status: $status - $message")
    println("Log updated for $(log.config.name)")
end

function handle_event(log::ProcessLog, status::Symbol, messages...)
    log.status = status
    add_entries!(log, messages...)
end

function add_entries!(log::ProcessLog, level::Symbol, entries...)
    for e in entries
        push!(log.history, (level=level, msg=e))
    end
end

function report(target::ProcessConfig)
    printstyled("\n--- ID: $(target.id) - NAME: $(target.name) ---\n", color=:cyan, bold=true)
end

function report(target::ProcessLog)
    report(target, :all)
end

function report(target::ProcessLog, filter_level::Symbol)
    header = filter_level == :all ? "FULL REPORT" : "FILTERED REPORT ($(filter_level))"

    printstyled("\n--- $header: $(target.config.name) ---\n", color=:cyan, bold=true)

    filtered_history =
            if filter_level == :all
                target.history
            else
                filter(entry -> entry.level == filter_level, target.history)
            end

    if isempty(filtered_history)
        println("No entries found for level: $filter_level")
        return
    end

    for entry in filtered_history
        # Color logic
        line_color = entry.level == :error ? :red :
            entry.level == :warn  ? :yellow : :light_black

        printstyled("[$(entry.level)] ", color=line_color, bold=true)
        println(entry.msg)
    end
end

function report(target::ProcessLog, keyword::String)

    printstyled("\n--- SEARCH RESULTS FOR: '$keyword' ---\n", color=:magenta, bold=true)

    results = filter(x -> contains(lowercase(x.msg), lowercase(keyword)), target.history)

    if isempty(results)
        println("No logs match the keyword.")
    else
        for r in results
            println("-> [$(r.level)] $(r.msg)")
        end
    end
end

# Execution
function main()

    # Creating instances
    core_config = ProcessConfig(101, :DataProcessor)
    my_log = ProcessLog(core_config, :Idle, [])

    # Simulating mixed log entries using Splat
    add_entries!(my_log, :info, "System boot", "Service started")
    add_entries!(my_log, :warn, "High memory usage detected")
    add_entries!(my_log, :error, "Connection lost to Database", "Retry failed")
    add_entries!(my_log, :info, "Clean exit")

    # Report
    report(core_config)
    report(my_log)

    count_entries = (l) -> length(l.history)
    println("Total entries logged: $(count_entries(my_log))")

    # Find all erros
    report(my_log, :error)

    # Find by word
    word = "dataBase"
    report(my_log, word)

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
