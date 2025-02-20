#
#
function entropy(probs::AbstractVector)
    s = 0
    for prob in probs
        if (prob > 0)
            s += (-1) * prob * log(prob)
        end
    end

    return s
end