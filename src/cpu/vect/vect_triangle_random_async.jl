#
#       TODO - Find where this code is allocating memory (912B -> 29.65MiB)
#
function triangle_random_async(data_x::AbstractArray, data_y::AbstractArray, threshold, structure::AbstractVector{Int}, space_size::AbstractVector{Int}, num_samples::Int, func::F, dim::AbstractVector{Int}) where {F}
    #
    #       Compute the Power Vector
    p_vect::Vector{Int} = []
    exponent = 0
    for j = 1:structure[2]
        for _ = j:structure[1]
            push!(p_vect, 2^exponent)
            exponent += 1
        end
    end

    function triangle_random_task(segment::UnitRange{Int})
        #       Alloc memory for histogram and the index list
        hg = zeros(Int, 2^exponent)
        idx = ones(Int, length(space_size))
        recursive_index = zeros(Int, length(structure))

        @inbounds for _ in segment
            for s in eachindex(space_size)
                idx[s] = rand(1:space_size[s])
            end

            @fastmath hg[compute_triangle_index(data_x, data_y, threshold, structure, func, dim, idx, recursive_index, p_vect)] += 1
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

        push!(tasks, Threads.@spawn triangle_random_task(segment))

        start_value += incrementor
        if (rest_sampling_value > 0)
            rest_sampling_value -= 1
        end
    end

    results = fetch.(tasks)

    res = zeros(Int, 2^exponent)
    for r in results
        res .+= r
    end

    return res
end