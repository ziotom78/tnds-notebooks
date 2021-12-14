# Iniziamo importando i pacchetti che ci serviranno.

using Printf
using Plots
using Statistics

# ## Esercizio 10.1
#
# In Julia non esiste il concetto di «classe», ma esistono le `struct`
# che funzionano in modo concettualmente simile. Non permettono di
# associare metodi, tranne eventualmente un semplice costruttore.
# Definiamo una classe `GLC` che sia equivalente alla classe `Random`
# che vi viene richiesto di implementare in C++.

# ### Generatore Lineare Congruenziale

mutable struct GLC
    a::UInt64
    c::UInt64
    m::UInt64
    seed::UInt64

    GLC(myseed) = new(1664525, 1013904223, 1 << 31, myseed)
end

# Definiamo ora una funzione `rand` che restituisca un numero casuale
# floating-point compreso in un intervallo:

@doc """
    rand(glc::GLC, xmin, xmax)

Return a pseudo-random number uniformly distributed in the
interval [xmin, xmax).
"""
function rand(glc::GLC, xmin, xmax)
    glc.seed = (glc.a * glc.seed + glc.c) % glc.m
    xmin + (xmax - xmin) * glc.seed / glc.m
end

# È molto comodo avere anche una funzione `rand` che usi l'intervallo
# $[0, 1]$.

@doc """
    rand(glc::GLC)

Return a pseudo-random number uniformly distributed in the
interval [0, 1).
"""
rand(glc::GLC) = rand(glc, 0.0, 1.0)

# Le funzioni definite sopra forniscono una guida, definita dalla
# macro `@doc` e invocabile dalla REPL col carattere `?` seguito dal
# nome della funzione:
#
# ```
# julia> ?randgauss
# ```
#
# Questi sono i numeri che dovreste aspettarvi se avete implementato bene il
# vostro codice (notate che i numeri cambiano se usate un seed diverso!).

glc = GLC(1)
for i in 1:5
    println(i, ": ", rand(glc))
end

# Preoccupatevi quindi di creare una serie di `assert` nel vostro
# codice C++ che verifichino che ottenete gli stessi valori se partite
# dallo stesso seme (`1`), possibilmente in una funzione
# `test_random_numbers()` invocata all'inizio del vostro `main`.
#
# Quando si implementano numeri pseudo-casuali, è sempre bene farsi
# un'idea della distribuzione dei valori. Disegnamo quindi
# l'istogramma della distribuzione di un gran numero di campioni, e
# verifichiamo che siano uniformemente distribuiti nell'intervallo [0,
# 1).

histogram([rand(glc) for i in 1:10000], label="")
savefig(joinpath(@OUTPUT, "rand_hist.svg")) # hide

# \fig{rand_hist.svg}

# ### Distribuzione esponenziale
#
# Trattandosi di una formula semplice, in Julia si può definire
# `randexp` con una sola riga di codice:

"""
    randexp(glc::GLC)

Return a positive pseudo-random number distributed with a
probability density ``p(x) = λ e^{-λ x}``.
"""
randexp(glc::GLC, λ) = -log(1 - rand(glc)) / λ

# Questi sono i numeri per i vostri `assert`:

glc = GLC(1)
for i in 1:5
    println(i, ": ", randexp(glc, 1))
end

# Questo è l'istogramma

histogram([randexp(glc, 1) for i in 1:10000], label="")
savefig(joinpath(@OUTPUT, "randexp_hist.svg")) # hide

# \fig{randexp_hist.svg}

# ### Distribuzione Gaussiana

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
    x = sqrt(-2log(1 - s)) * cos(2π * t)
    μ + σ * x
end

# Questi sono i numeri per i vostri `assert`:

glc = GLC(1)
for i in 1:5
    println(i, ": ", randgauss(glc, 2, 1))
end

# Questo è l'istogramma:

histogram([randgauss(glc, 2, 1) for i in 1:10000], label="")
savefig(joinpath(@OUTPUT, "randgauss_hist.svg")) # hide

# \fig{randgauss_hist.svg}

# ### Distribuzione Gaussiana con metodo Accept-Reject

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

# Questi sono i numeri per gli `assert`:

glc = GLC(1)
for i in 1:5
    println(i, ": ", randgauss_ar(glc, 2, 1))
end

# Questo è l'istogramma:

histogram([randgauss_ar(glc, 2, 1) for i in 1:10000], label="")
savefig(joinpath(@OUTPUT, "randgauss_ar_hist.svg")) # hide

# \fig{randgauss_ar_hist.svg}


# ## Esercizio 10.2
#
# Questa è una semplice implementazione dell'integrale della media:

