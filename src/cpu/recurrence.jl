#
#           
#

@inline function recurrence(x, y, threshold, idx, dim, sdim)
    #   TODO - Fix the memory allocation bottleneck that Julia causes in this piece of code.
    #       I really don't know how I can fix it =/
    return @inbounds evaluate(euclidean_metric, view(x, :, view(idx, 1:dim[1])), view(y, :, view(idx, dim[1]+1:sdim))) <= threshold
end