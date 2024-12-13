# This file was generated, do not modify it. # hide
function simulate_method2(t0, tf, h)
    println("Inizia la simulazione, da t=$t0 a $tf con h=$h")

    # Calcola il numero di iterazioni prima di iniziare il ciclo vero
    # e proprio
    nsteps = num_of_steps(t0, tf, h)
    t = t0
    for i = 1:nsteps
        println("  t = $t")
        # Ricalcola t partendo da t0 e da h, usando il contatore i
        t = t0 + i * h
    end
    println("Simulazione terminata a t = $t")
end

simulate_method2(0, 1, 0.1)