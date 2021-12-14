# This file was generated, do not modify it. # hide
glc = GLC(1)
n1_simul, n2_simul, A_simul, B_simul = simulate_experiment(glc, 1000)

@printf("%14s %14s %14s %14s\n", "n₁", "n₂", "A", "B")
println(repeat('-', 62))
for i = 1:5
    # We use scientific notation for B, as it is ≪1
    @printf("%14.6f %14.6f %14.6f %14.6e\n",
            n1_simul[i], n2_simul[i], A_simul[i], B_simul[i])
end