using RecurrenceMicrostates
using BenchmarkTools
using ProgressMeter
using Random
using JLD2

rng = MersenneTwister()
Random.seed!()

const n = 2
const beta = 2.99
const timesize = 1000
const threshold = 0.2
const samples_range = range(0.01, 1, 20)

const settings = power_vector(n)

#       Por conta do Benchmark é necessario fazer essa gambiarra =<
percent = 0.0

function beta_x(x; transient = round(Int, (10 * timesize)))
    serie = zeros(Float64, (1, timesize))
    before = x[1]

    for time = 1:(timesize + transient)
        after = before * beta
        while (after > 1.0)
            after = after - 1.0
        end

        before = after

        if (time > transient)
            serie[1, time-transient] = before
        end
    end
    return serie
end

function main()
    if (!isfile("test/beta-x.dat"))
        generated_data = beta_x(rand(Float64, 1))
        save_object("test/beta-x.dat", generated_data)
    end

    global data = load_object("test/beta-x.dat")

    trials = []
    @showprogress for i in eachindex(samples_range)
        global percent = samples_range[i]
        push!(trials, (samples_range[i], @benchmark microstates(data, threshold, settings; samples_percent = percent)))
    end
    
    save_object("test/beta-x-results.dat", trials)
end

main()