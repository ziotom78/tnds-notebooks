# This file was generated, do not modify it. # hide
glc = GLC(1)
n1_simul, n2_simul, A_simul, B_simul = simulate_experiment(glc, 1000)

@printf("%14s %14s %14s %14s\n", "n₁", "n₂", "A", "B [nm²]")
println(repeat('-', 62))
for i = 1:5
    # We use scientific notation for B, as it is ≪1. As we want to
    # avoid printing units for B (they are already in the table header),
    # we just «strip» nm² from it.
    @printf("%14.6f %14.6f %14.6f %14.6e\n",
            n1_simul[i], n2_simul[i], A_simul[i], ustrip(u"nm^2", B_simul[i]))
end