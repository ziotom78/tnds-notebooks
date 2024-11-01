# This file was generated, do not modify it. # hide
plot(steps, compute_errors(midpoint, steps),
     label = "Mid-point",
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi",
     ylabel = "Errore")
plot!(steps, compute_errors(trapezoids, steps),
      label = "Trapezoidi")
plot!(steps, compute_errors(simpson, steps),
      label = "Simpson")

savefig(joinpath(@OUTPUT, "error-comparison.svg")); # hide