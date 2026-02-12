# main.jl

mutable struct TemperatureSensor{T <: AbstractFloat}
    uid::Int
    current_temp::Union{T, Nothing}
    threshold::T

    # Inner constructor
    function TemperatureSensor(uid::Int, temp::T, limit::T) where T <: AbstractFloat
        if limit < 0
            error("Thresold cannot be negative!")
        end
        new{T}(uid, temp, limit)
    end
end

# Outer constructor
function TemperatureSensor(uid::Int, temp::Real, limit::Real)
    common_type = promote_type(typeof(temp), typeof(limit))
    final_type = common_type <: AbstractFloat ? common_type : Float64
    return TemperatureSensor(uid, final_type(temp), final_type(limit))
end

# Shorthand constructor
TemperatureSensor(uid::Int) = TemperatureSensor(uid, 0.0, 100.0)

# Process batch
function process_batch(sensors::Vector{TemperatureSensor{Float32}})
    for s in sensors
        s.current_temp += 0.1f0
        println("BATCH: Sensor $(s.uid) [F32]: Reading updated.")
    end
end

function process_batch(sensors::Vector{TemperatureSensor{Float64}})
    for s in sensors
        s.current_temp += 0.5f0
        println("BATCH: Sensor $(s.uid) [F64]: Reading updated.")
    end
end

function process_batch(sensors::Vector{TemperatureSensor{T}}) where T <: AbstractFloat
    for s in sensors
        println("BATCH: Sensor $(s.uid): Current temp is $(s.current_temp)")
    end
end

function update_reading!(s::TemperatureSensor{T}) where T
    # 20% chance of sensor failure
    if rand() < 0.2
        s.current_temp = nothing
        println("Sensor $(s.uid): Critical Failure! Reading is 'nothing'.")
    else
        # Success: generating a random value around the threshold
        s.current_temp = s.threshold + randn() * 5
        println("Sensor $(s.uid): Reading updated successfully.")
    end
end

function analyze_sensor(s::TemperatureSensor{T}) where T
    if isnothing(s.current_temp)
        return "STATUS_ERROR: No data available for Sensor $(s.uid)"
    end

    if s.current_temp > s.threshold
        return "STATUS_ALARM: Value $(s.current_temp) exceeds $(s.threshold)"
    else
        return "STATUS_OK: Value $(s.current_temp) is safe"
    end
end

function main()

    s1 = TemperatureSensor(101, 25.5, 50.0)
    s2 = TemperatureSensor(102, 30, 80.5)
    s3 = TemperatureSensor(103)

    s1.current_temp = 62.3

    println("Sensor 1 type: ", typeof(s1))
    println("Sensor 2 type: ", typeof(s2))
    println("Sensor 3 type: ", typeof(s3))

    println(analyze_sensor(s1))
    println(analyze_sensor(s2))
    println(analyze_sensor(s3))

    println("-" ^ 80)

    sensors_1 = [
        TemperatureSensor(1, 25.0f0, 40.0f0),
        TemperatureSensor(2, 26.5f0, 40.0f0)
    ]

    sensors_2 = [
        TemperatureSensor(3, 25.0, 50.0),
        TemperatureSensor(4, 22.123456789, 50.0)
    ]

    process_batch(sensors_1)
    process_batch(sensors_2)

    println("-" ^ 80)

    sensors = [sensors_1, sensors_2]

    for sensor in sensors
        for s in sensor
            update_reading!(s)
            println(analyze_sensor(s))
            println("-" ^ 80)
        end
    end

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
