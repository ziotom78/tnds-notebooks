# This file was generated, do not modify it. # hide
list_of_N = [500, 1_000, 5_000, 10_000, 50_000, 100_000]
list_of_plots = []
list_of_errors = []
for N in list_of_N
    let samples = [intmean(glc, xsinx, 0, π / 2, N) for i in 1:10_000]
        push!(list_of_plots, histogram(samples, label="N = $N"))
        push!(list_of_errors, std(samples))
    end
end
plot(list_of_plots..., layout=(3, 2), legend=false);
savefig(joinpath(@OUTPUT, "mc_integrals_varying_N.svg")); # hide