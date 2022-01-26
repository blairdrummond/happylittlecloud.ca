#!/usr/bin/env python

""" Given an unbiased sequence of coin flips {H,T}

    How long until you first see HTT? What about HTH?

    Answer given by simulation and analytically by taking
    a Random walk on the third deBruijn graph with a sink
    at HTT or HTH. Compute the expected value using matrix
    algebra. Recall: I + Q + Q^2 ... = (I-Q)^{-1}

    Blair Drummond, 2019
"""

from random import choice
import numpy as np


def bits(k):
    """ Generate all bitstrings """
    if k <= 1:
        yield [0]
        yield [1]
    else:
        for b in bits(k-1):
            yield [0] + b
            yield [1] + b

""" ###############################################
    ### Simulate the hitting time of HTT vs HTH ###
    ###############################################
"""
def simulation(abc):
    """ Generate random string until you find abc """
    acc = []
    while len(acc) < len(abc):
        acc = acc + [choice([0,1])]
        
    i = 0
    while acc != abc:
        del acc[0]
        acc = acc + [choice([0,1])]
        i = i + 1
    return i
        

def ntrials(abc, n):
    """ average over n trials """
    return ( 0.0 + sum([simulation(abc) for i in range(n)]) ) / n

print("Simulated Result:")
print()
print('    {}: {}'.format("Hitting time of HTT", ntrials([1, 0, 0], 2000000)))
print('    {}: {}'.format("Hitting time of HTH", ntrials([1, 0, 1], 2000000)))
print()
print()





""" ###########################
    ### Analytical Solution ###
    ###########################
"""

def order(binary_number):
    """ compute base 2 value """
    rev = reversed(binary_number)
    i = 0
    k = 0
    for digit in rev:
        k = k + digit * (2**i)
        i = i + 1
    return k


# def inv_order(number,k):
#     def __inv__(n):
#         if n == 0:
#             return [0]
#         elif n == 1:
#             return [1]
# 
#         q = n % 2
#         p = n // 2
# 
#         return __inv__(p) + [q]
# 
#     seq = __inv__(number)
# 
#     return [0]*(k - len(seq)) + seq


def deBruijn(n):
    """ Create the matrix for the 
        symmetric random walk on the nth deBruijn Graph 
        I like stochastic columns.
    """
    mat = np.zeros((2**n, 2**n))
    for v in bits(n+1):
        mat[order(v[:-1])][order(v[1:])] = 0.5

    return np.transpose(mat)

#def reindex(m, d):
#    """ Re-index the state-space of a markov chain, using a dict """
#    m2 = m.copy()
#    l, w = m.shape
#    for i in range(l):
#        for j in range(w):
#            m2[i][j] = m[d[i]][d[j]]
#    return m2

""" Take the nth deBruijn graph, and redirect state 4 or 5 (HTT or HTH) to zero.
  
    m[:, 4] = 0   or   m[:, 5] = 0

    So, once you reach 4 or 5, you "exit" the Markov Chain. However, the rows 4 and 5
    still capture the probability of transitioning into state 4 or 5, and therefore,

 n steps in markov chain -\           /- uniform initial probabilities
                          |           |
         \sum_n  n e_4   m^n (1/8, 1/8, 1/8 ... , 1/8)^T
                 |  |
                 |  |
                 |   \- extract the 4th row. e_4 = (0,0,0,0,1,0,0,0)
                 |
                 \- from E[wait time], expected number of steps

         = e_4 @ ( sum_{n=0}  n m^n ) @ (1/8, 1/8, ... , 1/8)^T
         = e_4 @ ( m sum_{n=0}  n m^{n-1}   ) @ (1/8, 1/8, ... , 1/8)^T
         = e_4 @ ( m {d/dm}(sum_{n=0}  m^n) ) @ (1/8, 1/8, ... , 1/8)^T
         = e_4 @ ( m {d/dm} (1-m)^{-1} ) @ (1/8, 1/8, ... , 1/8)^T
         = e_4 @ ( m  (1-m)^{-2} ) @ (1/8, 1/8, ... , 1/8)^T

"""



M = deBruijn(3)
ones = np.ones(8)
I = np.identity(8)
inv = np.linalg.inv

print("Analytical Solution:")
print()

M4 = M.copy()
M4[:, 4] = np.zeros(8)
#M4 = reindex(M4, {0:4, 1:1, 2:2, 3:3, 4:0, 5:5, 6:6, 7:7})
M4I = inv(I - M4)
print('    Hitting time of HTT: {}'.format(
    #         e4                  m    (1-m)^{-2}        (1/8, 1/8, ... , 1/8)
    np.array([0,0,0,0,1,0,0,0]) @ M4 @ M4I @ M4I @ np.transpose(ones / 8)
))




M5 = M.copy()
M5[:, 5] = np.zeros(8)
#M5 = reindex(M5, {0:5, 1:1, 2:2, 3:3, 4:4, 5:0, 6:6, 7:7})
M5I = inv(I - M5)
print('    Hitting time of HTH: {}'.format(np.array([0,0,0,0,0,1,0,0]) @ M5 @ M5I @ M5I @ np.transpose(ones / 8)))
print()


