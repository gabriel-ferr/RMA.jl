#
#           Standard Recurrence
function recurrence(x::AbstractVector, y::AbstractVector, threshold::Union{Float32, Float64})
    return (threshold - euclidean(x, y)) >= 0 ? Int8(1) : Int8(0)
end
#
#           Corridor Recurrence
function recurrence(x::AbstractVector, y::AbstractVector, threshold::Tuple{Union{Float32, Float64}, Union{Float32, Float64}})
    return ((euclidean(x, y) - threshold[1]) >= 0 ? Int8(1) : Int8(0)) * (threshold[2] - euclidean(x, y)) >= 0 ? Int8(1) : Int8(0)
end