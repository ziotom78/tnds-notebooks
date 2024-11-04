# This file was generated, do not modify it. # hide
steps = [10, 20, 50, 100, 200, 500, 1000]
errors = [abs(midpoint(xsinx, 0, pi / 2, n) - 1) for n in steps]

using Plots
plot(steps, errors, xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "midpoint-error.svg")); # hide