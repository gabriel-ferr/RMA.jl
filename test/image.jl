using RecurrenceMicrostates
using BenchmarkTools
using ProgressMeter
using Images
using JLD2

const n = [2, 2, 2, 2]
const threshold = (0.3, 0.6)
const samples_range = range(0.01, 1, 20)

const settings = power_vector(n)

function main()
    img = Float64.(Gray.(load("test/3.png")))
    sz = size(img)
    global data = zeros(Float64, 1, sz[1], sz[2])

    for i in 1:sz[1]
        for j in 1:sz[2]
            data[1, i, j] = img[i, j]
        end
    end

    trials = []
    @showprogress for i in eachindex(samples_range)
        global percent = samples_range[i]
        push!(trials, (samples_range[i], @benchmark microstates(data, data, threshold, settings; samples_percent = percent)))
    end
    
    save_object("test/image-results.dat", trials)
end

main()