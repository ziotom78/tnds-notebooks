# This file was generated, do not modify it. # hide
# Esegue per `nruns` volte l'incremento `increment`, partendo da
# `start`
function simulate(nruns, start, increment)
    t = start
    for i in 1:nruns
        t += increment
    end
    println("Incrementando di $increment per $nruns volte, il risultato è $t")
end

simulate(10, 0, h)