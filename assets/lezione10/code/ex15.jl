# This file was generated, do not modify it. # hide
histogram([randgauss_ar(glc, 2, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randgauss_ar_hist.svg")); # hide