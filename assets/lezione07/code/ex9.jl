# This file was generated, do not modify it. # hide
steps = [10, 50, 100, 500, 1000]
errors = [abs(midpoint(sin, 0, pi, n) - 2) for n in steps]

plot(steps, errors, xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "midpoint-error.svg")); # hide