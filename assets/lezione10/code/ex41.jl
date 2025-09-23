# This file was generated, do not modify it. # hide
histogram([n1_simul, n2_simul],
          label = ["n₁" "n₂"],
          layout = (2, 1));
savefig(joinpath(@OUTPUT, "hist_n1_n2.svg")); # hide