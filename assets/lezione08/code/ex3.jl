# This file was generated, do not modify it. # hide
function simulate(t0, tf, h)
    t = t0

    println("Inizia la simulazione, da t=$t0 a $tf con h=$h")

    # Itera finché non abbiamo raggiunto il tempo finale
    while t < tf
        println("  t = $t")
        t += h
    end

    println("Simulazione terminata a t = $t")
end

simulate(0.0, 1.0, 0.1)