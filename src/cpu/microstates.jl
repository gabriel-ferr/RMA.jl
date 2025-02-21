#
#           
#

function microstates(data_x::AbstractArray, data_y::AbstractArray, threshold, structure::AbstractVector{Int}; shape::Symbol = :square, run_mode::Symbol = :default, sampling_mode::Symbol = :random, num_samples::Union{Int, Float64} = 1.0, func::Function = recurrence, use_threads::Bool = true)
    
    #       Verify the arguments
    if (length(structure) < 2)
        throw(ArgumentError("The microstate structure required at least two values."))
    end
    
    d_x = ndims(data_x) - 1
    d_y = ndims(data_y) - 1

    if (size(data_x, 1) != size(data_y, 1))
        throw(ArgumentError("The data_x and data_y first dimension size must be equal."))
    end

    if (length(structure) != d_x + d_y)
        throw(ArgumentError("The structure and the given data are not compatible."))
    end

    if (num_samples isa Float64 || num_samples == 1)
        if (num_samples <= 0 || num_samples > 1)
            throw(ArgumentError("num_samples as a fraction must be in the range (0, 1]."))
        end
        num_samples = 0 # TODO
    else
        # TODO
    end

    #       Compute the hypervolume.
    hypervolume = reduce(*, structure)
    #       Verify if need to use dictionary or not.
    use_dict = run_mode == :dict
    use_dict = hypervolume > 28 ? true : use_dict
    use_dict = run_mode == :vect ? false : use_dict

    #       Call the process...
    if (use_dict)
        throw("Not implemented yet") # TODO
    else
        if (shape == :square)
            if (sampling_mode == :full)
                throw("Not implemented yet") # TODO
            elseif (sampling_mode == :random)
                return use_threads ? throw("Not implemented yet") : square_random(data_x, data_y, threshold, structure, num_samples, func)
            else
                throw(ArgumentError("Invalid sampling mode. Use :full or :random"))
            end
        else
            throw(ArgumentError("Invalid shape. Use :square")) # TODO - Add triangle version
        end
    end
end