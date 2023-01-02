<!--This file was generated, do not modify it.-->
# Metodi Monte Carlo (Lezioni 10 e 11)

## Lezione 10

Iniziamo importando i pacchetti che ci serviranno.

````julia:ex1
using Printf
using Plots
using Statistics
````

### Esercizio 10.1

In Julia non esiste il concetto di «classe», ma esistono le `struct`
che funzionano in modo concettualmente simile. Non permettono di
associare metodi, tranne eventualmente un semplice costruttore, e
tutti i campi sono pubblici di default.

Definiamo una classe `GLC` che sia equivalente alla classe `Random`
che vi viene richiesto di implementare in C++.

#### Generatore Lineare Congruenziale

````julia:ex2
mutable struct GLC
    a::UInt64
    c::UInt64
    m::UInt64
    seed::UInt64

    GLC(myseed) = new(1664525, 1013904223, 1 << 31, myseed)
end
````

Definiamo ora una funzione `rand` che restituisca un numero casuale
floating-point compreso in un intervallo:

````julia:ex3
@doc """
    rand(glc::GLC, xmin, xmax)

Return a pseudo-random number uniformly distributed in the
interval [xmin, xmax).
"""
function rand(glc::GLC, xmin, xmax)
    glc.seed = (glc.a * glc.seed + glc.c) % glc.m
    xmin + (xmax - xmin) * glc.seed / glc.m
end
````

È molto comodo avere anche una funzione `rand` che usi l'intervallo
$[0, 1]$.

````julia:ex4
@doc """
    rand(glc::GLC)

Return a pseudo-random number uniformly distributed in the
interval [0, 1).
"""
rand(glc::GLC) = rand(glc, 0.0, 1.0)
````

Le funzioni definite sopra forniscono una guida, definita dalla
macro `@doc` e invocabile dalla REPL col carattere `?` seguito dal
nome della funzione:

```
julia> ?randgauss
```

Questi sono i numeri che dovreste aspettarvi se avete implementato bene il
vostro codice (notate che i numeri cambiano se usate un seed diverso!).

````julia:ex5
glc = GLC(1)
for i in 1:5
    println(i, ": ", rand(glc))
end
````

Preoccupatevi quindi di creare una serie di `assert` nel vostro
codice C++ che verifichino che ottenete gli stessi valori se partite
dallo stesso seme (`1`), possibilmente in una funzione
`test_random_numbers()` invocata all'inizio del vostro `main`.

Quando si implementano numeri pseudo-casuali, è sempre bene farsi
un'idea della distribuzione dei valori. Disegnamo quindi
l'istogramma della distribuzione di un gran numero di campioni, e
verifichiamo che siano uniformemente distribuiti nell'intervallo [0,
1).

````julia:ex6
histogram([rand(glc) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "rand_hist.svg")); # hide
````

\fig{rand_hist.svg}

#### Distribuzione esponenziale

Trattandosi di una formula semplice, in Julia si può definire
`randexp` con una sola riga di codice:

````julia:ex7
"""
    randexp(glc::GLC)

Return a positive pseudo-random number distributed with a
probability density ``p(x) = λ e^{-λ x}``.
"""
randexp(glc::GLC, λ) = -log(1 - rand(glc)) / λ
````

Questi sono i numeri per i vostri `assert`:

````julia:ex8
glc = GLC(1)
for i in 1:5
    println(i, ": ", randexp(glc, 1))
end
````

Questo è l'istogramma

