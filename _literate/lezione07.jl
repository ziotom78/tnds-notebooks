# In questo documento mostro come implementare gli algoritmi di
# integrazione numerica visti durante la lezione 7. È una utile
# traccia per capire quali risultati dovete aspettarvi, perché
# fornisce i numeri da usare negli assert del vostro codice.
#
# Invece di fornire gli esempi di codice in C++, ho scelto di usare il
# linguaggio [Julia](https://julialang.org/), per i seguenti motivi:
#
# - Non fornendo codici C++, vi obbligo ad implementare tutto da soli;
#
# - Il linguaggio Julia è molto semplice da leggere, e non richiede
# - competenze particolari per essere compreso;
#
# - Essendo questo un notebook, include sia le spiegazioni che gli
# - esempi di codice e gli output.
#
# Tenete conto in Julia non esiste incapsulamento, e l'ereditarietà e
# il polimorfismo sono implementati in maniera diversa dal C++, quindi
# il modo in cui sono implementati i codici è profondamente diverso.
# Essendo un linguaggio pensato per applicazioni scientifiche, la
# notazione di Julia è molto «matematica», e non dovrebbe essere
# difficile per voi capire cosa faccia il codice.
#
# ## Installazione di Julia
#
# Questo documento è un documento creato con Julia e i pacchetti
# [Literate.jl](https://github.com/fredrikekre/Literate.jl) e
# [Franklin.jl](https://github.com/tlienart/Franklin.jl).
#
# Julia è un linguaggio di programmazione moderno pensato soprattutto
# per la scrittura di codici numerici e scientifici. È più semplice
# del C++ ma, a differenza di altri linguaggi «facili» come Python, è
# estremamente potente. Non è consigliabile installare Julia sui
# computer del laboratorio, a causa dello scarso spazio disponibile
# nelle home. Le istruzioni in questo paragrafo possono esservi utili
# se desiderate installare Julia sul vostro computer.
#
# Scaricate l'eseguibile per il vostro ambiente dal sito
# https://julialang.org/ (al momento la versione più recente è la 1.6,
# ma la 1.7 è prevista a breve). Avviate poi Julia (da Linux eseguite
# julia, mentre sotto Windows e Mac OS X dovrebbe essere presente
# un'icona), ed installate alcuni pacchetti che saranno utili per
# questa lezione e la prossima.
#
# ```julia
# import Pkg
# Pkg.add("Plots")
# Pkg.add("IJulia")
# ```
#
# Una volta eseguiti i comandi, potete aprire notebook esistenti e
# crearne di nuovi con questo codice:
#
# ```julia
# using IJulia
# jupyterlab(dir=".")
# ```
#
# Appena eseguita l'istruzione, dovrebbe aprirsi il vostro browser
# Internet (Firefox, Safari, …) e mostrare la pagina di Jupyter-Lab,
# l'interfaccia che consente di gestire i notebook.
#
# ## Introduzione
#
# Iniziamo col caricare due librerie che ci serviranno. In Julia si
# caricano librerie col comando `import` (l'analogo di `#include` in
# C++):

import Statistics

## In C++ si sarebbe scritto: Statistics::mean
## ("Statistics" è un namespace)
Statistics.mean([1, 2, 3])

# Esiste il comando `using`, che equivale alla combinazione in C++ di `#include` e `using namespace`:

using Statistics

## Non è più necessario scrivere `Statistics.mean`
mean([1, 2, 3])

# Le librerie che ci interessano sono Plots (per produrre grafici,
# come ROOT in C++) e Printf (per scrivere valori formattati sullo
# schermo, come in C++ `setprecision`, `setw`, etc.)

using Plots
using Printf

