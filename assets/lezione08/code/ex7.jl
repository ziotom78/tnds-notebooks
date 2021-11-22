# This file was generated, do not modify it. # hide
function simulate_method2(t0, tf, increment)
    println("Inizia la simulazione, da t = $t0 a t = $tf in passi di $increment")

    # Calcola il numero di iterazioni prima di iniziare il ciclo vero e proprio
    nsteps = round(Int, (tf - t0) / h)
    t = t0
    for i = 1:nsteps
        println("  t = $t")
        t = t0 + i * h
    end
    println("Simulazione terminata a t = $t")
end

simulate_method2(0, 1, 0.1)