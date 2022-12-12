# This file was generated, do not modify it. # hide
N = 1_000
glc = GLC(1)

η1 = Array{Float64}(undef, N)
η2 = Array{Float64}(undef, N)
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, δt, δR)
end

histogram(η2, label=@sprintf("R = %.3f m", R_true[2]))
histogram!(η1, label=@sprintf("R = %.3f m", R_true[1]));
savefig(joinpath(@OUTPUT, "hist_eta1_eta2.svg")) # hide