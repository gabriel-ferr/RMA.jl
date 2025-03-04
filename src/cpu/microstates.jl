#
#           
#

function microstates(solution, parameters, n::Int, vicinity::Union{Int, Float64}; shape::Symbol = :square, run_mode::Symbol = :default, sampling_mode::Symbol = :random, num_samples::Union{Int, Float64} = 1.0, func = (x, y, p, ix, dim) -> recurrence(x, y, p, ix, dim), use_threads::Bool = true, transient::Int = 0, max_length::Int = 0)
    #       Prepare the data.
    data = prepare(solution, vicinity; transient = transient, max_length = max_length)

    #       Get data dimension and the structure.
    dim = ndims(data) - 1
    structure = ones(Int, 2 * dim) .* n

    return microstates(data, data, parameters, structure; shape = shape, run_mode = run_mode, sampling_mode = sampling_mode, num_samples = num_samples, func = func, use_threads = use_threads)

end

#
#           
#

function microstates(data::AbstractArray, parameters, n::Int; shape::Symbol = :square, run_mode::Symbol = :default, sampling_mode::Symbol = :random, num_samples::Union{Int, Float64} = 1.0, func = (x, y, p, ix, dim) -> recurrence(x, y, p, ix, dim), use_threads::Bool = true)
    
    #       Get data dimension and the structure.
    dim = ndims(data) - 1
    structure = ones(Int, 2 * dim) .* n

    #       Return the distribution.
    return microstates(data, data, parameters, structure; shape = shape, run_mode = run_mode, sampling_mode = sampling_mode, num_samples = num_samples, func = func, use_threads = use_threads)
end
#
#           
#

function microstates(data_x::AbstractArray, data_y::AbstractArray, parameters, structure::AbstractVector{Int}; shape::Symbol = :square, run_mode::Symbol = :default, sampling_mode::Symbol = :random, num_samples::Union{Int, Float64} = 1.0, func = (x, y, p, ix, dim) -> recurrence(x, y, p, ix, dim), use_threads::Bool = true)
    
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

    #       Number of samples
    total_microstates = 1
    space_size::Vector{Int} = []
    for d in 1:d_x
        len = size(data_x, d + 1) - structure[d]

        total_microstates *= len
        push!(space_size, len)
    end
    for d in 1:d_y
        len = size(data_y, d + 1) - structure[d_x + d]

        total_microstates *= len
        push!(space_size, len)
    end

    if (num_samples isa Float64 || num_samples == 1)
        if (num_samples <= 0 || num_samples > 1)
            throw(ArgumentError("num_samples must be in the range (0, 1]."))
        end
        num_samples = Int(round(num_samples * total_microstates))
    else
        if (num_samples <= 0 || num_samples > total_microstates)
            throw(ArgumentError(string("num_samples must be in the range (1, ", total_microstates,"] for the given data.")))
        end
    end

    #       Compute the hypervolume.
    hypervolume = reduce(*, structure)
    #       Verify if need to use dictionary or not.
    use_dict = run_mode == :dict
    use_dict = hypervolume > 28 ? true : use_dict
    use_dict = run_mode == :vect ? false : use_dict

    #       Call the process...
    if (use_dict)
        throw("Dictionaries not implemented yet") # TODO - All structures, but using dictionaries
    else
        if (hypervolume > 64)
            throw(ArgumentError("Due to memory limitations imposed by Julia, the hyper-volume of a microstate cannot exceed 64."))
        end
        if (shape == :square)
            if (sampling_mode == :full)
                histogram = use_threads ? throw("Not implemented yet") : square_full(data_x, data_y, parameters, structure, space_size, num_samples, func, [d_x, d_y], hypervolume, total_microstates) # TODO - Add async version
                return histogram ./ sum(histogram)
            elseif (sampling_mode == :random)
                histogram =  use_threads ? square_random_async(data_x, data_y, parameters, structure, space_size, num_samples, func, [d_x, d_y], hypervolume) : square_random(data_x, data_y, parameters, structure, space_size, num_samples, func, [d_x, d_y], hypervolume)
                return histogram ./ sum(histogram)
            elseif (sampling_mode == :columnwise)
                if (length(structure) > 2)
                    throw(ArgumentError("The sampling mode `:columnwise` is only available for a recurrence space with two dimensions."))
                end
                histogram = use_threads ? throw("Not implemented yet") : square_columnwise(data_x, data_y, parameters, structure, space_size, num_samples, func, [d_x, d_y], hypervolume)
                return histogram
            else
                throw(ArgumentError("Invalid sampling mode. Use :full, :random or :columnwise"))
            end
        elseif (shape == :triangle)
            if (length(structure) > 2)
                throw(ArgumentError("The shape mode `:triangle` is only available for a recurrence space with two dimensions."))
            end
            if (sampling_mode == :full)
                throw("Not implemented yet") # TODO - Add full version
            elseif (sampling_mode == :random)
                histogram = use_threads ? triangle_random_async(data_x, data_y, parameters, structure, space_size, num_samples, func, [d_x, d_y]) : triangle_random(data_x, data_y, parameters, structure, space_size, num_samples, func, [d_x, d_y])
                return histogram ./ sum(histogram)
            elseif (sampling_mode == :columnwise)
                throw(ArgumentError("Not implemented yet.")) # TODO - Add columnwise sampling
            else
                throw(ArgumentError("Invalid sampling mode. Use :full, :random or :columnwise"))
            end
        else
            throw(ArgumentError("Invalid shape. Use :square or :triangle"))
        end
    end
end