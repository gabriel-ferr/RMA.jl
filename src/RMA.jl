#
#           RecurrenceMicrostates.jl
#       By Gabriel Vinicius Ferreira (https://github.com/gabriel-ferr), Gabriel Marghoti (https://github.com/GabrielMarghoti)
#       Advisors: Thiago de Lima Prado and Sérgio Roberto Lopes
#
#           Abstract: The idea of this project is to create a standard library that
#   can be used in the application and development of Recurrence Microstates Theory
#   and its associated quantifiers. Here we try to generalize the computational process
#   so that it can be applied to any data situation, such as time series, images, or 
#   high-dimensional data.
#
#       GitHub - Julia Version: https://github.com/gabriel-ferr/RecurrenceMicrostates.jl
#
#       References:
#   [1] J.-P. Eckmann, S. O. Kamphorst, and D. Ruelle, Europhys. Lett 4, 973 (1987).
#   [2] G. Corso, T. de Lima Prado, G. Z. dos Santos Lima, J. Kurths, and S. R. Lopes, Chaos 28 (2018), 10.1063/1.5042026.
#   [3] N. Marwan, J. Kurths, and P. Saparin, Physics Letters A 360, 545 (2007).
#
#       ----- BEGIN CODE
module RMA
    #
    #       Libraries needed for the code to work.
    using Distances

    #       Metrics
    const euclidean_metric = Euclidean()

    #
    #       Import of the source code parts.
    include("cpu/recurrence.jl")
    include("cpu/square_index.jl")
    include("cpu/triangle_index.jl")
    include("cpu/vect/vect_square_full.jl")
    include("cpu/vect/vect_square_random.jl")
    include("cpu/vect/vect_square_random_async.jl")
    include("cpu/vect/vect_square_columnwise.jl")
    include("cpu/vect/vect_triangle_random.jl")
    include("cpu/vect/vect_triangle_random_async.jl")

    include("cpu/microstates.jl")
    include("rma/vect_entropy.jl")

    include("utils/prepare.jl")
    #
    #       Exports
    export microstates
    export entropy
    export prepare
end
#        ----- END CODE