# Nella lezione di oggi dovremo calcolare numericamente degli
# integrali. Useremo come esempio la funzione $f(x) = \sin(x)$,
# sapendo che
#
# $$\int_0^\pi\sin x\,\mathrm{d}x = 2.$$
#
# Useremo molto anche la capacità di Julia di creare liste al volo
# mediante la sintassi
#
# ```julia
# result = [f(x) for x in lista]
# ```
#
# che equivale al codice seguente:
#
# ```julia
# result = []
# for elem in lista
#     append!(result, f(elem))
# end
# ```
#
# Vediamo un esempio: creiamo un array prova che contenga il quadrato
# dei valori `[1, 2, 3]`. In C++ avremmo dovuto scrivere
#
# ```cpp
# std::vector<int> list{1, 2, 3};
# std::vector<int> prova(3);       // Parentesi tonde qui!
# for (size_t i{}; i < list.size(); ++i) {
#     prova[i] = list[i] * list[i];
# }
#
# // Ora `prova` contiene i valori {1, 4, 9}
# ```
#
# In Julia è tutto molto più semplice:
#
# ```julia
# [x * x for x in [1, 2, 3]]
# ```
#
# ## Metodo del mid-point
#
# Il metodo del mid-point consiste nell'approssimare l'integrale con
# il valore del punto della funzione $f$ nel punto medio
# dell'intervallo:
#
# $$
# \int_a^b f(x)\,\mathrm{d}x \approx
# \sum_{k = 0}^{n - 1} h \cdot f\left(a + \left(k + \frac12\right) h\right).
# $$
#
# In Julia non esistono classi, quindi non è possibile definire una
# classe `Integral`: si usa una tecnica più adatta per i calcoli che
# si usano in fisica, basata sul *multiple dispatch*.
#
# Non preoccupiamoci quindi di definire classi, ma implementiamo il
# metodo del mid-point tramite una semplice funzione `midpoint`. Non
# specifichiamo il tipo di `f`, né di `a` o di `b`, ma specifichiamo
# quello di `n`: il motivo sarà chiaro quando risolveremo l'esercizio
# 7.2. Il tipo `Integer` è l'analogo di una classe astratta in C++, ed
# è il padre di tutti quei tipi che rappresentano numeri interi
# (`Int`, `Int8`, `UInt32`, etc.). Stiamo in pratica dicendo a Julia
# che `midpoint` può accettare qualsiasi tipo di valore per `f`, `a` e
# `b`, ma `n` deve essere un numero intero.

function midpoint(f, a, b, n::Integer)
    h = (b - a) / n
    h * sum([f(a + (k + 0.5) * h) for k in 0:(n - 1)])
end

# Verifichiamone il funzionamento (in Julia $\pi$ è memorizzato nella
# costante `pi`):

midpoint(sin, 0, pi, 10)

# Casi come questo sono utili per implementare un `assert`. Vediamo
# cosa succede cambiando il numero di passi:

midpoint(sin, 0, pi, 100)

# Verifichiamo anche che il segno cambi se invertiamo gli estremi:

midpoint(sin, pi, 0, 10)

# Notate la semplicità con cui è stata chiamata la funzione: a
# differenza della programmazione OOP in C++, qui non abbiamo dovuto
# creare una classe `Seno` con un metodo `Eval` che chiamasse `sin`. È
# stato sufficiente invocare `midpoint` passandole sin come primo
# argomento.
#
# Il caso $\int_0^\pi \sin(x)\,\mathrm{d}x$ è troppo particolare per
# poter essere un buon caso per i test, perché (1) l'estremo inferiore
# è zero, e (2) la funzione si annulla negli estremi di integrazione.
# Alcune formule di integrazione che vedremo oggi richiedono un
# trattamento speciale agli estremi di integrazione, e un caso come
# questo potrebbe far passare inosservati dei bug importanti (**è
# successo in passato!**). Calcoliamo il valore dell'integrale con
# questo algoritmo in due casi più rappresentativi:
#
# $$
# \int_0^1\sin(x)\,\mathrm{d}x, \qquad
# \int_1^2\sin(x)\,\mathrm{d}x.
# $$

println("Primo integrale:   ", midpoint(sin, 0, 1, 10))
println("Secondo integrale: ", midpoint(sin, 1, 2, 30))

