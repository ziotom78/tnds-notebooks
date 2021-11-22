# This file was generated, do not modify it. # hide
function rungekutta(fn, x0, startt, endt, h)
    timerange = startt:h:endt
    result = Array{Float64}(undef, length(timerange), 1 + length(x0))
    cur = copy(x0)
    for (i, t) in enumerate(timerange)
        result[i, 1] = t
        result[i, 2:end] = cur

        k1 = fn(t,          cur)
        k2 = fn(t + h / 2., cur .+ k1 .* h / 2.0)
        k3 = fn(t + h / 2., cur .+ k2 .* h / 2.0)
        k4 = fn(t + h,      cur .+ k3 .* h)

        cur .+= (k1 .+ 2k2 .+ 2k3 .+ k4) .* h / 6
    end

    result
end