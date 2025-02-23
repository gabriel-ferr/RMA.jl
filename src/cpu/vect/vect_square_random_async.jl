#
#           
#

function square_random_async(data_x::AbstractArray, data_y::AbstractArray, threshold, structure::AbstractVector{Int}, space_size::AbstractVector{Int}, num_samples::Int, func::F, dim::AbstractVector{Int}, hypervolume::Int) where {F}
    #
    #       Compute the Power Vector
    p_vect = zeros(Int, hypervolume)
    for i in 1:hypervolume
        p_vect[i] = 2^(i-1)
    end
    sdim = sum(dim)

    #
    #       Creates a function to work as our async task.
    function square_random_task(segment::UnitRange{Int})
        hg = zeros(Int, 2^hypervolume)
        idx = zeros(Int, length(space_size))
        recursive_index = zeros(Int, length(structure))

        @inbounds for _ in segment
            for s in eachindex(space_size)
                idx[s] = rand(1:space_size[s])
            end

            @fastmath hg[compute_square_index(data_x, data_y, threshold, structure, func, dim, sdim, idx, recursive_index, p_vect)] += 1
        end

        return hg
    end

    #       Split the samples between the number of available threads
    int_sampling_value = floor(Int, num_samples / Threads.nthreads())
    rest_sampling_value = num_samples % Threads.nthreads()

    #
    #       Initialize our tasks...
    tasks = []
    start_value = 1
    for _ in 1:Threads.nthreads()
        incrementor = int_sampling_value + (rest_sampling_value > 0 ? 1 : 0)
        segment = start_value:start_value+incrementor - 1

        push!(tasks, Threads.@spawn square_random_task(segment))

        start_value += incrementor
        if (rest_sampling_value > 0)
            rest_sampling_value -= 1
        end
    end

    results = fetch.(tasks)

    res = zeros(Int, 2^hypervolume)
    for r in results
        res .+= r
    end

    return res
end