# In C++ possiamo quindi usare i seguenti assert:
#
# ```cpp
# int test_midpoint() {
#     Seno mysin{};
#     Midpoint mp{};
#
#     assert(are_close(mp.integrate(0, M_PI, 10, mysin), 2.0082484079079745));
#     assert(are_close(mp.integrate(0, M_PI, 100, mysin), 2.000082249070986));
#     assert(are_close(mp.integrate(M_PI, 0, 10, mysin), -2.0082484079079745));
#     assert(are_close(mp.integrate(0, 1, 10, mysin), 0.45988929071851814));
#     assert(are_close(mp.integrate(1, 2, 30, mysin), 0.9564934239032155));
# }
# ```
#
# ## Errore del metodo mid-point
#
# Calcoliamo ora l'andamento dell'errore rispetto alla funzione di riferimento $f(x) = \sin(x)$.

steps = [10, 50, 100, 500, 1000]
errors = [abs(midpoint(sin, 0, pi, n) - 2) for n in steps]

plot(steps, errors, xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "midpoint-error.svg")) # hide

# \fig{midpoint-error.svg}

# Il grafico precedente non è chiaro perché ci sono escursioni di
# alcuni ordini di grandezza sia per la variabile $x$ che per la
# variabile $y$. Usiamo allora un grafico bilogaritmico, in cui si
# rappresentano i punti $(x', y') = (\log x, \log y)$ anziché $(x,
# y)$. Questo è l'ideale per i grafici di leggi del tipo $y =
# x^\alpha$, come si vede da questi conti:
#
# $$
# \begin{aligned}
# y &= C x^\alpha,\\
# \log y &= \log\left(C x^\alpha\right),\\
# \log y &= \alpha \log x + \log C, \\
# y' &= \alpha x' + \log C,
# \end{aligned}
# $$
#
# che è della forma $y' = m x' + q$, ossia una retta, dove il
# coefficiente angolare $m$ è proprio $\alpha$.

plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "midpoint-error-log.svg")) # hide

# \fig{midpoint-error-log.svg}

# Nel vostro codice vorrete probabilmente usare ROOT per creare un
# grafico come questo. Siccome la realizzazione di grafici in ROOT può
# essere complessa, il mio consiglio è quello di stampare dapprima i
# numeri in un file (oppure a video, reindirizzando l'output da linea
# di comando con il carattere `>`), e solo una volta che sembrano
# ragionevoli procedere a creare il plot.
#
# Se invece di ROOT volete usare
# [gplot++](https://github.com/ziotom78/gplotpp), scaricate il file
# [gplot++.h](https://raw.githubusercontent.com/ziotom78/gplotpp/master/gplot%2B%2B.h)
# (facendo click col tasto destro sul link) e usate un codice del
# genere:
#
# ```cpp
# std::vector<double> steps{10, 50, 100, 500, 1000};
# std::vector<double> errors(steps.size());
#
# for (size_t i{}; i < errors.size(); ++i) {
#     errors[i] = ...; // Riempire il valore corrispondente
# }
#
# Gnuplot plt{};
# const std::string output_file_name{"midpoint-error.png"};
# plt.redirect_to_png(output_file_name, "800,600");
#
# plt.set_logscale(Gnuplot::AxisScale::LOGXY);
# plt.plot(steps, errors);
# plt.set_xlabel("Numero di passi");
# plt.set_ylabel("Errore");
# plt.show();
#
# // È sempre bene avvisare l'utente che è stato creato un file e fornirgli il
# // nome.
# std::cout << "Plot salvato nel file " << output_file_name << std::endl;
# ```
#
# Implementiamo ora una funzione che consenta di calcolare rapidamente
# l'errore di una funzione di integrazione numerica per un dato numero
# di passi di integrazione: ci servirà per studiare non solo il metodo
# del mid-point, ma anche i metodi di Simpson e dei trapezi.
#
# Inizializziamo per prima cosa le costanti che caratterizzano il caso
# che useremo come esempio, $\int_0^\pi\sin x\,\mathrm{d}x = 2$: la
# funzione da integrare (`REF_FN`), gli estremi (`REF_A` e `REF_B`), e
# il valore esatto dell'integrale (`REF_INT`).

