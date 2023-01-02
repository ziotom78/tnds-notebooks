# This file was generated, do not modify it. # hide
# In η1 ed η2 abbiamo già le stime di η considerando tutti
# e tre gli errori
println("Tutti gli errori: δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

# Ora dobbiamo eseguire di nuovo N esperimenti, assumendo che
# l'errore sia presente in una sola delle tre quantità
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0m, 0.0s, δR)
end
println("Solo δR:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

# Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0m, δt, 0.0m)
end
println("Solo δt:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

# Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, 0.0s, 0.0m)
end
println("Solo δx:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))