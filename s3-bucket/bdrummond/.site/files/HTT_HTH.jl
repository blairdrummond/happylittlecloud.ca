#!/usr/bin/env julia

# Given an unbiased sequence of coin flips {H,T}
#
# How long until you first see HTT? What about HTH?
#
# Answer given by simulation and analytically by taking
# a Random walk on the third deBruijn graph with a sink
# at HTT or HTH. Compute the expected value using matrix
# algebra. Recall: I + Q + Q^2 ... = (I-Q)^{-1}
#
# Blair Drummond, 2019

using Printf
using LinearAlgebra: I
using Distributed
using SharedArrays: SharedArray

global const H = true
global const T = false
global const TRIALS = 2000000

function bits(k::Int)
    Channel() do channel
        if k <= 1
            put!(channel, [T])
            put!(channel, [H])
        else
            for x in bits(k-1)
                put!(channel, push!(copy(x), T))
                put!(channel, push!(copy(x), H))
            end
        end
    end
end


###############################################
### Simulate the hitting time of HTT vs HTH ###
###############################################

function simulation(HT_::Array{Bool,1})
    # initialize random
    acc = rand([H,T], 3)
    i = 0
    while acc != HT_
        popfirst!(acc)
        push!(acc, rand([H,T]))
        i = i + 1
    end
    return i
end


HTT = (@distributed (+) for i=1:TRIALS; simulation([H,T,T]); end) / TRIALS
HTH = (@distributed (+) for i=1:TRIALS; simulation([H,T,H]); end) / TRIALS

println("Simulated Result:")
println()
@printf "    Hitting time of HTT: %f\n"  HTT
@printf "    Hitting time of HTH: %f\n"  HTH
println()
println()

###########################
### Analytical Solution ###
###########################

function order(binary_number::Array{Bool, 1})
    # compute base 2 value
    rev = reverse(binary_number)
    i = 0
    k = 0
    for digit in rev
        k = k + digit * (2^i)
        i = i + 1
    end
    return k
end

function deBruijn(n)
    # Create the matrix for the 
    # symmetric random walk on the nth deBruijn Graph 
    # I like stochastic columns.
    mat = SharedArray{Float64,2}(2^n,2^n)
    @sync @async for v = bits(n+1)
        mat[
            1+order(v[1:end-1]),
            1+order(v[2:end])
        ] = 0.5
    end
    return transpose(mat)
end

# Take the nth deBruijn graph, and redirect state 4 or 5 (HTT or HTH) to zero.
#
# m[:, 4] = 0   or   m[:, 5] = 0
#
# So, once you reach 4 or 5, you "exit" the Markov Chain. However, the rows 4 and 5
# still capture the probability of transitioning into state 4 or 5, and therefore,
#
# n steps in markov chain -\           /- uniform initial probabilities
#                          |           |
#         \sum_n  n e_4   m^n (1/8, 1/8, 1/8 ... , 1/8)^T
#                 |  |
#                 |  |
#                 |   \- extract the 4th row. e_4 = (0,0,0,0,1,0,0,0)
#                 |
#                 \- from E[wait time], expected number of steps
#
#      = e_4 @ ( sum_{n=0}  n m^n ) @ (1/8, 1/8, ... , 1/8)^T
#      = e_4 @ ( m sum_{n=0}  n m^{n-1}   ) @ (1/8, 1/8, ... , 1/8)^T
#      = e_4 @ ( m {d/dm}(sum_{n=0}  m^n) ) @ (1/8, 1/8, ... , 1/8)^T
#      = e_4 @ ( m {d/dm} (1-m)^{-1} ) @ (1/8, 1/8, ... , 1/8)^T
#      = e_4 @ ( m  (1-m)^{-2} ) @ (1/8, 1/8, ... , 1/8)^T

M = deBruijn(3)
Id = zeros(8,8)+I

println("Analytical Solution:")
println()

M4 = copy(M)
M4[:, 5] .= zeros(8)
M4I = inv(Id - M4)
HTT_time = (pop!([0 0 0 0 1 0 0 0] * M4 * M4I * M4I * ones(8) / 8))
@printf     "    Hitting time of HTT: %f\n" HTT_time




M5 = copy(M)
M5[:, 6] .= zeros(8)
M5I = inv(Id - M5)
HTH_time = (pop!([0 0 0 0 0 1 0 0] * M5 * M5I * M5I * ones(8) / 8))
@printf "    Hitting time of HTH: %f\n" HTH_time
println()



# using LightGraphs
# using NetworkLayout:Spectral
# 
# layout(M%I)