const REF_FN = sin;  # La funzione da integrare
const REF_A = 0;     # Estremo inferiore di integrazione
const REF_B = pi;    # Estremo superiore di integrazione
const REF_INT = 2.;  # Valore dell'integrale noto analiticamente

# La funzione `compute_errors` calcola il valore assoluto della
# differenza tra la stima dell'integrale con la funzione `fn` (che può
# essere ad esempio `midpoint`) e il valore vero dell'integrale,
# `REF_INT`.

compute_errors(fn, steps) = [abs(fn(REF_FN, REF_A, REF_B, n) - REF_INT)
                             for n in steps]

# Applichiamo `compute_errors` alla funzione `midpoint`:

errors = compute_errors(midpoint, steps)

# Come ricavare la legge di potenza dovrebbe essere ovvio dal discorso
# fatto sopra circa i grafici bilogaritmici…

function error_slope(steps, errors)
    deltax = log(steps[end]) - log(steps[1])
    deltay = log(errors[end]) - log(errors[1])

    deltay / deltax
end

error_slope(steps, errors)

# Domanda: È importante nell'implementazione di `error_slope` sopra fissare la base del logaritmo, oppure no? In altre parole, si ottengono risultati diversi se si usa $\log_2$, $\log_{10}$ oppure $\log_e$?
#
# ## Metodo di Simpson
#
# Si usa la formula
#
# $$
# \int_a^b f(x)\,\mathrm{d}x \approx \left(
# \frac13 f(x_0) +
# \frac43 f(x_1) +
# \frac23 f(x_2) +
# \ldots +
# \frac43 f(x_{N - 2}) +
# \frac13 f(x_{N - 1})
# \right) h,
# $$
#
# con $x_k = a + k h$.
#
# Come sopra, implementiamo l'algoritmo senza definire classi (come
# faremmo in C++), ma scrivendo direttamente una funzione.

function simpson(f, a, b, n::Integer)
    ## Siccome il metodo funziona solo quando il numero di
    ## intervalli è pari, usiamo "truen" anziché "n" nei
    ## calcoli sotto
    truen = (n % 2 == 0) ? n : (n + 1)

    h = (b - a) / truen
    acc = 1/3 * (f(a) + f(b))
    for k = 1:(truen - 1)
        acc += 2/3 * (1 + k % 2) * f(a + k * h)
    end

    acc * h
end

# Verifichiamone il funzionamento sul nostro caso di riferimento.
# Anche questi numeri sono utili per implementare degli assert nel
# vostro codice C++; in particolare, il metodo di Simpson tratta in
# modo diverso gli estremi $f(a)$ e $f(b)$, quindi il secondo e il
# terzo test sono particolarmente importanti!

println("Primo caso:   ", simpson(sin, 0, pi, 10))
println("Secondo caso: ", simpson(sin, 0, pi, 100))
println("Terzo caso:   ", simpson(sin, 0, 1, 10))
println("Quarto caso:  ", simpson(sin, 1, 2, 30))

# Stavolta non fornisco gli `assert` da usare nel vostro codice:
# dovreste essere in grado di implementarli da soli usando i quattro
# numeri stampati sopra.

errors = compute_errors(simpson, steps)

plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "simpson-error.svg")) # hide

# \fig{simpson-error.svg}

# Verifichiamo che la pendenza sia quella attesa: l'errore $\epsilon$
# dovrebbe essere tale che $\epsilon \propto h^{-4}$.

error_slope(steps, errors)

# ## Metodo dei trapezoidi
#
# In questo caso si approssima l'integrale con l'area del trapezio.

function trapezoids(f, a, b, n::Integer)
    h = (b - a) / n
    acc = (f(a) + f(b)) / 2
    for k in 1:(n - 1)
        acc += f(a + k * h)
    end

    acc * h
end

println("Primo caso:   ", trapezoids(sin, 0, pi, 10))
println("Secondo caso: ", trapezoids(sin, 0, pi, 100))
println("Terzo caso:   ", trapezoids(sin, 0, 1, 10))
println("Quarto caso:  ", trapezoids(sin, 1, 2, 30))

# Facciamo un plot come prima:

