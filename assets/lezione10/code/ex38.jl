# This file was generated, do not modify it. # hide
glc = GLC(1)
(n1_simul, n2_simul, A_simul, B_simul) = simulate_experiment(glc, 10_000)
println("Correlazione tra n1 e n2: ", corr(n1_simul, n2_simul))
println("Correlazione tra A e B: ", corr(A_simul, B_simul))