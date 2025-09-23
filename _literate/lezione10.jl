# # Lezione 10
#
# Iniziamo importando i pacchetti che ci serviranno.

using Printf
using Plots
using Statistics

# ## Esercizio 10.0
#
# Definiamo una classe `GLC` che sia equivalente alla classe `Random`
# che vi viene richiesto di implementare in C++.
#
# In Julia non esiste il concetto di «classe», ma esistono le `struct`
# che funzionano in modo concettualmente simile. Non permettono di
# associare metodi, tranne eventualmente un semplice costruttore, e
# tutti i campi sono pubblici di default.

# ### Generatore Lineare Congruenziale

mutable struct GLC
    a::UInt32
    c::UInt32
    m::UInt32
    seed::UInt32

    GLC(myseed) = new(1664525, 1013904223, 1 << 31, myseed)
end

# Il tipo `UInt32` corrisponde a `unsigned int` in C++.
#
# La strana scrittura `1 << 31` è un'operazione di [bit
# shift](https://en.wikipedia.org/wiki/Bitwise_operation#Bit_shifts):
# dice di considerare il numero `1` in binario, e di spostarlo a
# sinistra, aggiungendo quindi alla sua destra tanti zeri quanti il
# secondo operando (31). Ecco alcuni esempi, dove i numeri che
# iniziano con `0b` sono scritti in binario (è una convenzione del C++
# e di Julia):
#
# ```text
# 0b10010 << 1 == 0b100100    (uno zero aggiunto alla fine)
# 0b10010 << 3 == 0b10010000  (tre zeri aggiunti alla fine)
# 0b10010 >> 2 == 0b100       (due cifre tolte alla fine)
# ```
#
# Potete comprendere il significato dell'operazione se pensate al caso
# decimale: se sposto un numero come `1` a sinistra, aggiungendo 31
# zeri, lo sto moltiplicando per $10^{31}$, ottenendo quindi il numero
# `1e+31`. Analogamente, se tolgo $N$ cifre a destra di un numero, lo
# sto *dividendo* per $10^N$.
#
# Nel caso binario, `1 << 31` vuol dire moltiplicare `1` per
# $2^{31}$, ma quest'operazione è molto più rapida che usando `pow()`
# in C++ o l'operatore `^` in Julia, perché il bit-shift viene fatto a
# livello di singoli capacitori e induttanze nella CPU, che
# “travasano” la carica di un bit nel bit accanto, ed è un'operazione
# velocissima.

#md # !!! note "Piccola nota storica"
#md #     Negli anni '90 il compilatore [Borland C++](https://en.wikipedia.org/wiki/Borland_C%2B%2B) aveva introdotto l'ottimizzazione di tradurre istruzioni come `x *= 2` in `x <<= 1`, e analogamente per la divisione intera per 2 o sue potenze. Questo aveva causato un sensibile aumento di velocità di certi codici, che la Borland aveva pubblicizzato nelle sue brochures! Oggi quest'ottimizzazione è diventata standard su tutti i compilatori, non solo C++, ma all'epoca era un trucco da “addetti ai lavori”, ed aveva suscitato molto interesse il fatto che un compilatore fosse diventato così furbo da saperla applicare in certi casi.

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

histogram([rand(glc) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "rand_hist.svg")); # hide

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

