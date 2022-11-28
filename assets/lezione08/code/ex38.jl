# This file was generated, do not modify it. # hide
function search_inversion(vect)
    prevval = vect[1]
    for i in 2:length(vect)
        # Qui usiamo lo stesso trucco per trovare un cambio di segno
        # che avevamo già impiegato negli esercizi per la ricerca
        # degli zeri
        if sign(prevval) * sign(vect[i]) < 0
            return i - 1
        end
        prevval = vect[i]
    end

    println("No inversion found, run the simulation for a longer time")

    # Restituisci un indice negativo (impossibile), perché non
    # abbiamo trovato alcuna inversione.
    -1
end