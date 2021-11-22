# This file was generated, do not modify it. # hide
function invtime(time, vec)
    idx = search_inversion(vec)
    timeA, timeB = time[idx:idx + 1]
    vecA, vecB = vec[idx:idx + 1]

    abs(interp((timeA, vecA), (timeB, vecB)))
end