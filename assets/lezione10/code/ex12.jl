# This file was generated, do not modify it. # hide
histogram([randgauss(glc, 2, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randgauss_hist.svg")); # hide