"""
    intmean(glc::GLC, fn, a, b, N)

Evaluate the integral of `fn(x)` in the interval ``[a, b]``
using the mean method with ``N`` points.
"""
function intmean(glc::GLC, fn, a, b, N)
    (b - a) * sum([fn(rand(glc, a, b)) for i in 1:N]) / N
end

# L'integrale *hit-or-miss* è solo lievemente più complicato:

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

# Verifichiamo che il codice compili, e che produca un risultato sensato.
# Teniamo presente che $\int_0^\pi \sin x\,\mathrm{d}x = 2$; inoltre, siccome
# $\sin(x)$ è una funzione limitata in $[0, 1]$, possiamo porre `fmax=1` nella
# chiamata a `inthm`:

println("Integrale (metodo media):", intmean(GLC(1), sin, 0, π, 100))
println("Integrale (metodo hit-or-miss):", inthm(GLC(1), sin, 0, π, 1, 100))

# Implementate degli `assert` che verifichino che ottenete gli stessi
# risultati nella vostra implementazione C++. Come già ricordato
# sopra, fate molta attenzione ad inizializzare il generatore di
# numeri pseudo-casuali con lo stesso seme (`1` in questo caso).
#
# Eseguiamo ora il calcolo per 10.000 volte e facciamone l'istogramma:
# osserviamo che la distribuzione è approssimativamente una Gaussiana,
# come previsto.

glc = GLC(1)
mean_samples = [intmean(glc, sin, 0, π, 100) for i in 1:10_000]
histogram(mean_samples, label="Media")

glc = GLC(1)  # Reset the random generator
mean_hm = [inthm(glc, sin, 0, π, 1, 100) for i in 1:10_000]
histogram!(mean_hm, label="Hit-or-miss")

savefig(joinpath(@OUTPUT, "mc_integrals.svg")) # hide

# \fig{mc_integrals.svg}

# Se l'andamento dell'errore è della forma $\epsilon(N) = k/\sqrt{N}$, con $N$
# numero di punti, allora nel nostro caso possiamo stimare $k$ immediatamente
# dalla deviazione standard dei valori in `values` mediante la formula $k =
# \sqrt{N} \times \epsilon(N)$:

k_mean = √100 * std(mean_samples)
k_hm = √100 * std(mean_hm)

println("K (media) = ", k_mean)
println("K (hit-or-miss) = ", k_hm)

# A questo punto, per rispondere alla domanda del problema, è sufficiente
# risolvere l'equazione $0.001 = k/\sqrt{N}$ per $N$, ossia $$N =
# \left(\frac{k}{0.001}\right)^2$$.

noptim_mean = round(Int, (k_mean/0.001)^2)
noptim_hm = round(Int, (k_hm/0.001)^2)

println("N (media) = ", noptim_mean)
println("N (hit-or-miss) = ", noptim_hm)

# Per verificare la correttezza del risultato, rifacciamo l'istogramma. Siccome
# ci vuole molto tempo per ottenere il risultato, verifichiamo il risultato solo
# nel caso del metodo della media, e per un numero ridotto di realizzazioni
# (1000 anziché 10.000):

glc = GLC(1)
values = [intmean(glc, sin, 0, π, noptim_mean) for i in 1:1000]
histogram(values, label="")
savefig(joinpath(@OUTPUT, "mc_intmean.svg")) # hide

# \fig{mc_intmean.svg}

# Il risultato è effettivamente corretto:

std(values)

# # Lezione 11: Metodi Monte Carlo
#
# ## Esercizio 11.0
#
# Definiamo una serie di variabili per le costanti fisiche del problema:

σ_θ = 0.3e-3;
θ0_ref = π / 2;
Aref = 2.7;
Bref = 60_000e-18;
α = deg2rad(60.0);
λ1 = 579.1e-9;
λ2 = 404.7e-9;

# La funzione `n_cauchy` restituisce $n$ supponendo vera la formula di Cauchy.
# La sintassi con un parametro usa i valori di riferimento di $A$ e $B$ scritti
# sopra.

n_cauchy(λ, A, B) = sqrt(A + B / λ^2)
n_cauchy(λ) = n_cauchy(λ, Aref, Bref)

# La funzione `n` invece restituisce $n$ in funzione della deviazione
# misurata `δ` dal prisma, dove $\alpha$ è il suo angolo di apertura
# (definito sopra).

n(δ) = sin((δ + α) / 2) / sin(α / 2)
δ(n) = 2asin(n * sin(α / 2)) - α

# Queste formule si ricavano banalmente dall'inversione della formula di Cauchy;
# la funzione `A_and_B` calcola contemporaneamente $A$ e $B$, ed è stata
# definita per comodità:

