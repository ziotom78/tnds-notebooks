# This file was generated, do not modify it. # hide
function forced_pendulum_amplitude(ω)
    # In Julia posso assegnare a una variabile la definizione di una
    # funzione!
    fn = (time, x) -> forcedpendulum(time, x, ω)

    # Step 1: lascio che la simulazione proceda finché l'oscillatore
    # non si stabilizza

    x = [0., 0.]
    t = 0.0

    while t < 15 / α
        x = rungekutta(fn, x, t, h)
        t += h
    end

    # Step 2: continuo a simulare finché il segno della velocità non
    # si inverte

    oldx = [0., 0.]
    while true
        oldx = x
        x = rungekutta(fn, x, t, h)
        t += h

        if x[2] * oldx[2] < 0
            break
        end
    end

    # Step 3: eseguo una interpolazione per sapere di quanto
    # “arretrare” col tempo. Dovrà essere per forza h_new < 0

    h_new = interp((-h, oldx[2]), (0, x[2]))
    @assert h_new < 0

    x = rungekutta(fn, x, t, h_new)

    # Devo usare `abs`: non so a priori se l'oscillatore è a destra o
    # a sinistra dello zero
    return abs(x[1])
end