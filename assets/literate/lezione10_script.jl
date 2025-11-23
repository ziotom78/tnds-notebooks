# This file was generated, do not modify it.

using Printf
using Plots
using Statistics

mutable struct GLC
    a::UInt32
    c::UInt32
    seed::UInt32

    GLC(myseed) = new(1664525, 1013904223, myseed)
end

@doc """
    rand(glc::GLC, xmin, xmax)

Return a pseudo-random number uniformly distributed in the
interval [xmin, xmax).
"""
function rand(glc::GLC, xmin, xmax)
    glc.seed = UInt32(glc.a * glc.seed + glc.c)
    xmin + (xmax - xmin) * glc.seed / (2.0^32)
end

@doc """
    rand(glc::GLC)

Return a pseudo-random number uniformly distributed in the
interval [0, 1).
"""
rand(glc::GLC) = rand(glc, 0.0, 1.0)

glc = GLC(1)
for i in 1:5
    println(i, ": ", rand(glc))
end

histogram([rand(glc) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "rand_hist.svg")); # hide

"""
    randexp(glc::GLC)

Return a positive pseudo-random number distributed with a
probability density ``p(x) = λ e^{-λ x}``.
"""
randexp(glc::GLC, λ) = -log(1 - rand(glc)) / λ

glc = GLC(1)
for i in 1:5
    println(i, ": ", randexp(glc, 1))
end

