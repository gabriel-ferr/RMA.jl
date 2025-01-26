#
#           Standard Recurrence
function recurrence(x::AbstractVector, y::AbstractVector, threshold::Union{Float32, Float64})
    return (threshold - euclidean(x, y)) >= 0 ? Int8(1) : Int8(0)
end