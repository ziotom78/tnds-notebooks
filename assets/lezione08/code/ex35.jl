# This file was generated, do not modify it. # hide
plot(oscillations[:, 1], oscillations[:, 3],
     label = "",
     xlabel = "Tempo [s]",
     ylabel = "Velocità angolare [rad/s]")

savefig(joinpath(@OUTPUT, "oscillations1.svg")) # hide