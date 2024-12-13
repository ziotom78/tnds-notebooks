# This file was generated, do not modify it. # hide
function period(θ₀; h = 0.01)
    # Simuliamo finché ω non diventa negativa

    x = [θ₀, 0.]
    oldx = [0., 0.]
    t = 0.0
    while x[2] ≤ 0
        oldx = x  # Ci serve poi per fare l'interpolazione
        x = rungekutta(pendulum, x, t, h)
        t += h
    end

    # A questo punto, t è un po' più di un semiperiodo.

    # Calcoliamo mediante interpolazione l'istante in cui
    # si è avuto ω=0
    t_semip = interp((t - h, oldx[2]), (t, x[2]))

    # Il periodo è due volte il semiperiodo
    return 2t_semip
end