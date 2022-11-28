# This file was generated, do not modify it. # hide
scatter(oscillations[:, 1], oscillations[:, 3],
        label = "",
        xlim = (1.0, 1.2),
        xlabel = "Tempo [s]",
        ylabel = "Velocità angolare [rad/s]")

savefig(joinpath(@OUTPUT, "oscillations2.svg")) # hide