A(λ1, δ1, λ2, δ2) = (λ2^2 * n(δ2)^2 - λ1^2 * n(δ1)^2) / (λ2^2 - λ1^2)
B(λ1, δ1, λ2, δ2) = (n(δ2)^2 - n(δ1)^2) / (1/λ2^2 - 1/λ1^2)
A_and_B(λ1, δ1, λ2, δ2) = (A(λ1, δ1, λ2, δ2), B(λ1, δ1, λ2, δ2))

# Calcoliamo allora i valori di riferimento di $n(\lambda_1) = n_1$ e
# $n(\lambda_2) = n_2$, supponendo veri i valori di $A$ e $B$ scritti sopra
# r(`A_ref` e `B_ref`):

n1_ref, n2_ref = n_cauchy(λ1), n_cauchy(λ2)

# Da $n_1$ e $n_2$ calcoliamo quanto aspettarci per $\delta_1$ e
# $\delta_2$:

δ1_ref, δ2_ref = δ(n1_ref), δ(n2_ref)

# A questo punto possiamo simulare l'esperimento. La simulazione della
# misura di $\delta_1$ e $\delta_2$ va fatta usando l'approssimazione
# Gaussiana con i valori medi `δ1_ref` e `δ2_ref`, e la deviazione
# standard `σ_θ` data dal testo dell'esercizio:

function simulate_experiment(glc, nsim)
    n1_simul = Array{Float64}(undef, nsim)
    n2_simul = Array{Float64}(undef, nsim)

    A_simul = Array{Float64}(undef, nsim)
    B_simul = Array{Float64}(undef, nsim)

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

# Ecco i primi 5 valori della simulazione; controllate che siano gli
# stessi che ottenete voi, facendo attenzione di usare come seme `1` e
# che l'ordine in cui chiamate la funzione per generare i numeri
# casuali sia la stessa del codice sopra:
#
#   1. _Prima_ si genera $\theta_0$;
#   2. _Poi_ si generano $\theta_1$ e $\theta_2$.
#
# Nel fare i plot qui sotto mi limito a ripetere l'esperimento 1000
# volte (il testo richiede 10.000 volte). I risultati non cambiano
# molto.

glc = GLC(1)
n1_simul, n2_simul, A_simul, B_simul = simulate_experiment(glc, 1000)

@printf("%14s %14s %14s %14s\n", "n₁", "n₂", "A", "B")
println(repeat('-', 62))
for i = 1:5
    ## We use scientific notation for B, as it is ≪1
    @printf("%14.6f %14.6f %14.6f %14.6e\n",
            n1_simul[i], n2_simul[i], A_simul[i], B_simul[i])
end

#

histogram([n1_simul, n2_simul],
          label = ["n₁", "n₂"],
          layout = (2, 1))
savefig(joinpath(@OUTPUT, "hist_n1_n2.svg")) # hide

# \fig{hist_n1_n2.svg}

scatter(n1_simul, n2_simul, label="")
savefig(joinpath(@OUTPUT, "scatter_n1_n2.svg")) # hide

# \fig{scatter_n1_n2.svg}

# Il package `Statistics` di Julia implementa il calcolo della
# covarianza tra due serie, che è uguale alla correlazione a meno di
# una normalizzazione. Definiamo quindi la funzione `corr`, che
# calcola il coefficiente di correlazione, analogamente a questa; nel
# vostro codice C++ dovrete invece implementarla usando la formula.

corr(x, y) = cov(x, y) / (std(x) * std(y))

# I valori di $n_1$ ed $n_2$ sono correlati, perché sono entrambi
# stati ricavati dalla medesima stima di $\theta_0$.

corr(n1_simul, n2_simul)

# Dal momento che $B \ll 1$, applichiamo ad esso un fattore di scala
# $10^{14}$:

histogram([A_simul, B_simul * 1e14],
          label = ["A" "B × 10^14"],
          layout = (2, 1))
savefig(joinpath(@OUTPUT, "hist_A_B.svg")) # hide

# \fig{hist_A_B.svg}

#

scatter(A_simul, B_simul * 1e14, label="")
savefig(joinpath(@OUTPUT, "scatter_A_B.svg")) # hide

# \fig{scatter_A_B.svg}

# Ricalcoliamo qui i coefficienti di correlazione nel caso in cui
# l'esperimento sia rifatto 10.000 volte. Notate che creo di nuovo un
# generatore di numeri casuali.

glc = GLC(1)
(n1_simul, n2_simul, A_simul, B_simul) = simulate_experiment(glc, 10_000)
println("Correlazione tra n1 e n2: ", corr(n1_simul, n2_simul))
println("Correlazione tra A e B: ", corr(A_simul, B_simul))

