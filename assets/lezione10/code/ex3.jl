# This file was generated, do not modify it. # hide
@doc """
    rand(glc::GLC, xmin, xmax)

Return a pseudo-random number uniformly distributed in the
interval [xmin, xmax).
"""
function rand(glc::GLC, xmin, xmax)
    glc.seed = (glc.a * glc.seed + glc.c) % glc.m
    xmin + (xmax - xmin) * glc.seed / glc.m
end