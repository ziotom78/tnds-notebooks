# This file was generated, do not modify it. # hide
plot(deltat, error_euler,
     xscale = :log10, yscale = :log10,
     xlabel = "Passo d'integrazione",
     ylabel = @sprintf("Errore a t = %.1f", lastt),
     label = "")
scatter!(deltat, error_euler, label = "")

savefig(joinpath(@OUTPUT, "euler_error.svg")) # hide