errors = compute_errors(trapezoids, steps)
plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "trapezoids-error.svg")) # hide

# \fig{trapezoids-error.svg}

# Calcoliamo anche la pendenza della curva $\epsilon \propto h^\alpha$:

error_slope(steps, errors)

# Tracciamo ora un grafico comparativo dei due metodi. 

plot(steps, compute_errors(midpoint, steps),
     label = "Mid-point",
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi",
     ylabel = "Errore")
plot!(steps, compute_errors(trapezoids, steps),
      label = "Trapezoidi")
plot!(steps, compute_errors(simpson, steps),
      label = "Simpson")

savefig(joinpath(@OUTPUT, "error-comparison.svg")) # hide

# \fig{error-comparison.svg}

# Notate che il metodo del mid-point e dei trapezi hanno la stessa
# legge di scala, ma non si sovrappongono: la costante $C$ nella legge
# di scala $\epsilon = Cn^{-\alpha}$ è diversa (e quindi è diversa
# l'intercetta $q = \log C$ nel grafico bilogaritmico).
#
# ## Ricerca della precisione
#
# L'esercizio 7.2 è diverso dagli esercizi 7.0 e 7.1, perché richiede
# di iterare il calcolo finché non si raggiunge una precisione
# fissata. Usiamo il suggerimento del testo per non dover ricalcolare
# da capo il valore approssimato dell'integrale.
#
# Sfruttiamo la capacità di Julia di esprimere sequenze con la
# sintassi `start:delta:end`:

## La funzione `collect` obbliga Julia a stampare l'elenco completo
## degli elementi di una lista anziché usare la forma compatta (poco
## interessante in questo caso)
collect(1:2:10)

# Ora appare chiaro perché nell'implementare `midpoint`, `simpsons` e
# `trapezoids` sopra avevamo dichiarato esplicitamente come `Integer`
# il tipo dell'ultimo parametro, `n`: adesso vogliamo invece invocare
# `trapezoids` usando la precisione, che indichiamo col tipo
# `AbstractFloat`, analogo a una classe astratta C++ da cui derivano i
# tipi floating-point, come `Float16`, `Float32`, e `Float64`.

function trapezoids(f, a, b, prec::AbstractFloat)
    n = 2

    h = (b - a) / n
    ## Valore dell'integrale nel caso n = 2
    acc = (f(a) + f(b)) / 2 + f((a + b) / 2)
    newint = acc * h
    while true
        oldint = newint
        n *= 2
        h /= 2

        for k in 1:2:(n - 1) # Itera solo sui numeri dispari
            acc += f(a + k * h)
        end

        newint = acc * h
        ## 4//3 è la frazione 4/3 in Julia. In C++ *non* scrivete
        ## 4/3, perché sarebbe una divisione intera: scrivete 4.0/3
        if 4//3 * abs(newint - oldint) < prec
            break
        end
    end

    newint
end

# Notate che dopo aver compilato la definizione precedente, Julia ha
# scritto trapezoids (generic function with 2 methods). Ha quindi
# capito che abbiamo fornito una nuova implementazione di trapezoids,
# e non ha quindi sovrascritto la vecchia (che accettava come ultimo
# argomento un intero, ossia il numero di passaggi).

# Per verificare il funzionamento della nuova funzione trapezoids,
# possiamo verificare che l'integrale calcolato sulla nostra funzione
# di riferimento $f(x) = \sin x$ abbia un errore sempre inferiore alla
# precisione richiesta.

prec = [1e-1, 1e-2, 1e-3, 1e-4, 1e-5]
errors = [abs(trapezoids(REF_FN, REF_A, REF_B, eps) - REF_INT)
          for eps in prec]

plot(prec, errors,
     label = "Misurato",
     xscale = :log10, yscale = :log10,
     xlabel = "Precisione impostata",
     ylabel = "Precisione ottenuta")
plot!(prec, prec, label = "Caso teorico peggiore")

savefig(joinpath(@OUTPUT, "trapezoids-vs-theory.svg")) # hide

# \fig{trapezoids-vs-theory.svg}ù

