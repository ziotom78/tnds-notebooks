# This file was generated, do not modify it. # hide
target_ε = 0.001
noptim_mean = round(Int, (k_mean / target_ε)^2)
noptim_hm = round(Int, (k_hm / target_ε)^2)

println("N (media) = ", noptim_mean)
println("N (hit-or-miss) = ", noptim_hm)