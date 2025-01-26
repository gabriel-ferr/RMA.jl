#
#           MicrostateSettings
#       This structure is responsible for the storage of information about 
#   the microstates, such as the power vector as it is stored or the tensor 
#   structure.
struct MicrostateSettings
    #       - The Power Vector.
    vect::Vector{Int}
    #       - Structure of Microstate tensor.
    structure::Vector{Int}
    #       - The type of data used to store the probabilities.
    datatype::DataType
    #       - Hiyper-Volume of Microstate.
    hypervolume::Int
    #       - Use dictionary?
    use_dict::Bool
    #       - Index type for dictionary.
    indextype::DataType
end
#
#           Power Vector
#       This function initializes the power vector and also creates a setting structure.
function power_vector(structure::Vector{Int}; datatype::DataType = Float64, force_vector = false, force_dict = false)
    #
    #           ----- BEGIN USER CHECK
    if (length(structure) < 2)
        throw("The microstate structure required at least two dimensions.")
    end
    #           ----- END USER CHECK
    #
    #       Calculates the hypervolume.
    hypervolume = reduce(*, structure)
    #
    #       Analyze whether or not to use dictionaries.
    use_dict = force_dict
    use_dict = (hypervolume > 28) ? true : use_dict
    use_dict = (force_vector) ? false : use_dict
    #       Get the index type if will use dictionary.
    indextype = Int64
    if (use_dict)
        if (hypervolume <= 8)
            indextype = UInt8
        elseif (hypervolume <= 16)
            indextype = UInt16
        elseif (hypervolume <= 32)
            indextype = UInt32
        elseif (hypervolume <= 64)
            indextype = UInt64
        elseif (hypervolume <= 128)
            indextype = UInt128
        else
            throw("Due to memory limitations imposed by Julia, the hyper-volume of a microstate cannot exceed 128.")
        end
    end
    #
    #       Compute the power vector.
    vect = []
    for i in 1:hypervolume
        push!(vect, 2^(i-1))
    end
    #
    #       Build the setting struct and return it.
    return MicrostateSettings(vect, structure, datatype, hypervolume, use_dict, indextype)
end

#
#       Power Vector to square microstates (time series)
function power_vector(n::Int; datatype::DataType = Float64, force_vector = false, force_dict = false)
    return power_vector([n, n]; datatype = datatype, force_vector = force_vector, force_dict = force_dict)
end