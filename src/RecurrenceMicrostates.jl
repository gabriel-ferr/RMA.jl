#
#           RecurrenceMicrostates.jl
#       By Gabriel Vinicius Ferreira (https://github.com/gabriel-ferr)
#       Advisors: Thiago de Lima Prado and Sérgio Roberto Lopes
#
#           Abstract: The idea of this project is to create a standard library that
#   can be used in the application and development of Recurrence Microstates Theory
#   and its associated quantifiers. Here we try to generalize the computational process
#   so that it can be applied to any data situation, such as time series, images, or 
#   high-dimensional data.
#
#       GitHub: https://github.com/gabriel-ferr/RecurrenceMicrostates.jl
#
#       References:
#   [1] J.-P. Eckmann, S. O. Kamphorst, and D. Ruelle, Europhys. Lett 4, 973 (1987).
#   [2] G. Corso, T. de Lima Prado, G. Z. dos Santos Lima, J. Kurths, and S. R. Lopes, Chaos 28 (2018), 10.1063/1.5042026.
#   [3] N. Marwan, J. Kurths, and P. Saparin, Physics Letters A 360, 545 (2007).
#
#       ----- BEGIN CODE
module RecurrenceMicrostates
    #
    #       Libraries needed for the code to work.
    using Distances

    #
    #       Import of the source code parts.
    include("utils/vector.jl")
    include("cpu/microstates.jl")
    include("cpu/recurrence.jl")

    #
    #       Exports
    export power_vector
    export microstates
end
#       ----- END CODE