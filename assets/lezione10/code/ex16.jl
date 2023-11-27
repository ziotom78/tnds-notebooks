# This file was generated, do not modify it. # hide
function computesums!(glc::GLC, n, vec)
    for i in eachindex(vec)
        accum = 0.0
        for k in 1:n
            accum += rand(glc)
        end
        vec[i] = accum
    end
end