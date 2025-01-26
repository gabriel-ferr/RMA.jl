#
#               Microstates
#       Calculates the probability of recurrence microstates for a generalized data.
function microstates(data_x::AbstractArray, data_y::AbstractArray, threshold, settings::MicrostateSettings; samples_percent::Float64 = 0.2, recurr::Function = recurrence)
    if (settings.use_dict)
    else
        return _microstates_with_vectors(data_x, data_y, threshold, settings; samples_percent = samples_percent, recurr = recurr)
    end
end

#
#       Function microstate for discrete time series.
function microstates(data::Array{Union{Float32, Float64}, 2}, threshold, settings::MicrostateSettings; samples_percent::Float64 = 0.2, recurr::Function = recurrence)
    return microstates(data, data, threshold, settings; samples_percent = samples_percent, recurr = recurr)
end

#
#       Function microstate for continuous time series.
function microstates(time, data, threshold, vicinity, settings::MicrostateSettings; samples_percent::Float64 = 0.2, recurr::Function = recurrence)
    new_pos = [1]
    for t in eachindex(time)
        if (t == 1) continue; end;
        if (time[new_pos[length(new_pos)]] + vicinity <= time[t])
            push!(new_pos, t)
        end
    end

    return microstates(data[:, pos], threshold, settings; samples_percent = samples_percent, recurr = recurr)
end

#
#       Calculates the probability of recurrence microstates for a generalized data using vectors.
function _microstates_with_vectors(data_x::AbstractArray, data_y::AbstractArray, threshold, settings::MicrostateSettings; samples_percent::Float64 = 0.2, recurr::Function = recurrence)
    #
    #       Verify data and power vector compatibilities.
    d_x = ndims(data_x) - 1
    d_y = ndims(data_y) - 1
    D = d_x + d_y

    if (d_x != d_y)
        throw("The number of dimensions of data_x and data_y must be equal.")
    end
    if (length(settings.structure) != D)
        throw("The configured Power Vector and the given data are not compatible.")
    end

    rp_hypervolume = reduce(*, size(data_x)[2:end]) * reduce(*, size(data_y)[2:end])
    samples_n = Int(floor(samples_percent * rp_hypervolume))

    samples = zeros(Int, D, samples_n)
    for dim in 1:d_x
        samples[dim, :] .= rand(1:(size(data_x, dim + 1) - (settings.structure[dim] - 1)), samples_n)
        samples[d_x + dim, :] .= rand(1:(size(data_y, dim + 1) - (settings.structure[d_x + dim] - 1)), samples_n)
    end

    dtype = Int8
    if (samples_n > typemax(Int8))
        dtype = Int16
    end
    if (samples_n > typemax(Int16))
        dtype = Int32
    end
    if (samples_n > typemax(Int32))
        dtype = Int64
    end
    if (samples_n > typemax(Int64))
        dtype = Int128
    end
    if (samples_n > typemax(Int128))
        println("Because the number of samples exceeds the storage capacity of an Int128, it is possible for a state to be overloaded.")
    end

    stats = zeros(dtype, (2^settings.hypervolume, Threads.nthreads()))

    #
    #       Calculates the probabilities async.
    function _async_microstates(samples_index, th_index)
        indexes = zeros(Int, length(settings.structure))

        #       Some variables used in the calculation
        add = 0
        counter = 0

        for col in samples_index
            add = 0
            indexes = zeros(Int, length(settings.structure))

            for m in eachindex(settings.vect)
                add = add + settings.vect[m] * recurr(data_x[:, (samples[1:d_x, col] .+ indexes[1:d_x])...], data_y[:, (samples[d_x+1:end, col] .+ indexes[d_x+1:end])...], threshold)
                
                indexes[1] += 1
                for k in 1:length(settings.structure) - 1
                    if (indexes[k] >= settings.structure[k])
                        indexes[k] = 0
                        indexes[k+1] += 1
                    end
                end
            end

            stats[add + 1, th_index] += dtype(1)
            counter += 1
        end

        return counter
    end

    #
    #       Split the work between the threads.
    int_numb = Int(floor(size(samples, 2) ./ Threads.nthreads()))
    rest_samples = size(samples, 2) - Threads.nthreads() * int_numb

    numb_init = int_numb
    if (rest_samples > 0)
        numb_init += 1
        rest_samples -= 1
    end

    samples_idx = [1:numb_init]
    for i = 1:Threads.nthreads() - 1
        numb = int_numb
        if (rest_samples > 0)
            numb += 1
            rest_samples -= 1
        end

        push!(samples_idx, ((samples_idx[i][end] + 1):samples_idx[i][end] + numb))
    end

    tasks = []
    for i = 1:Threads.nthreads()
        push!(tasks, Threads.@spawn _async_microstates(samples_idx[i], i))
    end

    results = fetch.(tasks)
    cnt = 0

    res = zeros(settings.datatype, 2^(settings.hypervolume))
    for i = 1:Threads.nthreads()
        res .= res .+ stats[:, i]
        cnt += results[i]
    end

    res ./= cnt

    return res, cnt
end