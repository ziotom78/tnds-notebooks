# This file was generated, do not modify it. # hide
histogram([rand(glc) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "rand_hist.svg")) # hide