````julia:ex9
histogram([randexp(glc, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randexp_hist.svg")); # hide
````

\fig{randexp_hist.svg}

#### Distribuzione Gaussiana

````julia:ex10
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
````

Questi sono i numeri per i vostri `assert`:

````julia:ex11
glc = GLC(1)
for i in 1:5
    println(i, ": ", randgauss(glc, 2, 1))
end
````

Questo è l'istogramma:

````julia:ex12
histogram([randgauss(glc, 2, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randgauss_hist.svg")); # hide
````

\fig{randgauss_hist.svg}

#### Distribuzione Gaussiana con metodo Accept-Reject

````julia:ex13
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
````

Questi sono i numeri per gli `assert`:

````julia:ex14
glc = GLC(1)
for i in 1:5
    println(i, ": ", randgauss_ar(glc, 2, 1))
end
````

Questo è l'istogramma:

````julia:ex15
histogram([randgauss_ar(glc, 2, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randgauss_ar_hist.svg")); # hide
````

\fig{randgauss_ar_hist.svg}

### Esercizio 10.2

Questa è una semplice implementazione dell'integrale della media:

````julia:ex16
"""
    intmean(glc::GLC, fn, a, b, N)

Evaluate the integral of `fn(x)` in the interval ``[a, b]``
using the mean method with ``N`` points.
"""
function intmean(glc::GLC, fn, a, b, N)
    (b - a) * sum([fn(rand(glc, a, b)) for i in 1:N]) / N
end
````

L'integrale *hit-or-miss* è solo lievemente più complicato:

````julia:ex17
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
````

Verifichiamo che il codice compili, e che produca un risultato sensato.
Teniamo presente che $\int_0^\pi \sin x\,\mathrm{d}x = 2$; inoltre, siccome
$\sin(x)$ è una funzione limitata in $[0, 1]$, possiamo porre `fmax=1` nella
chiamata a `inthm`:

````julia:ex18
println("Integrale (metodo media):", intmean(GLC(1), sin, 0, π, 100))
println("Integrale (metodo hit-or-miss):", inthm(GLC(1), sin, 0, π, 1, 100))
````

Implementate degli `assert` che verifichino che ottenete gli stessi
risultati nella vostra implementazione C++. Come già ricordato
sopra, fate molta attenzione ad inizializzare il generatore di
numeri pseudo-casuali con lo stesso seme (`1` in questo caso).

Eseguiamo ora il calcolo per 10.000 volte e facciamone l'istogramma:
osserviamo che la distribuzione è approssimativamente una Gaussiana,
come previsto.

````julia:ex19
glc = GLC(1)
mean_samples = [intmean(glc, sin, 0, π, 100) for i in 1:10_000]
histogram(mean_samples, label="Media")

glc = GLC(1)  # Reset the random generator
mean_hm = [inthm(glc, sin, 0, π, 1, 100) for i in 1:10_000]
histogram!(mean_hm, label="Hit-or-miss");
savefig(joinpath(@OUTPUT, "mc_integrals.svg")); # hide
````

\fig{mc_integrals.svg}

Se l'andamento dell'errore è della forma $\epsilon(N) = k/\sqrt{N}$, con $N$
numero di punti, allora nel nostro caso possiamo stimare $k$ immediatamente
dalla deviazione standard dei valori in `values` mediante la formula $k =
\sqrt{N} \times \epsilon(N)$:

````julia:ex20
k_mean = √100 * std(mean_samples)
k_hm = √100 * std(mean_hm)

println("K (media) = ", k_mean)
println("K (hit-or-miss) = ", k_hm)
````

A questo punto, per rispondere alla domanda del problema, è sufficiente
risolvere l'equazione $0.001 = k/\sqrt{N}$ per $N$, ossia $$N =
\left(\frac{k}{0.001}\right)^2$$.

````julia:ex21
noptim_mean = round(Int, (k_mean/0.001)^2)
noptim_hm = round(Int, (k_hm/0.001)^2)

println("N (media) = ", noptim_mean)
println("N (hit-or-miss) = ", noptim_hm)
````

Per verificare la correttezza del risultato, rifacciamo l'istogramma. Siccome
ci vuole molto tempo per ottenere il risultato, verifichiamo il risultato solo
nel caso del metodo della media, e per un numero ridotto di realizzazioni
(1000 anziché 10.000):

````julia:ex22
glc = GLC(1)
values = [intmean(glc, sin, 0, π, noptim_mean) for i in 1:1000]
histogram(values, label="");
savefig(joinpath(@OUTPUT, "mc_intmean.svg")); # hide
````

\fig{mc_intmean.svg}

Il risultato è effettivamente corretto:

````julia:ex23
std(values)
````

## Lezione 11: Metodi Monte Carlo

L'esercizio di questa lezione è **estremamente** importante, perché
le tecniche Monte Carlo sono molto diffuse in fisica. (E inoltre
questo è un tipo di tema d'esame che ricorre spesso!)

Ne approfitto anche per mostrarvi un modo di scrivere codice che
espliciti le unità di misura e faccia automaticamente un controllo
dimensionale. In C++ questo sarebbe fattibile usando la
programmazione template, che non è stata però quasi mai usata per lo
svolgimento degli esercizi; tenete presente nei vostri futuri
progetti che librerie come
[Boost.units](https://www.boost.org/doc/libs/1_65_0/doc/html/boost_units.html),
[SI](https://github.com/bernedom/SI) o
[units](https://github.com/nholthaus/units) possono essere usate per
specificare le unità di misura di variabili e costanti, e per
verificarne la consistenza nel proprio codice.

Sfortunatamente, il modo in cui avete scritto programmi in questo
semestre fa uso della programmazione *object-oriented*, che non è
adatta per usare questo genere di librerie (e più in generale per il
calcolo numerico), perché avete dichiarato come `double` tutti i
parametri di metodi come `Solutore::CercaZeri` o
`Integral::integrate`, mentre per usare queste librerie C++ avreste
dovuto definire sia `Solutore` che `integral` come classi template.
Ad esempio:

```cpp
template <typename T, typename Fn>
class Solutore {
public:
  Solutore();

  virtual T CercaZeri(T xmin, T xmax, Fn f,
                      T prec = 1e-3, int nmax = 100) = 0;
};
```

In questo modo, supponendo di usare la libreria
[units](https://github.com/nholthaus/units), avreste potuto poi
passare a `Solutore::CercaZeri` variabili dimensionali, perché il
compilatore avrebbe selezionato il tipo `T` giusto (lunghezza,
tempo, etc.):

```cpp
using namespace units::length;
using namespace units::time;

Bisezione sol{};

// We find the zero of a function f(x), where x is a length
auto result1 = sol.CercaZeri(0.5_m, 1.5_m, my_function, 1e-4_m);

// We find the zero of a function g(t), where t is a time
auto result2 = sol.CercaZeri(10.0_s, 15.0_s, another_function, 1e-2_s);
```

Ovviamente, né `my_function` né `another_function` sarebbero più
state derivate da `FunzioneBase`, dovendo invece essere funzioni che
accettano quantità delle dimensioni giuste. Ecco per quale motivo la
programmazione *object-oriented* non è indicata per codici numerici:
non permette la versatilità nei tipi dei dati garantita invece dalla
programmazione con i template.

(In un certo senso, Julia è invece un linguaggio dove *tutto* è un
template, e ciò lo rende ideale per il calcolo scientifico).

### Esercizio 11.0

Iniziamo con l'importare la libreria
[Unitful.jl](https://github.com/PainterQubits/Unitful.jl), che
implementa le unità di misura che ci servono. Importeremo
esplicitamente quelle unità di misura che ci serviranno, perché la
libreria di default non ne importa nessuno (simboli come `m`, `s`,
`mm`, etc., sono molto usati come nomi di variabili, e sarebbe un
disastro se venissero tutti importati senza criterio!).

````julia:ex24
using Unitful
import Unitful: m, cm, mm, nm, s, °, mrad, @u_str
````

I simboli `nm`, `°` e `mrad` sono unità di misura che si possono
usare direttamente nelle definizioni, come `x = 10nm`. La macro
`@u_str`, terminando con `_str`, indica che è una macro che può
essere usata aggiungendo `u` dopo le stringhe per specificare le
unità di misura. Questo è indispensabile per tipi più complessi dei
semplici `m`, `cm`, `mm`, etc., che richiedano espressioni
matematiche, come ad esempio `E = 10u"N/C"` (campo elettrico).

Definiamo una serie di variabili per le costanti fisiche del problema:

````julia:ex25
σ_θ = 0.3mrad;       # I could have written σ_θ = 0.3u"mrad"
θ0_ref = 90°;        # Similarly,           θ0_ref = 90u"°"
Aref = 2.7;
Bref = 6e4u"nm^2";
α = 60.0°;
λ1 = 579.1nm;
λ2 = 404.7nm;
````

La funzione `n_cauchy` restituisce $n$ supponendo vera la formula di Cauchy.
La sintassi con un parametro usa i valori di riferimento di $A$ e $B$ scritti
sopra.

````julia:ex26
n_cauchy(λ, A, B) = sqrt(A + B / λ^2)
n_cauchy(λ) = n_cauchy(λ, Aref, Bref)
````

La funzione `n` invece restituisce $n$ in funzione della deviazione
misurata `δ` dal prisma, dove $\alpha$ è il suo angolo di apertura
(definito sopra). Siccome la funzione `asin` (arcoseno) restituisce
il valore in radianti, che è scomodo da leggere, definiamo `δ` in modo
che esprima sempre il risultato in gradi.

````julia:ex27
n(δ) = sin((δ + α) / 2) / sin(α / 2)
δ(n) = uconvert(u"°", 2asin(n * sin(α / 2)) - α)
````

Queste formule si ricavano banalmente dall'inversione della formula di Cauchy;
la funzione `A_and_B` calcola contemporaneamente $A$ e $B$, ed è stata
definita per comodità:

````julia:ex28
A(λ1, δ1, λ2, δ2) = (λ2^2 * n(δ2)^2 - λ1^2 * n(δ1)^2) / (λ2^2 - λ1^2)
B(λ1, δ1, λ2, δ2) = (n(δ2)^2 - n(δ1)^2) / (1/λ2^2 - 1/λ1^2)
A_and_B(λ1, δ1, λ2, δ2) = (A(λ1, δ1, λ2, δ2), B(λ1, δ1, λ2, δ2))
````

Calcoliamo allora i valori di riferimento di $n(\lambda_1) = n_1$ e
$n(\lambda_2) = n_2$, supponendo veri i valori di $A$ e $B$ scritti sopra
r(`A_ref` e `B_ref`):

````julia:ex29
n1_ref, n2_ref = n_cauchy(λ1), n_cauchy(λ2)
````

Da $n_1$ e $n_2$ calcoliamo quanto aspettarci per $\delta_1$ e
$\delta_2$:

````julia:ex30
δ1_ref, δ2_ref = δ(n1_ref), δ(n2_ref)
````

Il vostro codice probabilmente stamperà angoli in radianti (è la
convenzione di `asin` in C++), quindi convertiamo i valori sopra in
modo che possiate confrontarli col risultato del vostro programma:

````julia:ex31
println("δ1_ref = ", uconvert(u"rad", δ1_ref))
println("δ2_ref = ", uconvert(u"rad", δ2_ref))
````

A questo punto possiamo simulare l'esperimento. La simulazione della
misura di $\delta_1$ e $\delta_2$ va fatta usando l'approssimazione
Gaussiana con i valori medi `δ1_ref` e `δ2_ref`, e la deviazione
standard `σ_θ` data dal testo dell'esercizio:

````julia:ex32
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
````

Ecco i primi 5 valori della simulazione; controllate che siano gli
stessi che ottenete voi, facendo attenzione di usare come seme `1` e
che l'ordine in cui chiamate la funzione per generare i numeri
casuali sia la stessa del codice sopra:

  1. _Prima_ si genera $\theta_0$;
  2. _Poi_ si generano $\theta_1$ e $\theta_2$.

Nel fare i plot qui sotto mi limito a ripetere l'esperimento 1000
volte (il testo richiede 10.000 volte). I risultati non cambiano
molto.

````julia:ex33
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
````

````julia:ex34
histogram([n1_simul, n2_simul],
          label = ["n₁", "n₂"],
          layout = (2, 1));
savefig(joinpath(@OUTPUT, "hist_n1_n2.svg")); # hide
````

\fig{hist_n1_n2.svg}

````julia:ex35
scatter(n1_simul, n2_simul, label="");
savefig(joinpath(@OUTPUT, "scatter_n1_n2.svg")); # hide
````

\fig{scatter_n1_n2.svg}

Il package `Statistics` di Julia implementa il calcolo della
covarianza tra due serie, che è uguale alla correlazione a meno di
una normalizzazione. Definiamo quindi la funzione `corr`, che
calcola il coefficiente di correlazione, analogamente a questa; nel
vostro codice C++ dovrete invece implementarla usando la formula.

````julia:ex36
corr(x, y) = cov(x, y) / (std(x) * std(y))
````

I valori di $n_1$ ed $n_2$ sono correlati, perché sono entrambi
stati ricavati dalla medesima stima di $\theta_0$.

````julia:ex37
corr(n1_simul, n2_simul)
````

Nel fare l'istogramma di $A$ e $B$, rimuoviamo le unità di misura da
quest'ultimo, perché altrimenti Julia segnalerebbe che `A_simul` e
`B_simul` sono incompatibili (essendo combinati nella stessa
chiamata ad `histogram`):

````julia:ex38
histogram([A_simul, ustrip.(u"nm^2", B_simul)],
          label = ["A" "B"],
          layout = (2, 1))
savefig(joinpath(@OUTPUT, "hist_A_B.svg")); # hide
````

\fig{hist_A_B.svg}

Facciamo anche un grafico X-Y

````julia:ex39
scatter(A_simul, B_simul, label="");
savefig(joinpath(@OUTPUT, "scatter_A_B.svg")); # hide
````

\fig{scatter_A_B.svg}

Ricalcoliamo qui i coefficienti di correlazione nel caso in cui
l'esperimento sia rifatto 10.000 volte. Notate che creo di nuovo un
generatore di numeri casuali.

````julia:ex40
glc = GLC(1)
(n1_simul, n2_simul, A_simul, B_simul) = simulate_experiment(glc, 10_000)
println("Correlazione tra n1 e n2: ", corr(n1_simul, n2_simul))
println("Correlazione tra A e B: ", corr(A_simul, B_simul))
````

### Esercizio 11.1

L'esercizio 11.1 è preso da un vecchio tema d'esame, e va svolto in modo molto
simile al precedente. Si tratta di misurare il coefficiente di viscosità
$\eta$ partendo dalla velocità di caduta di una sferetta di metallo
all'interno di un cilindro pieno di glicerina, tramite la formula $$ v_L =
\frac{2R^2}{9\eta}(\rho - \rho_0) g = \frac{\Delta x}{\Delta t}, $$ dove
$\Delta x$ è la lunghezza del tratto percorso in caduta dalla sferetta e
$\Delta t$ il tempo impiegato. La relazione si inverte facilmente per dare $$
\eta = \frac{2R^2\,g\,\Delta t}{9\,\Delta x}(\rho - \rho_0), $$ dove le
quantità misurate in ognuno degli esperimenti Monte Carlo sono $R$, $\Delta x
= x_1 - x_0$, e $\Delta t$.

Definiamo le costanti numeriche del problema, usando ancora Unitful.jl:

````julia:ex41
δt, δx, δR = 0.01s, 0.001m, 0.0001m;
ρ, ρ0 = 2700.0u"kg/m^3", 1250.0u"kg/m^3";
g = 9.81u"m/s^2";
η_true = 0.83u"kg/m/s";
R_true = [0.01m, 0.005m];
x0 = 20cm;
x1 = 60cm;
Δx_true = x1 - x0;
````

Definiamo anche alcune relazioni matematiche.

````julia:ex42
v_L(R, η) = 2R^2 / (9η) * (ρ - ρ0) * g;
Δt(R, Δx, η) = Δx / v_L(R, η);
Δt_true = [Δt(R, Δx_true, η_true) for R in R_true];
η(R, Δt, Δx) = 2R^2 * g * Δt / (9Δx) * (ρ - ρ0);
````

Definiamo ora la funzione `simulate`, che effettua _due_ esperimenti: uno con
$R = 0.01\,\text{m}$ e l'altro con $R = 0.005\,\text{m}$.

````julia:ex43
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
````

Eseguiamo ora 1000 simulazioni e facciamo l'istogramma della stima di $\eta$
per i due raggi della sferetta.

````julia:ex44
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
````

\fig{hist_eta1_eta2.svg}

Si tratta ora di stimare le incertezze di $\eta$ al variare degli
errori considerati. Notate che per usare `round` con quantità
associate ad unità di misura è necessario specificare l'unità di
misura usata per arrotondare: con 4 cifre, il valore `1 m` potrebbe
essere scritto come `1.0000 m` oppure `100.0000 cm`!

````julia:ex45
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
````

