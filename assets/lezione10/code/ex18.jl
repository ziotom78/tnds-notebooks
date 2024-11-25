# This file was generated, do not modify it. # hide
glc = GLC(1)
vec = Array{Float64}(undef, 100_000)

list_of_N = 1:12
list_of_histograms = []
list_of_sigmas = Float64[]
for n in list_of_N
    computesums!(glc, n, vec)
    push!(list_of_histograms, histogram(vec, bins = 20, title = "N = $n"))
    push!(list_of_sigmas, std(vec))
end
plot(
    list_of_histograms...,
    layout = (3, 4),
    size = (900, 600),
    legend = false,
)
savefig(joinpath(@OUTPUT, "es10_1_histogram.svg")); # hide