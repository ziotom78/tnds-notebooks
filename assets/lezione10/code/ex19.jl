# This file was generated, do not modify it. # hide
plot(list_of_N, list_of_sigmas,
     xaxis = :log10, yaxis = :log10, label = "",
     xlabel = "N", ylabel = "Standard deviation σ")
savefig(joinpath(@OUTPUT, "es10_1_std.svg")); # hide