# This file was generated, do not modify it. # hide
histogram([A_simul, ustrip.(u"nm^2", B_simul)],
          label = ["A" "B"],
          layout = (2, 1))
savefig(joinpath(@OUTPUT, "hist_A_B.svg")); # hide