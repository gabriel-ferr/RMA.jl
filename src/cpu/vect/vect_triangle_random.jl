#
#           
#

function triangle_random(data_x::AbstractArray, data_y::AbstractArray, threshold, structure::AbstractVector{Int}, space_size::AbstractVector{Int}, num_samples::Int, func::F, dim::AbstractVector{Int}) where {F}
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
    #
    #       Alloc memory for histogram and the index list
    hg = zeros(Int, 2^exponent)
    idx = ones(Int, length(space_size))
    recursive_index = zeros(Int, length(structure))

    #
    #       Do the process...
    @inbounds for _ in 1:num_samples
        for s in eachindex(space_size)
            idx[s] = rand(1:space_size[s])
        end

        @fastmath hg[compute_triangle_index(data_x, data_y, threshold, structure, func, dim, idx, recursive_index, p_vect)] += 1
    end

    return hg
end