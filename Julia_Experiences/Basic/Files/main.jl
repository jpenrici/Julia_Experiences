# main.jl

using Dates
using Random
using Statistics
using DelimitedFiles

# --- Simulation Logic ---

"""
Generates random greenhouse data for a given number of days.
Returns a Matrix containing [Timestamp, Temperature, Humidity].
"""
function generate_sensor_data(days::Int)

    header = ["Date" "Temp_C" "Humidity_%"]
    data = Matrix{Any}(missing, days, 3)
    start_date = now()

    for i in 1:days
        timestamp = start_date + Day(i)
        # Formatting date to String: YYYY-MM-DD
        data[i, 1] = Dates.format(timestamp, "yyyy-mm-dd")

        # Simulate failures: 10% chance for each sensor
        temp_failure = rand() < 0.10
        humidity_failure = rand() < 0.10

        # Generating random values (Float64)
        if !temp_failure
            data[i, 2] = round(15.0 + rand() * 15, digits=2) # 15°C to 30°C
        end
        if !humidity_failure
            data[i, 3]= round(40.0 + rand() * 20, digits=2) # 40% to 60%
        end

    end

    return vcat(header, data)
end

# --- File Operations ---

function main()

    filename = "greenhouse_data.csv"

    # 1. Generate and Save Data
    println("Generating data...")
    raw_data = generate_sensor_data(30) # days of logs

    writedlm(filename, raw_data, ',')
    println("Data saved to $filename\n")

    # 2. Retrieve Data
    content, header = readdlm(filename, ',', header=true)

    # --- Data Analysis ---
    function parse_sensor_value(val)
        return (val == "" || val == "missing") ? missing : Float64(val)
    end

    temps = parse_sensor_value.(content[:, 2])
    humidities = parse_sensor_value.(content[:, 3])

    clean_temps = collect(skipmissing(temps))
    clean_hums = collect(skipmissing(humidities))

    if !isempty(clean_temps) && !isempty(clean_hums)
        avg_temp = mean(clean_temps)
        min_temp = minimum(clean_temps)
        max_temp = maximum(clean_temps)
        avg_hum = mean(clean_hums)
        max_hum = maximum(clean_hums)
        min_hum = minimum(clean_hums)

        println("--- Greenhouse Report ---")
        println("Period: $(content[1, 1]) to $(content[end, 1])")
        println("Average Temperature: $(round(avg_temp, digits=2))°C")
        println("Minimum Temperature: $(min_temp)°C")
        println("Maximum Temperature: $(max_temp)°C")
        println("Average Humidity: $(round(avg_hum, digits=2))%")
        println("Minimum Humidity: $(round(min_hum, digits=2))%")
        println("Maximum Humidity: $(round(max_hum, digits=2))%")
    else
        println("Critical Error: One or more sensors have no valid data to report.")
    end

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
