# This file was generated, do not modify it. # hide
"""
    intmean(glc::GLC, fn, a, b, N)

Evaluate the integral of `fn(x)` in the interval ``[a, b]``
using the mean method with ``N`` points.
"""
function intmean(glc::GLC, fn, a, b, N)
    (b - a) * sum([fn(rand(glc, a, b)) for i in 1:N]) / N
end