histogram([randexp(glc, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randexp_hist.svg")); # hide

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
    x = sqrt(-2log(s)) * cos(2π * t)
    μ + σ * x
end

# All'interno della funzione, nella riga in cui si assegna il valore a
# `x`, vi sareste potuti aspettare la riga
#
# ```julia
# x = sqrt(-2log(1 - s)) * cos(2π * t)
# ```
#
# con il termine `2log(1 - s)` anziché `2log(s)`. I due termini *non* sono uguali, ovviamente, ma la loro distribuzione statistica invece sì: in entrambi i casi infatti l'argomento del logaritmo è distribuito uniformemente tra 0 ed 1. Però la scrittura `2log(s)` risparmia una sottrazione ed è quindi lievemente più veloce.

# Questi sono i numeri per i vostri `assert`, assumendo ovviamente che anche voi usiate `log(s)` anziché `log(1 - s)`:

glc = GLC(1)
for i in 1:5
    println(i, ": ", randgauss(glc, 2, 1))
end

# Questo è l'istogramma:

histogram([randgauss(glc, 2, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randgauss_hist.svg")); # hide

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

histogram([randgauss_ar(glc, 2, 1) for i in 1:10000], label="");
savefig(joinpath(@OUTPUT, "randgauss_ar_hist.svg")); # hide

# \fig{randgauss_ar_hist.svg}


# ## Esercizio 10.1
#
# L'esercizio è molto semplice da implementare, ma richiede comunque una
# certa attenzione: bisogna studiare infatti molti casi (ben 12 istogrammi),
# e questo richiede molto ordine e pulizia! Imparare a scrivere codice
# ordinato è importante soprattutto per il giorno dell'esame: capita spesso
# che nei temi d'esame si chieda di ripetere più volte un calcolo o una
# simulazione, ed è bene non usare copia-e-incolla ma strutturare il
# codice usando dei cicli `for` e implementando funzioni di supporto
# anziché rendere il `main` lungo centinaia di righe.
#
# Iniziamo con l'implementazione di un codice che riempia un vettore
# con i campioni casuali sommati $N$ alla volta:

function computesums!(glc::GLC, n, vec)
    for i in eachindex(vec)
        accum = 0.0
        for k in 1:n
            accum += rand(glc)
        end
        vec[i] = accum
    end
end

# (in Julia c'è la convenzione di mettere il carattere `!` alla fine delle
# funzioni che modificano uno dei loro argomenti: questo è proprio il nostro
# caso, perché `vec` viene modificato da `computesums!`)
#
# Facciamo una prova semplice:

glc = GLC(1)
## Array di *due* elementi
vec = Array{Float64}(undef, 2)
## Chiediamo che in ogni elemento vengano sommati *cinque*
## numeri. Quindi ogni elemento di `vec` sarà un numero
## casuale nell'intervallo 0…5.
computesums!(glc, 5, vec)
println("vec[1] = ", vec[1])
println("vec[2] = ", vec[2])

# Potete usare questi numeri in un `assert` per verificare la
# vostra implementazione di `compute_sums` (mettete pure tutto
# nello stesso file del `main`):
#
# ```cpp
# void test_compute_sums() {
#   std::vector<double> vec(2);  // Attenzione, parentesi *tonde* qui!
#
#   RandomGen rng{1};
#   compute_sums(rng, 5, vec);
#   assert(are_close(vec[0], 1.7307902472093701));
#   assert(are_close(vec[1], 1.7124183257110417));
#   cerr << "compute_sums() is correct, hurrah! 🥳\n";
# }
# ```
#
# Ora ci occorre invocare questa funzione più volte facendo variare $N$
# da 1 a 12, e producendo un istogramma ogni volta.

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

# \fig{es10_1_histogram.svg}

# Notate che, grazie alla definizione della funzione `computesums!`,
# il ciclo `for` è stato ridotto ad appena tre righe. Inoltre proprio
# l'uso del `for` ha evitato quegli orribili copia-e-incolla che
# spesso i docenti trovano nelle correzioni degli esami scritti.
#
# Il seguente è un esempio di come **non** implementare questo
# esercizio; è un vero esercizio, consegnato da uno studente pochi
# anni fa. È una vera e propria “galleria degli orrori”!
#
# ```cpp
# // 👿 NON BASATEVI SU QUESTO CODICE! 👿
#
# std::vector<double> vec(100'000);
#
# // Aargh! Qui scrive di nuovo il numero 100'000 anziché usare `ssize(vec)`:
# // cosa succede se poi durante l'esame voleva usare un numero minore
# // per risparmiare tempo? Deve cambiare tutte le occorrenze!
# for(int k{}; k < 100'000; ++k) {
#   vec[k] = 0.0;   // Per giunta qui non usa neppure vec.at(k),
#                   // quindi se riduce il numero 100'000 nella
#                   // definizione di `vec` ma non nel ciclo `for`,
#                   // qui poteva avere un “segmentation fault”!
#   for(int i{}; i < 1; ++i)
#     vec[k] += rand.Unif(0.0, 1.0);
# }
#
# // Ok, invece che fare una sola figura con 12 grafici sceglie di
# // creare 12 file PNG distinti… è più faticoso però poi
# // controllare i risultati e confrontare gli istogrammi!
# Gnuplot plt1{};
# plt1.redirect_to_svg("n1.png");
# plt1.histogram(vec, 20, "N = 1");
# plt1.show();
#
# // Caso con n = 2
#
# // NOOOO! Tutto quanto segue è un copia-e-incolla del codice sopra!
# // Terribile!
# for(int k{}; k < 100'000; ++k) {
#   vec[k] = 0.0;
#   for(int i{}; i < 2; ++i)
#     vec[k] += rand.Unif(0.0, 1.0);
# }
#
# Gnuplot plt2{};
# plt3.redirect_to_svg("n3.png");
# plt3.histogram(vec, 20, "N = 3");
# plt3.show();
#
# // Caso con n = 3
# for(int k{}; k < 100'000; ++k) {
#   vec[k] = 0.0;
#   for(int i{}; i < 3; ++i)
#     vec[k] += rand.Unif(0.0, 1.0);
# }
#
# Gnuplot plt3{};
# plt3.redirect_to_svg("n3.png");
# plt3.histogram(vec, 20, "N = 3");
# plt3.show();
#
# // Il codice continua tutto così… ci siamo capiti!
# // …
# ```
#
# Il codice Julia evita di ricorrere ai copia-e-incolla implementando
# una funzione `computesums!` e chiamandola più volte all'interno di
# un ciclo `for`. Questo approccio è estremamente elegante 😇 e ha molti
# vantaggi rispetto al disperato copia-e-incolla del malefico esempio 👿:
#
# -   Ci mettete meno tempo a scriverlo, e in un esame il tempo è sempre prezioso;
# -   Se scegliete l'approccio “copia-e-incolla” 👿 e vi rendete conto di un
#     errore nel codice che avete appena copiato (ad esempio, una parentesi non chiusa),
#     dovete correggerlo dodici volte… ma nel caso 😇 l'errore va corretto una
#     volta sola! E anche questo è un bel risparmio di tempo.
# -   Il codice 😇 è più semplice da leggere, e quindi è più facile individuare
#     errori (ci sono meno posti in cui il problema potrebbe nascondersi)
# -   Se vi rendete conto che il programma ci mette troppo per essere
#     eseguito, e questo vi è di impiccio perché i risultati non vi
#     convincono e prevedete di doverlo eseguire molte volte, è
#     semplice limitare ad esempio i valori di `N` da esplorare nel
#     codice 😇, limitandovi ad esempio ai primi 5 casi anziché a
#     tutti e 12. Nel codice 👿 invece, dovete commentare decine di
#     righe di codice, col rischio di commentare qualche variabile
#     importante che vi serve alla fine del programma e che quindi
#     causa errori di compilazione…
#
# Ora creiamo il grafico con l'andamento della deviazione standard (calcolata
# nell'esempio sopra con la funzione `Statistics.std`), memorizzata in
# `list_of_sigmas`:

plot(list_of_N, list_of_sigmas,
     xaxis = :log10, yaxis = :log10, label = "",
     xlabel = "N", ylabel = "Standard deviation σ")
savefig(joinpath(@OUTPUT, "es10_1_std.svg")); # hide

# \fig{es10_1_std.svg}

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
# Teniamo presente che $\int_0^{\pi/2} x \sin x\,\mathrm{d}x = 1$; inoltre, siccome
# $x \sin(x)$ è una funzione limitata in $[0, 1]$, possiamo porre `fmax = π/2` nella
# chiamata a `inthm`:

xsinx(x) = x * sin(x)
println("Integrale (metodo media):", intmean(GLC(1), xsinx, 0, π/2, 100))
println("Integrale (metodo hit-or-miss):", inthm(GLC(1), xsinx, 0, π/2, π/2, 100))

# Implementate degli `assert` che verifichino che ottenete gli stessi
# risultati nella vostra implementazione C++. Come già ricordato
# sopra, fate molta attenzione ad inizializzare il generatore di
# numeri pseudo-casuali con lo stesso seme (`1` in questo caso).
# Notate anche che il codice sopra usa **due** generatori di numeri
# casuali: uno per `intmean` e l'altro per `inthm`. Se voi invece
# ne usate uno solo e chiamate `intmean` e poi `inthm` passando sempre
# quello, anche se avete implementato correttamente entrambi i metodi,
# per `intmean` lo stesso numero ma per `inthm` un numero diverso!
#
# Eseguiamo ora il calcolo per 10.000 volte e facciamone l'istogramma:
# osserviamo che la distribuzione è approssimativamente una Gaussiana,
# come previsto.

glc = GLC(1)
mean_samples = [intmean(glc, xsinx, 0, π / 2, 100) for i in 1:10_000]
histogram(mean_samples, label="Media")

glc = GLC(1)  # Reset the random generator
mean_hm = [inthm(glc, xsinx, 0, π / 2, π / 2, 100) for i in 1:10_000]
histogram!(mean_hm, label="Hit-or-miss");
savefig(joinpath(@OUTPUT, "mc_integrals.svg")); # hide

# \fig{mc_integrals.svg}

# Passiamo ora al punto 2: calcoliamo 10.000 volte il valore dell’integrale
# variando il valore di $N$ e disegnamo gli istogrammi:

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

# \fig{mc_integrals_varying_N.svg}

# Questo è il grafico con l’andamento dell’errore:

scatter(
    list_of_N,
    list_of_errors,
    xlabel = "N",
    ylabel = "Errore",
    xaxis = :log10,
    yaxis = :log10,
)
savefig(joinpath(@OUTPUT, "mc_integrals_err_plot.svg")); # hide

# \fig{mc_integrals_err_plot.svg}

# E questi sono i punti calcolati:

println("N       Errore")
for (cur_n, cur_err) in zip(list_of_N, list_of_errors)
    @printf("%d\t%.5f\n", cur_n, cur_err)
end

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

target_ε = 0.001
noptim_mean = round(Int, (k_mean / target_ε)^2)
noptim_hm = round(Int, (k_hm / target_ε)^2)

println("N (media) = ", noptim_mean)
println("N (hit-or-miss) = ", noptim_hm)

# Per verificare la correttezza del risultato, rifacciamo l'istogramma. Siccome
# ci vuole molto tempo per ottenere il risultato, verifichiamo il risultato solo
# nel caso del metodo della media, e per un numero ridotto di realizzazioni
# (1000 anziché 10.000):

glc = GLC(1)
values = [intmean(glc, xsinx, 0, π / 2, noptim_mean) for i in 1:1000]
histogram(values, label="");
savefig(joinpath(@OUTPUT, "mc_intmean.svg")); # hide

# \fig{mc_intmean.svg}

# Il risultato è effettivamente corretto:

std(values)

# # Lezione 12: Simulazione di un esperimento
#
# L'esercizio di questa lezione è **estremamente** importante, perché
# le tecniche Monte Carlo sono molto diffuse in fisica. (E inoltre
# questo è un tipo di tema d'esame che ricorre spesso!)
#
# Ne approfitto anche per mostrarvi un modo di scrivere codice che
# espliciti le unità di misura e faccia automaticamente un controllo
# dimensionale. In C++ questo sarebbe fattibile usando la
# programmazione template, che non è stata però quasi mai usata per lo
# svolgimento degli esercizi; tenete presente nei vostri futuri
# progetti che librerie come
# [mp-units](https://mpusz.github.io/mp-units/latest/),
# [Boost.units](https://www.boost.org/doc/libs/1_65_0/doc/html/boost_units.html),
# [SI](https://github.com/bernedom/SI),
# [units](https://github.com/nholthaus/units), etc. possono essere
# usate per specificare le unità di misura di variabili e costanti, e
# per verificarne la consistenza nel proprio codice.
#
# Sfortunatamente, il modo in cui avete scritto programmi in questo
# semestre fa uso della programmazione *object-oriented*, che non è
# adatta per usare questo genere di librerie (e più in generale per il
# calcolo numerico), perché avete dichiarato come `double` tutti i
# parametri di metodi come `Solutore::CercaZeri` o
# `Integral::integrate`, mentre per usare queste librerie C++ avreste
# dovuto definire sia `Solutore` che `integral` come classi template.
# Ad esempio:
#
# ```cpp
# template <typename T, typename Fn>
# class Solutore {
# public:
#   Solutore();
#
#   virtual T CercaZeri(T xmin, T xmax, Fn f,
#                       T prec = 1e-3, int nmax = 100) = 0;
# };
# ```
#
# In questo modo, supponendo di usare la libreria
# [units](https://github.com/nholthaus/units), avreste potuto poi
# passare a `Solutore::CercaZeri` variabili dimensionali, perché il
# compilatore avrebbe selezionato il tipo `T` giusto (lunghezza,
# tempo, etc.):
#
# ```cpp
# using namespace units::length;
# using namespace units::time;
#
# Bisezione sol{};
#
# // We find the zero of a function f(x), where x is a length
# auto result1 = sol.CercaZeri(0.5_m, 1.5_m, my_function, 1e-4_m);
#
# // We find the zero of a function g(t), where t is a time
# auto result2 = sol.CercaZeri(10.0_s, 15.0_s, another_function, 1e-2_s);
# ```
#
# Ovviamente, né `my_function` né `another_function` sarebbero più
# state derivate da `FunzioneBase`, dovendo invece essere funzioni che
# accettano quantità delle dimensioni giuste.
#
# (In Julia questo tipo di programmazione è naturale perché in un
# certo senso *tutto* è un template, e ciò lo rende ideale per il
# calcolo scientifico. Vedremo meglio questo aspetto nel seminario
# “jolly” che terrò dopo la sessione di esami per chi è interessato).
#
# ## Esercizio 12.0
#
# Iniziamo con l'importare la libreria
# [Unitful.jl](https://github.com/PainterQubits/Unitful.jl), che
# implementa le unità di misura che ci servono. Importeremo
# esplicitamente quelle unità di misura che ci serviranno, perché la
# libreria di default non ne importa nessuno (simboli come `m`, `s`,
# `mm`, etc., sono molto usati come nomi di variabili, e sarebbe un
# disastro se venissero tutti importati senza criterio!).

using Unitful
import Unitful: m, cm, mm, nm, s, °, mrad, @u_str

# I simboli `nm`, `°` e `mrad` sono unità di misura che si possono
# usare direttamente nelle definizioni, come `x = 10nm`. La macro
# `@u_str`, terminando con `_str`, indica che può essere usata
# aggiungendo `u` dopo le stringhe per specificare le unità di misura.
# Questo è indispensabile per tipi più complessi dei semplici `m`,
# `cm`, `mm`, etc., che richiedano espressioni matematiche, come ad
# esempio i campi elettrici: `E = 10u"N/C"`.

# Definiamo una serie di variabili per le costanti fisiche del problema:

σ_θ = 0.3mrad;       # Avrei potuto scrivere σ_θ = 0.3u"mrad"
θ0_ref = 90°;        # Ugualmente,           θ0_ref = 90u"°"
Aref = 2.7;
Bref = 6e4u"nm^2";   # Qui devo usare `u` perché nm² è troppo complicato
α = 60.0°;
λ1 = 579.1nm;
λ2 = 404.7nm;

# La funzione `n_cauchy` restituisce $n$ supponendo vera la formula di Cauchy.
# La sintassi con un parametro usa i valori di riferimento di $A$ e $B$ scritti
# sopra.

n_cauchy(λ, A, B) = sqrt(A + B / λ^2)
n_cauchy(λ) = n_cauchy(λ, Aref, Bref)

# La funzione `n` invece restituisce $n$ in funzione della deviazione
# misurata `δ` dal prisma, dove $\alpha$ è il suo angolo di apertura
# (definito sopra). Siccome la funzione `asin` (arcoseno) restituisce
# il valore in radianti, che è scomodo da leggere, definiamo `δ` in modo
# che esprima sempre il risultato in gradi: per questo scopo c'è la
# funzione `uconvert`, che richiede come primo parametro l'unità di
# misura di *destinazione* (nel nostro caso gradi, quindi `u"°"`).

n(δ) = sin((δ + α) / 2) / sin(α / 2)
δ(n) = uconvert(u"°", 2asin(n * sin(α / 2)) - α)

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

# Il vostro codice probabilmente stamperà angoli in radianti (è la
# convenzione di `asin` in C++), quindi convertiamo i valori sopra in
# modo che possiate confrontarli col risultato del vostro programma:

println("δ1_ref = ", uconvert(u"rad", δ1_ref))
println("δ2_ref = ", uconvert(u"rad", δ2_ref))

# A questo punto possiamo simulare l'esperimento. La simulazione della
# misura di $\delta_1$ e $\delta_2$ va fatta usando l'approssimazione
# Gaussiana con i valori medi `δ1_ref` e `δ2_ref`, e la deviazione
# standard `σ_θ` data dal testo dell'esercizio:

function simulate_experiment(glc, nsim)
    n1_simul = Array{Float64}(undef, nsim)
    n2_simul = Array{Float64}(undef, nsim)

    A_simul = Array{Float64}(undef, nsim)
    ## Here I create an array of values whose measurement unit
    ## must be the same as `Bref`
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

@printf("%14s %14s %14s %14s\n", "n₁", "n₂", "A", "B [nm²]")
println(repeat('-', 62))
for i = 1:5
    ## We use scientific notation for B, as it is ≪1. As we want to
    ## avoid printing units for B (they are already in the table header),
    ## we just «strip» nm² from it.
    @printf("%14.6f %14.6f %14.6f %14.6e\n",
            n1_simul[i], n2_simul[i], A_simul[i], ustrip(u"nm^2", B_simul[i]))
end

#

histogram([n1_simul, n2_simul],
          label = ["n₁" "n₂"],
          layout = (2, 1));
savefig(joinpath(@OUTPUT, "hist_n1_n2.svg")); # hide

# \fig{hist_n1_n2.svg}

scatter(n1_simul, n2_simul, label="");
savefig(joinpath(@OUTPUT, "scatter_n1_n2.svg")); # hide

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

# Nel fare l'istogramma di $A$ e $B$, rimuoviamo le unità di misura da
# quest'ultimo, perché altrimenti Julia segnalerebbe che `A_simul` e
# `B_simul` sono incompatibili (essendo combinati nella stessa
# chiamata ad `histogram`):

histogram([A_simul, ustrip.(u"nm^2", B_simul)],
          label = ["A" "B"],
          layout = (2, 1))
savefig(joinpath(@OUTPUT, "hist_A_B.svg")); # hide

# \fig{hist_A_B.svg}

# Facciamo anche un grafico X-Y

scatter(A_simul, B_simul, label="");
savefig(joinpath(@OUTPUT, "scatter_A_B.svg")); # hide

# \fig{scatter_A_B.svg}

# Ricalcoliamo qui i coefficienti di correlazione nel caso in cui
# l'esperimento sia rifatto 10.000 volte. Notate che creo di nuovo un
# generatore di numeri casuali.

glc = GLC(1)
(n1_simul, n2_simul, A_simul, B_simul) = simulate_experiment(glc, 10_000)
println("Correlazione tra n1 e n2: ", corr(n1_simul, n2_simul))
println("Correlazione tra A e B: ", corr(A_simul, B_simul))

# ## Esercizio 12.1 — Attrito viscoso (facoltativo)
#
# L'esercizio 12.1 è preso da un vecchio tema d'esame, e va svolto in modo molto
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
# Definiamo le costanti numeriche del problema, usando ancora Unitful.jl:

δt, δx, δR = 0.01s, 0.001m, 0.0001m;
ρ, ρ0 = 2700.0u"kg/m^3", 1250.0u"kg/m^3";
g = 9.81u"m/s^2";
η_true = 0.83u"kg/m/s";
R_true = [0.01m, 0.005m];
x0 = 20cm;
x1 = 60cm;
Δx_true = x1 - x0;

# Definiamo anche alcune relazioni matematiche.

v_L(R, η) = 2R^2 / (9η) * (ρ - ρ0) * g;
Δt(R, Δx, η) = Δx / v_L(R, η);
Δt_true = [Δt(R, Δx_true, η_true) for R in R_true];
η(R, Δt, Δx) = 2R^2 * g * Δt / (9Δx) * (ρ - ρ0);

# Definiamo ora la funzione `simulate`, che effettua _due_ esperimenti: uno con
# $R = 0.01\,\text{m}$ e l'altro con $R = 0.005\,\text{m}$.

function simulate(glc::GLC, δx, δt, δR)
    ## Misura dell'altezza iniziale
    cur_x0 = randgauss(glc, x0, δx)
    ## Misura dell'altezza finale
    cur_x1 = randgauss(glc, x1, δx)

    ## Questo array di 2 elementi conterrà le due stime di η
    ## (corrispondenti ai due possibili raggi della sferetta)
    estimated_η = zeros(typeof(η_true), 2)
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

η1 = Array{typeof(η_true)}(undef, N)
η2 = Array{typeof(η_true)}(undef, N)
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, δt, δR)
end

histogram(η2, label="R = $(R_true[2])")
histogram!(η1, label="R = $(R_true[1])");
savefig(joinpath(@OUTPUT, "hist_eta1_eta2.svg")); # hide

# \fig{hist_eta1_eta2.svg}

# Si tratta ora di stimare le incertezze di $\eta$ al variare degli
# errori considerati. Notate che per usare `round` con quantità
# associate ad unità di misura è necessario specificare l'unità di
# misura usata per arrotondare: con 4 cifre, il valore `1 m` potrebbe
# essere scritto come `1.0000 m` oppure `100.0000 cm`!

## In η1 ed η2 abbiamo già le stime di η considerando tutti
## e tre gli errori
println("Tutti gli errori: δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

## Ora dobbiamo eseguire di nuovo N esperimenti, assumendo che
## l'errore sia presente in una sola delle tre quantità
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0m, 0.0s, δR)
end
println("Solo δR:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

## Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, 0.0m, δt, 0.0m)
end
println("Solo δt:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))

## Idem
for i in 1:N
    (η1[i], η2[i]) = simulate(glc, δx, 0.0s, 0.0m)
end
println("Solo δx:          δη(R1) = ", round(u"kg/m/s", std(η1), digits = 4))
println("                    (R2) = ", round(u"kg/m/s", std(η2), digits = 4))
