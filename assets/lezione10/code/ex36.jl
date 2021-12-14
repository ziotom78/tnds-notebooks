# This file was generated, do not modify it. # hide
histogram([A_simul, B_simul * 1e14],
          label = ["A" "B × 10^14"],
          layout = (2, 1))
savefig(joinpath(@OUTPUT, "hist_A_B.svg")) # hide