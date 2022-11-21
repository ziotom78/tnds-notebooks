# This file was generated, do not modify it. # hide
errors = compute_errors(simpson, steps)

plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "simpson-error.svg")) # hide