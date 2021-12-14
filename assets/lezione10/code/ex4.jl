# This file was generated, do not modify it. # hide
@doc """
    rand(glc::GLC)

Return a pseudo-random number uniformly distributed in the
interval [0, 1).
"""
rand(glc::GLC) = rand(glc, 0.0, 1.0)