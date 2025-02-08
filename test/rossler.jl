using RecurrenceMicrostates
using DifferentialEquations
using BenchmarkTools
using ProgressMeter
using Random
using JLD2

rng = MersenneTwister()
Random.seed!()

const n = 2

const a = 0.1
const b = 0.1
const c = 18.0

const tspan = (0.0, 1000.0)
const threshold = 0.2
const samples_range = range(0.01, 1, 20)

const settings = power_vector(n)

#       Por conta do Benchmark é necessario fazer essa gambiarra =<
percent = 0.0

function rossler!(du, u, p, t)
    x, y, z = u
    du[1] = - y - z
    du[2] = x + a * y
    du[3] = b + z * (x - c)
end

function rossler(ro, t_min)
    prob = ODEProblem(rossler!, ro, tspan, a)
    sol = solve(prob)

    t_index = findall(x -> x > t_min, sol.t)
    return sol.t[t_index], (sol[:, :])[:, t_index]
end

function main()
    if (!isfile("test/rossler.dat"))
        save_object("test/rossler.dat", rossler(rand(Float64, 3), 500))
    end

    global data = load_object("test/rossler.dat")

    trials = []
    @showprogress for i in eachindex(samples_range)
        global percent = samples_range[i]
        push!(trials, (samples_range[i], @benchmark microstates(data[1], data[2], threshold, 0.2, settings; samples_percent = percent)))
    end

    save_object("test/rossler-results.dat", trials)
end

main()