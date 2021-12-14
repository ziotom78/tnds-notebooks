# This file was generated, do not modify it. # hide
# In η1 ed η2 abbiamo già le stime di η considerando tutti
# e tre gli errori
@printf("Tutti gli errori: δη = %.4f kg/m/s (R1)\n", std(η1))
@printf("                     = %.4f kg/m/s (R2)\n", std(η2))

# Ora dobbiamo eseguire di nuovo N esperimenti, assumendo che
# l'errore sia presente in una sola delle tre quantità
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0, 0.0, δR)
end
@printf("Solo δR:          δη = %.4f kg/m/s (R1)\n", std(η1))
@printf("                     = %.4f kg/m/s (R2)\n", std(η2))

# Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0, δt, 0.0)
end
@printf("Solo δt:          δη = %.4f kg/m/s (R1)\n", std(η1))
@printf("                     = %.4f kg/m/s (R2)\n", std(η2))

# Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, 0.0, 0.0)
end
@printf("Solo δx:          δη = %.4f kg/m/s (R1)\n", std(η1))
@printf("                     = %.4f kg/m/s (R2)\n", std(η2))