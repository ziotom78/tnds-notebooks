# This file was generated, do not modify it. # hide
euler(fn, x, t, h) = x .+ fn(t, x) .* h