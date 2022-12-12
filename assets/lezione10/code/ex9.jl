# This file was generated, do not modify it. # hide
histogram([randexp(glc, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randexp_hist.svg")) # hide