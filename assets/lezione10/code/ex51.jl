# This file was generated, do not modify it. # hide
N = 1_000
glc = GLC(1)

η1 = Array{typeof(η_true)}(undef, N)
η2 = Array{typeof(η_true)}(undef, N)
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, δt, δR)
end

histogram(η2, label="R = $(R_true[2])")
histogram!(η1, label="R = $(R_true[1])");
savefig(joinpath(@OUTPUT, "hist_eta1_eta2.svg")); # hide