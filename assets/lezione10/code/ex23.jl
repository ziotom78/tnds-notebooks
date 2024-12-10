# This file was generated, do not modify it. # hide
glc = GLC(1)
mean_samples = [intmean(glc, xsinx, 0, π / 2, 100) for i in 1:10_000]
histogram(mean_samples, label="Media")

glc = GLC(1)  # Reset the random generator
mean_hm = [inthm(glc, xsinx, 0, π / 2, π / 2, 100) for i in 1:10_000]
histogram!(mean_hm, label="Hit-or-miss");
savefig(joinpath(@OUTPUT, "mc_integrals.svg")); # hide