# This file was generated, do not modify it. # hide
function rungekutta(fn, x, t, h)
    k1 = fn(t, x)
    k2 = fn(t + h / 2.0, x .+ k1 .* h / 2.0)
    k3 = fn(t + h / 2.0, x .+ k2 .* h / 2.0)
    k4 = fn(t + h, x .+ k3 .* h)

    x .+ (k1 .+ 2k2 .+ 2k3 .+ k4) .* h / 6
end