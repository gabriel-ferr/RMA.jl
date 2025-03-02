#
#           
#
@inline function recurrence(x::AbstractArray, y::AbstractArray, threshold::Float64, idx::AbstractVector{Int}, dim::AbstractVector{Int})
    #   TODO - Fix the memory allocation "bottleneck" that Julia causes in this piece of code.
    #       I really don't know how I can fix it =/
    return @inbounds evaluate(euclidean_metric, view(x, :, view(idx, 1:dim[1])), view(y, :, view(idx, dim[1]+1:dim[1] + dim[2]))) <= threshold
end
#
#
@inline function recurrence(x::AbstractArray, y::AbstractArray, threshold::Tuple{Float64, Float64}, idx::AbstractVector{Int}, dim::AbstractVector{Int})
    #   TODO - Same thing...
    distance = @inbounds evaluate(euclidean_metric, view(x, :, view(idx, 1:dim[1])), view(y, :, view(idx, dim[1]+1:dim[1] + dim[2])))
    return ( distance >= threshold[1] && distance <= threshold[2])
end