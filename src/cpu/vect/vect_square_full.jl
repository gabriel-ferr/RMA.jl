#
#           
#

function square_full(data_x::AbstractArray, data_y::AbstractArray, threshold, structure::AbstractVector{Int}, space_size::AbstractVector{Int}, num_samples::Int, func::F, dim::AbstractVector{Int}, hypervolume::Int, total_microstates::Int) where {F}
    #
    #       Alloc memory for histogram and the index list
    hg = zeros(Int, 2^hypervolume)
    idx = ones(Int, length(space_size))
    recursive_index = zeros(Int, length(structure))
    #
    #       Compute the Power Vector
    p_vect = zeros(Int, hypervolume)
    for i in 1:hypervolume
        p_vect[i] = 2^(i-1)
    end
    #
    #       Do the process...
    @inbounds for _ in 1:total_microstates
        @fastmath hg[compute_square_index(data_x, data_y, threshold, structure, func, dim, idx, recursive_index, p_vect)] += 1

        idx[1] += 1
        for k in 1:length(idx) - 1
            if (idx[k] > space_size[k])
                idx[k] = 1
                idx[k+1] += 1
            else
                break
            end
        end
    end
    #
    #
    return hg
end