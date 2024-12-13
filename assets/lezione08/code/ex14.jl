# This file was generated, do not modify it. # hide
function euler_simulation(x0, t0, tf, h)
    # Calcola il numero di iterazioni prima di iniziare il ciclo vero
    # e proprio
    nsteps = num_of_steps(t0, tf, h)

    # I tre vettori hanno `N + 1` elementi e non `N`, perché vogliamo
    # memorizzare anche la condizione iniziale.
    times = zeros(Float64, nsteps + 1)
    pos = zeros(Float64, nsteps + 1)
    vel = zeros(Float64, nsteps + 1)

    # Salviamo la condizione iniziale
    times[1] = t0
    pos[1] = x0[1]
    vel[1] = x0[2]

    t = t0
    x = x0
    for i = 1:nsteps
        x = euler(oscillatore, x, t, h)
        t += h

        times[i + 1] = t
        pos[i + 1] = x[1]
        vel[i + 1] = x[2]
    end

    # Contrariamente al C++, una funzione Julia può restituire
    # più di un valore
    return (times, pos, vel)
end

times, pos, vel = euler_simulation([0.0, 1.0], 0.0, lastt, 0.1);