# This file was generated, do not modify it. # hide
function euler(fn, x0, startt, endt, h)
    # La scrittura startt:h:endt indica il vettore
    #
    #     [startt, startt + h, startt + 2h, startt + 3h, …, startt + N * h]
    #
    # dove N è il più grande intero tale che
    #
    #     startt + N * h ≤ endt
    timerange = startt:h:endt
    result = Array{Float64}(undef, length(timerange), 1 + length(x0))
    cur = x0
    for (i, t) in enumerate(timerange)
        result[i, 1] = t
        result[i, 2:end] = cur
        cur .+= fn(t, cur) * h
    end

    result
end