# ## Esercizio 11.1
#
# L'esercizio 11.1 è preso da un vecchio tema d'esame, e va svolto in modo molto
# simile al precedente. Si tratta di misurare il coefficiente di viscosità
# $\eta$ partendo dalla velocità di caduta di una sferetta di metallo
# all'interno di un cilindro pieno di glicerina, tramite la formula $$ v_L =
# \frac{2R^2}{9\eta}(\rho - \rho_0) g = \frac{\Delta x}{\Delta t}, $$ dove
# $\Delta x$ è la lunghezza del tratto percorso in caduta dalla sferetta e
# $\Delta t$ il tempo impiegato. La relazione si inverte facilmente per dare $$
# \eta = \frac{2R^2\,g\,\Delta t}{9\,\Delta x}(\rho - \rho_0), $$ dove le
# quantità misurate in ognuno degli esperimenti Monte Carlo sono $R$, $\Delta x
# = x_1 - x_0$, e $\Delta t$.
#
# Definiamo le costanti numeriche del problema, esprimendole tutte nel S.I.
# (anche `x0`, `x1` e `Δx`!)

δt, δx, δR = 0.01, 0.001, 0.0001
ρ, ρ0 = 2700.0, 1250.0
g = 9.81
η_true = 0.83
R_true = Float64[0.01, 0.005]
x0 = 0.2
x1 = 0.6
Δx_true = x1 - x0

# Definiamo anche alcune relazioni matematiche.

v_L(R, η) = 2R^2 / (9η) * (ρ - ρ0) * g
Δt(R, Δx, η) = Δx / v_L(R, η)
Δt_true = Float64[Δt(R, Δx_true, η_true) for R in R_true]
η(R, Δt, Δx) = 2R^2 * g * Δt / (9Δx) * (ρ - ρ0)

# Definiamo ora la funzione `simulate`, che effettua _due_ esperimenti: uno con
# $R = 0.01\,\text{m}$ e l'altro con $R = 0.005\,\text{m}$.

function simulate(glc::GLC, δx, δt, δR)
    ## Misura dell'altezza iniziale
    cur_x0 = randgauss(glc, x0, δx)
    ## Misura dell'altezza finale
    cur_x1 = randgauss(glc, x1, δx)

    ## Questo array di 2 elementi conterrà le due stime di η
    ## (corrispondenti ai due possibili raggi della sferetta)
    estimated_η = zeros(2)
    for case in [1, 2]
        ## Misura delle dimensioni della sferetta
        cur_R = randgauss(glc, R_true[case], δR)
        cur_Δx = cur_x1 - cur_x0

        ## Misura del tempo necessario per cadere da cur_x0 a cur_x1
        cur_Δt = randgauss(glc, Δt_true[case], δt)

        ## Stima di η
        estimated_η[case] = η(cur_R, cur_Δt, cur_Δx)
    end

    estimated_η
end

# Eseguiamo ora 1000 simulazioni e facciamo l'istogramma della stima di $\eta$
# per i due raggi della sferetta.

N = 1_000
glc = GLC(1)

η1 = Array{Float64}(undef, N)
η2 = Array{Float64}(undef, N)
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, δt, δR)
end

histogram(η2, label=@sprintf("R = %.3f m", R_true[2]))
histogram!(η1, label=@sprintf("R = %.3f m", R_true[1]))
savefig(joinpath(@OUTPUT, "hist_eta1_eta2.svg")) # hide

# \fig{hist_eta1_eta2.svg}

# Si tratta ora di stimare le incertezze di $\eta$ al variare degli errori
# considerati.

## In η1 ed η2 abbiamo già le stime di η considerando tutti
## e tre gli errori
@printf("Tutti gli errori: δη = %.4f kg/m/s (R1)\n", std(η1))
@printf("                     = %.4f kg/m/s (R2)\n", std(η2))

## Ora dobbiamo eseguire di nuovo N esperimenti, assumendo che
## l'errore sia presente in una sola delle tre quantità
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0, 0.0, δR)
end
@printf("Solo δR:          δη = %.4f kg/m/s (R1)\n", std(η1))
@printf("                     = %.4f kg/m/s (R2)\n", std(η2))

## Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0, δt, 0.0)
end
@printf("Solo δt:          δη = %.4f kg/m/s (R1)\n", std(η1))
@printf("                     = %.4f kg/m/s (R2)\n", std(η2))

## Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, 0.0, 0.0)
end
@printf("Solo δx:          δη = %.4f kg/m/s (R1)\n", std(η1))
@printf("                     = %.4f kg/m/s (R2)\n", std(η2))
