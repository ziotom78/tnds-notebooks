# This file was generated, do not modify it. # hide
xsinx(x) = x * sin(x)
println("Integrale (metodo media):", intmean(GLC(1), xsinx, 0, π/2, 100))
println("Integrale (metodo hit-or-miss):", inthm(GLC(1), xsinx, 0, π/2, 1, 100))