using RecurrenceMicrostates
using DifferentialEquations
using BenchmarkTools
using ProgressMeter
using Random
using JLD2

rng = MersenneTwister()
Random.seed!()

const n = 2
const sigma = 10
const rho = 28
const beta = 8/3.0
const tspan = (0.0, 1000.0)
const threshold = 0.2
const samples_range = range(0.01, 1, 20)

const settings = power_vector(n)

#       Por conta do Benchmark é necessario fazer essa gambiarra =<
percent = 0.0

function lorenz!(du, u, p, t)
    x, y, z = u
    du[1] = sigma * (y - x)
    du[2] = x * (rho - z) - y
    du[3] = x * y - beta * z
end

function lorenz(ro, t_min)
    prob = ODEProblem(lorenz!, ro, tspan, beta)
    sol = solve(prob)

    t_index = findall(x -> x > t_min, sol.t)
    return sol.t[t_index], (sol[:, :])[:, t_index]
end

function main()
    if (!isfile("test/lorenz.dat"))
        save_object("test/lorenz.dat", lorenz(rand(Float64, 3), 500))
    end

    global data = load_object("test/lorenz.dat")

    trials = []
    @showprogress for i in eachindex(samples_range)
        global percent = samples_range[i]
        push!(trials, (samples_range[i], @benchmark microstates(data[1], data[2], threshold, 0.2, settings; samples_percent = percent)))
    end

    save_object("test/lorenz-results.dat", trials)
end

main()