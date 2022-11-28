# This file was generated, do not modify it. # hide
oscillations = forcedpendulum(8.)
plot(oscillations[:, 1], oscillations[:, 2], label="")

savefig(joinpath(@OUTPUT, "forced-pendulum.svg")) # hide