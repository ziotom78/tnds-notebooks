# This file was generated, do not modify it. # hide
scatter(
    list_of_N,
    list_of_errors,
    xlabel = "N",
    ylabel = "Errore",
    xaxis = :log10,
    yaxis = :log10,
)
savefig(joinpath(@OUTPUT, "mc_integrals_err_plot.svg")); # hide