# This file was generated, do not modify it. # hide
@doc """
    rand(glc::GLC, xmin, xmax)

Return a pseudo-random number uniformly distributed in the
interval [xmin, xmax).
"""
function rand(glc::GLC, xmin, xmax)
    glc.seed = UInt32(glc.a * glc.seed + glc.c)
    xmin + (xmax - xmin) * glc.seed / (2.0^32)
end