histogram([randexp(glc, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randexp_hist.svg")); # hide

@doc raw"""
    randgauss(glc::GLC, μ, σ)

Return a pseudo-random number distributed with a probability
density ``p(x) = \frac{1}{\sqrt{2πσ^2}}
\exp\left(-\frac{(x - μ)^2}{2σ^2}\right)``, using the
Box-Müller algorithm.
"""
function randgauss(glc::GLC, μ, σ)
    s = rand(glc)
    t = rand(glc)
    x = sqrt(-2log(s)) * cos(2π * t)
    μ + σ * x
end

glc = GLC(1)
for i in 1:5
    println(i, ": ", randgauss(glc, 2, 1))
end

histogram([randgauss(glc, 2, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randgauss_hist.svg")); # hide

@doc raw"""
    randgauss_ar(glc::GLC, μ, σ)

Return a pseudo-random number distributed with a probability
density ``p(x) = \frac1{\sqrt{2πσ^2}}
\exp\left(-\frac{(x - μ)^2}{2σ^2}\right)``, using the
accept-reject algorithm.
"""
function randgauss_ar(glc::GLC, μ, σ)
    while true  # Loop forever
        x = rand(glc, -5., 5.)
        y = rand(glc)
        g = exp(-x^2 / 2)
        y ≤ g && return μ + x * σ
    end
end

glc = GLC(1)
for i in 1:5
    println(i, ": ", randgauss_ar(glc, 2, 1))
end

histogram([randgauss_ar(glc, 2, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randgauss_ar_hist.svg")); # hide

function computesums!(glc::GLC, n, vec)
    for i in eachindex(vec)
        accum = 0.0
        for k in 1:n
            accum += rand(glc)
        end
        vec[i] = accum
    end
end

glc = GLC(1)
# Array di *due* elementi
vec = Array{Float64}(undef, 2)
# Chiediamo che in ogni elemento vengano sommati *cinque*
# numeri. Quindi ogni elemento di `vec` sarà un numero
# casuale nell'intervallo 0…5.
computesums!(glc, 5, vec)
println("vec[1] = ", vec[1])
println("vec[2] = ", vec[2])

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

plot(list_of_N, list_of_sigmas,
     xaxis = :log10, yaxis = :log10, label = "",
     xlabel = "N", ylabel = "Standard deviation σ")
savefig(joinpath(@OUTPUT, "es10_1_std.svg")); # hide

"""
    intmean(glc::GLC, fn, a, b, N)

Evaluate the integral of `fn(x)` in the interval ``[a, b]``
using the mean method with ``N`` points.
"""
function intmean(glc::GLC, fn, a, b, N)
    (b - a) * sum([fn(rand(glc, a, b)) for i in 1:N]) / N
end

"""
    inthm(glc::GLC, fn, a, b, fmax, N)

Evaluate the integral of `fn(x)` in the interval ``[a, b]``
using the hit-or-miss method with ``N`` points, assuming that
`fn(x)` assumes values in the range `[0, fmax]`.
"""
function inthm(glc::GLC, fn, a, b, fmax, N)
    hits = 0
    for i in 1:N
        x = rand(glc, a, b)
        y = rand(glc, 0, fmax)
        y ≤ fn(x) && (hits += 1)
    end

    hits / N * (b - a) * fmax
end

xsinx(x) = x * sin(x)
println("Integrale (metodo media):", intmean(GLC(1), xsinx, 0, π/2, 100))
println("Integrale (metodo hit-or-miss):", inthm(GLC(1), xsinx, 0, π/2, π/2, 100))

glc = GLC(1)  # Reset the random generator
mean_hm = [inthm(glc, xsinx, 0, π / 2, π / 2, 100) for i in 1:10_000]
histogram(mean_hm, label="Hit-or-miss");

glc = GLC(1)
mean_samples = [intmean(glc, xsinx, 0, π / 2, 100) for i in 1:10_000]
histogram!(mean_samples, label="Media")

savefig(joinpath(@OUTPUT, "mc_integrals.svg")); # hide

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

scatter(
    list_of_N,
    list_of_errors,
    xlabel = "N",
    ylabel = "Errore",
    xaxis = :log10,
    yaxis = :log10,
)
savefig(joinpath(@OUTPUT, "mc_integrals_err_plot.svg")); # hide

println("N       Errore")
for (cur_n, cur_err) in zip(list_of_N, list_of_errors)
    @printf("%d\t%.5f\n", cur_n, cur_err)
end

k_mean = √100 * std(mean_samples)
k_hm = √100 * std(mean_hm)

println("K (media) = ", k_mean)
println("K (hit-or-miss) = ", k_hm)

target_ε = 0.001
noptim_mean = round(Int, (k_mean / target_ε)^2)
noptim_hm = round(Int, (k_hm / target_ε)^2)

println("N (media) = ", noptim_mean)
println("N (hit-or-miss) = ", noptim_hm)

glc = GLC(1)
values = [intmean(glc, xsinx, 0, π / 2, noptim_mean) for i in 1:1000]
histogram(values, label="");
savefig(joinpath(@OUTPUT, "mc_intmean.svg")); # hide

std(values)

using Unitful
import Unitful: m, cm, mm, nm, s, °, mrad, @u_str

σ_θ = 0.3mrad;       # Avrei potuto scrivere σ_θ = 0.3u"mrad"
θ0_ref = 90°;        # Ugualmente,           θ0_ref = 90u"°"
Aref = 2.7;
Bref = 6e4u"nm^2";   # Qui devo usare `u` perché nm² è troppo complicato
α = 60.0°;
λ1 = 579.1nm;
λ2 = 404.7nm;

n_cauchy(λ, A, B) = sqrt(A + B / λ^2)
n_cauchy(λ) = n_cauchy(λ, Aref, Bref)

n(δ) = sin((δ + α) / 2) / sin(α / 2)
δ(n) = uconvert(u"°", 2asin(n * sin(α / 2)) - α)

A(λ1, δ1, λ2, δ2) = (λ2^2 * n(δ2)^2 - λ1^2 * n(δ1)^2) / (λ2^2 - λ1^2)
B(λ1, δ1, λ2, δ2) = (n(δ2)^2 - n(δ1)^2) / (1/λ2^2 - 1/λ1^2)
A_and_B(λ1, δ1, λ2, δ2) = (A(λ1, δ1, λ2, δ2), B(λ1, δ1, λ2, δ2))

n1_ref, n2_ref = n_cauchy(λ1), n_cauchy(λ2)

δ1_ref, δ2_ref = δ(n1_ref), δ(n2_ref)

println("δ1_ref = ", uconvert(u"rad", δ1_ref))
println("δ2_ref = ", uconvert(u"rad", δ2_ref))

function simulate_experiment(glc, nsim)
    n1_simul = Array{Float64}(undef, nsim)
    n2_simul = Array{Float64}(undef, nsim)

    A_simul = Array{Float64}(undef, nsim)
    # Here I create an array of values whose measurement unit
    # must be the same as `Bref`
    B_simul = Array{typeof(Bref)}(undef, nsim)

    for i in 1:nsim
        θ0 = randgauss(glc, θ0_ref, σ_θ)
        θ1 = randgauss(glc, θ0_ref + δ1_ref, σ_θ)
        θ2 = randgauss(glc, θ0_ref + δ2_ref, σ_θ)
        δ1, δ2 = θ1 - θ0, θ2 - θ0
        n1, n2 = n(δ1), n(δ2)
        a, b = A_and_B(λ1, δ1, λ2, δ2)

        n1_simul[i] = n1
        n2_simul[i] = n2

        A_simul[i] = a
        B_simul[i] = b
    end

    (n1_simul, n2_simul, A_simul, B_simul)
end

glc = GLC(1)
n1_simul, n2_simul, A_simul, B_simul = simulate_experiment(glc, 1000)

@printf("%14s %14s %14s %14s\n", "n₁", "n₂", "A", "B [nm²]")
println(repeat('-', 62))
for i = 1:5
    # We use scientific notation for B, as it is ≪1. As we want to
    # avoid printing units for B (they are already in the table header),
    # we just «strip» nm² from it.
    @printf("%14.6f %14.6f %14.6f %14.6e\n",
            n1_simul[i], n2_simul[i], A_simul[i], ustrip(u"nm^2", B_simul[i]))
end

histogram([n1_simul, n2_simul],
          label = ["n₁" "n₂"],
          layout = (2, 1));
savefig(joinpath(@OUTPUT, "hist_n1_n2.svg")); # hide

scatter(n1_simul, n2_simul, label="");
savefig(joinpath(@OUTPUT, "scatter_n1_n2.svg")); # hide

corr(x, y) = cov(x, y) / (std(x) * std(y))

corr(n1_simul, n2_simul)

histogram([A_simul, ustrip.(u"nm^2", B_simul)],
          label = ["A" "B"],
          layout = (2, 1))
savefig(joinpath(@OUTPUT, "hist_A_B.svg")); # hide

scatter(A_simul, B_simul, label="");
savefig(joinpath(@OUTPUT, "scatter_A_B.svg")); # hide

glc = GLC(1)
(n1_simul, n2_simul, A_simul, B_simul) = simulate_experiment(glc, 10_000)
println("Correlazione tra n1 e n2: ", corr(n1_simul, n2_simul))
println("Correlazione tra A e B: ", corr(A_simul, B_simul))

δt, δx, δR = 0.01s, 0.001m, 0.0001m;
ρ, ρ0 = 2700.0u"kg/m^3", 1250.0u"kg/m^3";
g = 9.81u"m/s^2";
η_true = 0.83u"kg/m/s";
R_true = [0.01m, 0.005m];
x0 = 20cm;
x1 = 60cm;
Δx_true = x1 - x0;

v_L(R, η) = 2R^2 / (9η) * (ρ - ρ0) * g;
Δt(R, Δx, η) = Δx / v_L(R, η);
Δt_true = [Δt(R, Δx_true, η_true) for R in R_true];
η(R, Δt, Δx) = 2R^2 * g * Δt / (9Δx) * (ρ - ρ0);

function simulate(glc::GLC, δx, δt, δR)
    # Misura dell'altezza iniziale
    cur_x0 = randgauss(glc, x0, δx)
    # Misura dell'altezza finale
    cur_x1 = randgauss(glc, x1, δx)

    # Questo array di 2 elementi conterrà le due stime di η
    # (corrispondenti ai due possibili raggi della sferetta)
    estimated_η = zeros(typeof(η_true), 2)
    for case in [1, 2]
        # Misura delle dimensioni della sferetta
        cur_R = randgauss(glc, R_true[case], δR)
        cur_Δx = cur_x1 - cur_x0

        # Misura del tempo necessario per cadere da cur_x0 a cur_x1
        cur_Δt = randgauss(glc, Δt_true[case], δt)

        # Stima di η
        estimated_η[case] = η(cur_R, cur_Δt, cur_Δx)
    end

    estimated_η
end

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

# In η1 ed η2 abbiamo già le stime di η considerando tutti
# e tre gli errori
println("Tutti gli errori: δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

# Ora dobbiamo eseguire di nuovo N esperimenti, assumendo che
# l'errore sia presente in una sola delle tre quantità
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0m, 0.0s, δR)
end
println("Solo δR:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

# Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0m, δt, 0.0m)
end
println("Solo δt:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

# Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, 0.0s, 0.0m)
end
println("Solo δx:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))
