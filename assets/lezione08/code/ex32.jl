# This file was generated, do not modify it. # hide
plot(deltat, error_euler, label = "");
scatter!(deltat, error_euler, label = "Eulero");

plot!(deltat, error_rk,
     xscale = :log10, yscale = :log10,
     xlabel = "Passo d'integrazione",
     ylabel = @sprintf("Errore a t = %.1f", lastt),
     label = "");
scatter!(deltat, error_rk, label = "Runge-Kutta");
savefig(joinpath(@OUTPUT, "euler_rk_comparison.svg")); # hide