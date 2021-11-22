# This file was generated, do not modify it. # hide
function search_inversion(vect)
    prevval = vect[1]
    for i in 2:length(vect)
        if prevval * vect[i] < 0
            return i - 1
        end
        prevval = vect[i]
    end

    println("No inversion found, run the simulation for a longer time")

    # Return a negative (impossible) index
    -1
end