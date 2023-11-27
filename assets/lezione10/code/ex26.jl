# This file was generated, do not modify it. # hide
glc = GLC(1)
values = [intmean(glc, sin, 0, π, noptim_mean) for i in 1:1000]
histogram(values, label="");
savefig(joinpath(@OUTPUT, "mc_intmean.svg")); # hide