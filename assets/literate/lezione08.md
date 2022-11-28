<!--This file was generated, do not modify it.-->
In questa lezione implementeremo dei programmi per risolvere
equazioni differenziali. Come per la lezione della volta scorsa,
mostro qui qual è il risultato atteso per gli esercizi, usando
Julia.

Importiamo alcune librerie che ci saranno molto utili per svolgere
gli esercizi:

````julia:ex1
using Plots
using Printf
````

## Iterare sui tempi

In tutti gli esercizi di oggi si richiede di iterare sul tempo $t$,
perché la soluzione numerica delle equazioni differenziali richiede
di partire dalla condizione iniziale al tempo $t = t_0$ e procedere
a incrementi di $h$ finché non si raggiunge il tempo finale $t_f$:

```cpp
std::vector<double> current{...};  // Condizione iniziale
while (...) {
    // Sovrascrive "current" al tempo t con "current" al tempo t + h
    current = evolve(current, t, h);
    t += h;
}
```

È importante scrivere bene la condizione nel ciclo `while`, perché è
una cosa che gli studenti sbagliano spesso! Il problema sta negli
errori di arrotondamento, che sono dovuti al modo in cui il computer
memorizza i numeri *floating-point* e sono quindi identici sia in
C++ che in Julia.

Vediamo quindi in cosa consiste il problema usando Julia. Creiamo
una variabile `t = 0` che poi incrementiamo in passi di `h = 0.1`
secondi: in questo modo simuliamo quello che farebbe il ciclo per
risolvere una equazione differenziale

````julia:ex2
t = 0
h = 0.1
t += h
````

Nulla di sorprendente… Incrementiamo ancora un paio di volte:

````julia:ex3
t += h
t += h
````

Sorpresa! Con tre incrementi si è rivelato un piccolo errore di
arrotondamento che era nascosto già nel primo passaggio. Il problema
è che il numero `0.1` con cui incrementavamo ogni volta la variabile
`t` non è rappresentabile nel formato *floating-point* usato dai
calcolatori moderni, che usano lo [standard IEE
754](https://en.wikipedia.org/wiki/IEEE_754). L'errore si è
accumulato, passaggio dopo passaggio, diventando visibile solo al
terzo passaggio.

Considerate ora un codice come questo, che vorrebbe iterare per `t`
che va da `0` a `1` in step di `h = 0.1`:

````julia:ex4
function simulate(t0, tf, increment)
    t = t0

    println("Inizia la simulazione, da t=$t0 a $tf con h=$increment")

    # Itera finché non abbiamo raggiunto il tempo finale
    while t < tf
        println("  t = $t")
        t += increment
    end

    println("Simulazione terminata a t = $t")
end

simulate(0.0, 1.0, 0.1)
````

Il codice si è arrestato al tempo $t \approx 1.1$ anziché al tempo
$t = 1$! Questa implementazione di `while` è molto comune nei
compiti scritti dei vostri colleghi degli anni scorsi, ma è
ovviamente **sbagliata**. Il modo giusto per implementare questo
genere di ciclo è di calcolare il numero di iterazioni (come un
intero) e poi fare un ciclo for usando solo variabili intere:

````julia:ex5
function simulate_method1(t0, tf, increment)
    println("Inizia la simulazione, da t=$t0 a $tf con h=$increment")

    # Calcola il numero di iterazioni prima di iniziare il ciclo vero
    # e proprio
    nsteps = round(Int, (tf - t0) / h)
    t = t0
    for i = 1:nsteps
        println("  t = $t")
        # Incrementa come al solito
        t += h
    end
    println("Simulazione terminata a t = $t")
end

simulate_method1(0, 1, 0.1)
````

In questo caso il ciclo si è arrestato al valore $t \approx 1$, con
un errore $\delta t \sim 10^{-16}$ che è assolutamente trascurabile:
l'implementazione quindi è corretta.

Un secondo metodo è quello di evitare di «accumulare» l'incremento
`h` nella variabile `t` ad ogni iterazione, ma calcolare ogni volta
da capo quest'ultima:

````julia:ex6
function simulate_method2(t0, tf, increment)
    println("Inizia la simulazione, da t=$t0 a $tf con h=$increment")

    # Calcola il numero di iterazioni prima di iniziare il ciclo vero
    # e proprio
    nsteps = round(Int, (tf - t0) / h)
    t = t0
    for i = 1:nsteps
        println("  t = $t")
        # Ricalcola t partendo da t0 e da h, usando il contatore i
        t = t0 + i * h
    end
    println("Simulazione terminata a t = $t")
end

simulate_method2(0, 1, 0.1)
````

Non c'è una grande differenza tra i due metodi, quindi sentitevi
liberi di implementare quello che volete (potete implementarne uno
in un esercizio, e l'altro nell'esercizio successivo, così fate
pratica con entrambi).

## Esercizio 8.0: Algebra vettoriale

Testo dell'esercizio:
[carminati-esercizi-08.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-08.html#esercizio-8.0).

In Julia non è necessario implementare le operazioni aritmetiche su
vettori, perché sono già implementate: basta porre un punto `.`
davanti all'operatore perché questo venga automaticamente propagato
sugli elementi di vettori:

````julia:ex7
[1, 2, 4] .+ [3, 7, -5]
````

## Esercizio 8.1: metodo di Eulero

Testo dell'esercizio:
[carminati-esercizi-08.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-08.html#esercizio-8.1).

Qui non implementiamo una classe con metodo `Passo` come suggerito
nel testo dell'esercizio, perché in Julia non esiste l'equivalente
delle classi del C++. Scriviamo invece una funzione `euler` che
restituisce una matrice a $N + 1$ colonne, dove $N$ è il numero di
equazioni: la prima colonna contiene il tempo, le altre colonne le
soluzioni delle $N$ variabili. (Per i più curiosi: il modo migliore
di procedere in Julia sarebbe quello di implementare un
[iteratore](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration)).

In Julia non c'è bisogno di definire una classe base
`FunzioneVettorialeBase` da cui derivare altre classi come
`OscillatoreArmonico` eccetera: basta passare la funzione nel
parametro `fn` (primo argomento). È un meccanismo simile a quello
visto nella lezione precedente usando i template, anche se in Julia
la risoluzione dei template avviene a *runtime* anziché in fase di
compilazione come in C++.

````julia:ex8
function euler(fn, x0, startt, endt, h)
    # La scrittura startt:h:endt indica il vettore
    #
    #     [startt, startt + h, startt + 2h, startt + 3h, …, startt + N * h]
    #
    # dove N è il più grande intero tale che
    #
    #     startt + N * h ≤ endt
    timerange = startt:h:endt
    result = Array{Float64}(undef, length(timerange), 1 + length(x0))
    cur = x0
    for (i, t) in enumerate(timerange)
        result[i, 1] = t
        result[i, 2:end] = cur
        cur .+= fn(t, cur) * h
    end

    result
end
````

Definiamo ora una funzione che descriva l'oscillatore armonico del problema 8.1.

````julia:ex9
oscillatore(time, x) = [x[2], -x[1]]  # ω0 = 1
````

Invochiamo `oscillatore` usando come condizione iniziale $(x, v) =
(0, 1)$ e integrando nell'intervallo $0 \leq t \leq 70\,\text{s}$,
usando come passo $h = 10^{-1}$. La funzione restituisce una matrice
a tre colonne, contenenti il tempo, la posizione e la velocità.

````julia:ex10
h = 0.1
result = euler(oscillatore, [0., 1.], 0.0, 70.0, h);
````

Questi sono i primi step (tempo, posizione e velocità):

````julia:ex11
result[1:10, :]
````

Questi sono invece gli ultimi:

````julia:ex12
result[(end - 10):end, :]
````

Il risultato sopra dovrebbe esservi utile per scrivere dei test nel
vostro codice C++ usando `assert`:

```cpp
#include "EquazioniDifferenziali.hpp"
#include <cstdio>
#include <cassert>
#include <cmath>

bool is_close(double a, double b, double epsilon = 1e-8) {
    return std::fabs(a - b) < epsilon;
}

void test_euler() {
  Eulero eulero;
  OscillatoreArmonico oa{1.0};
  const double lastt{70.0};      // Simula il sistema per 70 s
  const double h{0.1};
  const int nsteps{static_cast<int>(lasttt / h + 0.5)};
  std::vector<double> pos{0.0, 1.0};

  // Esegue la simulazione
  double t{};
  for (int idx{}; idx < nsteps; ++idx) {
    pos = eulero.Passo(t, pos, h, &oa);
    t += h;
  }

  assert(is_close(pos[0], 19.773746013860173));
  assert(is_close(pos[1], 25.848774751522960));
}
```

Notate che il ciclo `for` è implementato calcolando preventivamente
il numero di passi in `nsteps`: è quello che sopra avevamo chiamato
il «Metodo 1» (`simulate_method1`).

Per studiare il funzionamento di `euler`, consideriamo la
simulazione nell'intervallo usato sopra, $0 \leq t \leq
70\,\text{s}$.

Per maggiore eleganza rispetto a quanto fatto sopra, dichiariamo la
variabile `lastt` (nel vostro codice dovreste definirla come un
`const double`, ma in un notebook destinato all'uso interattivo come
questo non è mai consigliato definire costanti).

````julia:ex13
lastt = 70.0;
````

Nello stabilire il passo di integrazione occorre fare
un'osservazione **molto importante**: se vogliamo paragonare la
soluzione calcolata da euler, possiamo semplicemente paragonare
l'ultimo valore di `pos.GetComponente(0)` col valore $\sin(70)$. Ma
questo funziona se effettivamente il valore della variabile $t$
durante l'ultima iterazione del ciclo `for` è uguale a 70, e questo
vale solo se $\Delta t = 70\,\text{s}$ è esattamente divisibile per
$h$. Non scegliete quindi a caso i valori di $h$, ma definiteli in
funzione del numero di passi che volete far compiere.

Nel codice Julia definiamo `nsteps` come un vettore di valori della
forma $7\times 10^k$, con $k \in [2, 2.2, 2.4, 2.6, \ldots, 3.8,
4]$: in questo modo gli estremi sono 700 e 70000, pari ad $h =
10^{-1}$ e $h = 10^{-3}$. Il valore di `nsteps` deve ovviamente
essere sempre arrotondato ad un intero (mediante round).

````julia:ex14
nsteps = 7 * round.(Int, exp10.(2:0.2:4))
````

In `deltat` memorizziamo invece i passi temporali (ossia, i valori
di $h$) che studieremo più sotto. Come spiegato per l'esercizio 8.0,
in Julia l'operatore `./` è come l'operatore `/` di divisione, ma
viene applicato uno ad uno ad ogni elemento dell'array, e risparmia
la noia di dover implementare un ciclo `for`.

````julia:ex15
deltat = lastt ./ nsteps
````

Creiamo ora un'animazione che confronti la soluzione analitica
esatta $f(x) = \sin x$ con la soluzione calcolata col metodo
`euler`. In Julia è semplicissimo creare animazioni: basta usare la
macro `@animate` del pacchetto
[Plots](https://github.com/JuliaPlots/Plots.jl/), e poi salvare il
risultato in un file GIF.

````julia:ex16
anim = @animate for h in deltat
    result = euler(oscillatore, [0., 1.], 0.0, 70.0, h)
    plot(result[:, 1], result[:, 2],
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(result[:, 1], sin.(result[:, 1]), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "euler.gif"), fps = 1);
````

\fig{euler.gif}

Vediamo che l'errore è estremamente significativo se $h = 10^{-2}$.
Facciamo un confronto più quantitativo confrontando il valore della
posizione all'istante $t=70\,\text{s}$ con quello teorico.

````julia:ex17
lastpos = [euler(oscillatore, [0., 1.], 0.0, lastt, h)[end, 2] for h in deltat]
error_euler = abs.(lastpos .- sin(lastt))

@printf("%-14s\t%-14s\n", "δt [s]", "x(70) [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\n", deltat[i], lastpos[i])
end
````

I numeri sopra vi saranno preziosi per fare test sul vostro codice
usando `assert`. Creiamo ora un plot che mostri l'andamento
dell'errore in funzione del passo $h$, come mostrato sul sito.

````julia:ex18
plot(deltat, error_euler,
     xscale = :log10, yscale = :log10,
     xlabel = "Passo d'integrazione",
     ylabel = @sprintf("Errore a t = %.1f", lastt),
     label = "")
scatter!(deltat, error_euler, label = "")

savefig(joinpath(@OUTPUT, "euler_error.svg")) # hide
````

\fig{euler_error.svg}

## Esercizio 8.2: Soluzione con Runge-Kutta

Testo dell'esercizio:
[carminati-esercizi-08.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-08.html#esercizio-8.2).

La funzione `rungekutta` implementa l'integrazione di Runge-Kutta
usando lo stesso approccio della funzione `euler` vista sopra: è
quindi un po' diverso dal modo in cui la implementerete voi.

````julia:ex19
function rungekutta(fn, x0, startt, endt, h)
    timerange = startt:h:endt
    result = Array{Float64}(undef, length(timerange), 1 + length(x0))
    cur = copy(x0)
    for (i, t) in enumerate(timerange)
        result[i, 1] = t
        result[i, 2:end] = cur

        k1 = fn(t,          cur)
        k2 = fn(t + h / 2., cur .+ k1 .* h / 2.0)
        k3 = fn(t + h / 2., cur .+ k2 .* h / 2.0)
        k4 = fn(t + h,      cur .+ k3 .* h)

        cur .+= (k1 .+ 2k2 .+ 2k3 .+ k4) .* h / 6
    end

    result
end
````

Il funzionamento di `rungekutta` è però il medesimo di `euler`: le
due funzioni accettano gli stessi parametri e restituiscono matrici
a tre colonne.

````julia:ex20
result = rungekutta(oscillatore, [0., 1.], 0.0, 70.0, 0.1);
````

Come sopra, consideriamo la posizione e la velocità all'inizio della
simulazione:

````julia:ex21
result[1:10, :]
````

Questi sono i dati alla fine della simulazione:

````julia:ex22
result[(end - 10):end, :]
````

Possiamo usare questi valori per scrivere una funzione
`test_runge_kutta`, simile a `test_euler` (v. sopra):

```cpp
void test_runge_kutta() {
  RungeKutta rk;
  OscillatoreArmonico oa{1.0};
  const double lastt{70.0};
  const double h{0.1};
  const int nsteps{static_cast<double>(lasttt / h + 0.5)};
  std::vector<double> pos{0.0, 1.0};

  // Esegue la simulazione
  double t{};
  for (int idx{}; idx < nsteps; ++idx) {
    pos = rk.Passo(t, pos, h, &oa);
    t += h;
  }

  assert(is_close(pos[0], 0.7738501114078689));
  assert(is_close(pos[1], 0.6333611095194112));
}
```

Nel caso di Runge-Kutta, l'animazione è molto meno interessante: la
convergenza è eccellente anche per $h = 10^{-1}$.

````julia:ex23
anim = @animate for h in deltat
    cur_result = rungekutta(oscillatore, [0., 1.], 0.0, 70.0, h)
    plot(cur_result[:, 1], cur_result[:, 2],
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(cur_result[:, 1], sin.(cur_result[:, 1]), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "rk.gif"), fps = 1);
````

\fig{rk.gif}

Confrontiamo il grafico dell'errore di Runge-Kutta con quello di
Eulero, per rendere evidente la differenza nella velocità di
convergenza.

````julia:ex24
lastpos = [rungekutta(oscillatore, [0., 1.], 0.0, lastt, h)[end, 2] for h in deltat]
error_rk = abs.(lastpos .- sin(lastt))
````

Questa è la corrispondenza tra $\delta t$ e la posizione finale (a
$t = 70\,\text{s}$):

````julia:ex25
@printf("%-14s\t%-14s\n", "δt [s]", "x(70) [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\n", deltat[i], lastpos[i])
end
````

Creiamo un plot che mostri visivamente la differenza tra i due metodi:

````julia:ex26
plot(deltat, error_euler, label = "")
scatter!(deltat, error_euler, label = "Eulero")

plot!(deltat, error_rk,
     xscale = :log10, yscale = :log10,
     xlabel = "Passo d'integrazione",
     ylabel = @sprintf("Errore a t = %.1f", lastt),
     label = "")
scatter!(deltat, error_rk, label = "Runge-Kutta")

savefig(joinpath(@OUTPUT, "euler_rk_comparison.svg")) # hide
````

\fig{euler_rk_comparison.svg}

## Esercizio 8.3

Testo dell'esercizio:
[carminati-esercizi-08.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-08.html#esercizio-8.3).

Questo esercizio richiede di studiare il comportamento di un pendolo
di lunghezza $l$ sottoposto ad un'accelerazione di gravità $g$.
Impostiamo un paio di costanti.

````julia:ex27
rodlength = 1.;
g = 9.81;
````

La funzione `pendulum` definisce i due membri dell'equazione
differenziale di secondo grado.

````julia:ex28
pendulum(t, x) = [x[2], -g / rodlength * sin(x[1])]
````

Prima di effettuare lo studio richiesto dall'esercizio, è buona
norma studiare il comportamento della soluzione in un caso
particolare. Usiamo `rungekutta` per analizzare il caso in cui
$\theta_0 = \pi / 3$:

````julia:ex29
oscillations = rungekutta(pendulum, [π / 3, 0.], 0.0, 3.0, 0.01)
oscillations[1:10, :]
````

Visualizziamo anche le ultime righe:

````julia:ex30
oscillations[(end - 10):end, :]
````

È interessante studiare il pendolo creando un'animazione. Noi
useremo il pacchetto
[Luxor](https://github.com/JuliaGraphics/Luxor.jl), che consente di
creare disegni ed animazioni partendo da forme geometriche
primitive. (Se volete creare qualcosa del genere in C++, potete
usare la libreria [Monet](https://github.com/ziotom78/monet),
convertendo poi i file SVG generati da Monet in format PNG con
l'interfaccia a linea di comando di
[Inkscape](https://inkscape.org/) e assemblando i file PNG in
un'animazione MP4 o MKV con [ffmpeg](https://ffmpeg.org/)).

Per installare Luxor da Internet, usate come al solito i comandi di
Pkg:

```julia
using Pkg
Pkg.add("Luxor")
```

Quando è installato, possiamo importarlo come al solito:

````julia:ex31
import Luxor
````

In Luxor occorre specificare le dimensioni della superficie su cui
si disegna; noi sceglieremo una dimensione di 500×500. Il sistema di
coordinate ha origine sempre nel centro dell'immagine, in modo che
l'intervallo di valori sugli assi $x$ ed $y$ sarà nel nostro caso
$-250\ldots 250$.

La funzione `plot_pendulum` rappresenta il pendolo come una linea
che parte dal centro e alla cui estremità è disegnato un cerchio
pieno di colore nero. (Notate che Julia offre il comando `sincos`,
che calcola simultaneamente il valore del seno e del coseno di un
angolo).

````julia:ex32
function plot_pendulum(angle)
    radius = 200  # Lunghezza del braccio del pendolo
    y, x = radius .* sincos(π / 2 + angle)

    Luxor.sethue("black")
    Luxor.line(Luxor.Point(0, 0), Luxor.Point(x, y), :stroke)
    Luxor.circle(Luxor.Point(x, y), 10, :fill)
end
````

Abbiamo già calcolato la soluzione dell'equazione in un caso
particolare, e il risultato è nella matrice `oscillations`. Il
comando `size` restituisce le dimensioni di vettori, matrici e
tensori. Nel caso di `oscillations` ci sono ovviamente 3 colonne, ma
il numero di righe (corrispondente agli step temporali) dipende dal
passo $h$ e dalla lunghezza della simulazione. Vediamo di quanti
step si tratta:

````julia:ex33
size(oscillations, 1)
````

Creeremo ora un'immagine GIF animata chiamando ripetutamente il
comando `plot_pendulum`. Notate la comodità di Luxor: in poche righe
è possibile creare un'intera animazione e salvarla su disco.

````julia:ex34
anim = Luxor.Movie(500, 500, "Pendulum")

function animframe(scene, framenumber)
    Luxor.background("white")
    plot_pendulum(oscillations[framenumber, 2])
end

Luxor.animate(anim, [Luxor.Scene(anim, animframe, 1:size(oscillations, 1))],
    creategif=true, pathname=joinpath(@OUTPUT, "pendulum.gif"));
````

\fig{pendulum.gif}

Adesso che abbiamo visto che l'equazione del pendolo viene integrata
correttamente, dobbiamo passare al calcolo del periodo di
oscillazione. Come suggerito sul sito, bisogna considerare il
momento in cui la velocità angolare inverte il segno. Osserviamo
allora il grafico della velocità (seconda componente del sistema di
equazioni differenziali).

````julia:ex35
plot(oscillations[:, 1], oscillations[:, 3],
     label = "",
     xlabel = "Tempo [s]",
     ylabel = "Velocità angolare [rad/s]")

savefig(joinpath(@OUTPUT, "oscillations1.svg")) # hide
````

\fig{oscillations1.svg}

Possiamo farci un'idea del punto in cui avviene l'inversione usando
i filtri offerti da Julia. In particolare, la sintassi `v .< 0.1`
restituisce un vettore contenente tutti gli elementi del vettore `v`
che hanno valore inferiore a 0.1, ed impiega il solito trucco del
punto `.` che «propaga» un operatore sugli elementi di un vettore.

Ecco quindi come troviamo tutte le iterazioni della soluzione per
cui la velocità $v_i$ è tale per cui $\left| v_i \right| < 0.1$:

````julia:ex36
oscillations[abs.(oscillations[:, 3]) .< 0.1, :]
````

Vediamo dunque che, oltre alla velocità nulla dell'istante iniziale
(ovvia perché causata dalle nostre condizioni iniziali), c'è una
inversione al tempo $t \approx 1.07\,\text{s}$ e un'altra al tempo
$t \approx 2.15\,\text{s}$.

Dai numeri mostrati qui sopra, è evidente il problema accennato sul
sito: non esiste alcun punto in cui la velocità angolare sia
esattamente zero, perché stiamo usando un passo discreto per
integrare l'equazione. I due istanti esatti in cui avvengono le
inversioni sono rispettivamente nell'intervallo $(1.07, 1.08)$ e
$(2.15, 2.16)$. Facciamo un grafico ingrandito nell'intervallo
temporale $t = 1\ldots 1.2\,\text{s}$ per renderci meglio conto
della cosa:

````julia:ex37
scatter(oscillations[:, 1], oscillations[:, 3],
        label = "",
        xlim = (1.0, 1.2),
        xlabel = "Tempo [s]",
        ylabel = "Velocità angolare [rad/s]")

savefig(joinpath(@OUTPUT, "oscillations2.svg")) # hide
````

\fig{oscillations2.svg}

Implementiamo quindi una funzione per cercare l'inversione di segno
in un vettore. Essa dovrà scandire il vettore e determinare quando
il segno di due elementi consecutivi cambia, restituendo la
posizione del primo di questi due elementi. (È buona cosa che anche
voi implementiate una funzione del genere nel vostro codice C++).

````julia:ex38
function search_inversion(vect)
    prevval = vect[1]
    for i in 2:length(vect)
        # Qui usiamo lo stesso trucco per trovare un cambio di segno
        # che avevamo già impiegato negli esercizi per la ricerca
        # degli zeri
        if sign(prevval) * sign(vect[i]) < 0
            return i - 1
        end
        prevval = vect[i]
    end

    println("No inversion found, run the simulation for a longer time")

    # Restituisci un indice negativo (impossibile), perché non
    # abbiamo trovato alcuna inversione.
    -1
end
````

La funzione restituisce l'indice dell'ultimo elemento del vettore
*prima* dell'inversione. Nella vostra versione in C++ quindi la
funzione dovrà restituire un tipo `size_t` (intero senza segno).
Verifichiamone il funzionamento su un vettore (ricordando che in
Julia gli elementi dei vettori si contano da 1 anziché da 0 come in
C++!).

````julia:ex39
search_inversion([4, 3, 1, -2, -5])
````

Il risultato è quello che ci aspettiamo: l'elemento alla posizione 3
ha segno positivo (`1`), mentre il successivo cambia di segno
(`-2`).

Ora che abbiamo una funzione che determina l'indice $i$ per cui
$\omega_i$ ha segno opposto a $\omega_{i + 1}$, ci occorre trovare
una formula interpolante che ci restituisca il tempo a cui la
velocità si annulla. In altri termini, stiamo considerando due punti
$A$ e $B$ associati agli istanti temporali $t_A$ e $t_B$, e in
corrispondenza dei quali la velocità angolare passa da $\omega_A$ a
$\omega_B$ con un cambio di segno, e vogliamo trovare l'istante
temporale a cui $\omega = 0$ nell'ipotesi che $\omega(t)$ segua una
legge lineare (il che è un'ottima approssimazione, se riguardate il
grafico sopra). Non dobbiamo quindi fare altro che scrivere
l'equazione della retta che passa per $(t_A, \omega_A)$ e per $t_B,
\omega_B$ e calcolare la sua intersezione con la retta $\omega = 0$.

Si tratta di un semplice problema di geometria analitica, e la
soluzione è la seguente:

$$
t(\omega) = t_A + \frac{t_A - t_B}{\omega_A - \omega_B}\bigl(\omega - \omega_A\bigr).
$$

È facile convincersi della correttezza del risultato, perché
$t(\omega_A) = t_A$, $t(\omega_B) = t_B$, e l'espressione è
chiaramente una retta.

Nel nostro caso bisogna quindi implementare il calcolo della formula
nel caso in cui $\omega = 0$, e **raddoppiare il risultato**: lo
facciamo nella funzione `period`, che accetta come parametro la
matrice a tre colonne prodotta da `euler` o `rungekutta`, e che
sfrutta la funzione `invtime` che fornisce il valore del tempo
all'istante della inversione. Implementiamo una serie di
sotto-funzioni, in modo che sia più facile verificare il
comportamento di ciascuna. Qui introduciamo due implementazioni di
`interp`: la seconda è più specifica e calcola l'ascissa del punto
di intersezione della retta con l'asse delle ordinate.

````julia:ex40
interp(ptA, ptB, y) = ptA[1] + (ptA[1] - ptB[1]) / (ptA[2] - ptB[2]) * (y - ptA[2])
interp(ptA, ptB) = interp(ptA, ptB, 0)
````

Eseguiamo una volta `interp` per trovare il valore dell'ordinata $y$
in corrispondenza dell'ordinata $y = 0.3$ di una una retta passante
per i punti $(-0.4, -0.7)$ e $(0.5, 0.8)$:

````julia:ex41
let p1x = -0.4, p1y = -0.7, p2x = 0.5, p2y = 0.8, y = 0.3
    # Il comando `plot` richiede di passare un array con le ascisse
    # e uno con le coordinate…
    plot([p1x, p2x], [p1y, p2y], label = "")
    # …mentre la nostra `interp` richiede due coppie (x, y)
    let x = interp([p1x, p1y], [p2x, p2y], y)
        @printf("La retta interpolante passa per (%.1f, %.1f)\n", x, y)
        # Il comando `scatter` funziona come `plot`
        scatter!([p1x, x, p2x], [p1y, y, p2y], label = "")
    end
end

savefig(joinpath(@OUTPUT, "interp-test.svg")) # hide
````

\fig{interp-test.svg}

Il grafico mostra che la nostra implementazione di `interp` funziona
a dovere; voi potreste implementare un test nel vostro esercizio:

```cpp
void test_interp() {
  const double p1x = -0.4, p1y = -0.7;
  const double p2x = 0.5, p2y = 0.8;

  assert(is_close(interp(p1x, p1y, p2x, p2y, 0.3), 0.2));
}
```

Introduciamo ora un'altra funzione, `invtime`, che mette insieme
`search_inversion` e `interp` per restituire l'istante temporale in
cui avviene l'inversione del segno del vettore `vec`:

````julia:ex42
function invtime(time, vec)
    idx = search_inversion(vec)
    timeA, timeB = time[idx:idx + 1]
    vecA, vecB = vec[idx:idx + 1]

    abs(interp((timeA, vecA), (timeB, vecB)))
end
````

Siccome in questo esercizio assumiamo sempre di iniziare dalla
posizione $\theta = 0$, il valore del periodo è semplicemente il
doppio del tempo necessario per osservare l'inversione
(nell'esercizio 9.4 questo **non sarà più vero**, ricordatevelo!).

````julia:ex43
period(oscillations) = 2 * invtime(oscillations[:, 1], oscillations[:, 3])
````

Chiamando `period` su una matrice restituita da `euler` o da
`rungekutta` si ottiene quindi il periodo di oscillazione.

````julia:ex44
period(oscillations)
````

Confrontiamola col periodo ideale di un pendolo sottoposto a piccole oscillazioni.

````julia:ex45
ideal_period = 2π / √(g / rodlength)
````

Creiamo ora il grafico analogo a quello riportato nel testo
dell'esercizio.

````julia:ex46
angles = 0.1:0.1:3.0
ampl = [period(rungekutta(pendulum, [angle, 0.], 0.0, 3.0, 0.01))
        for angle in angles]
plot(angles, ampl, label="", xlabel="Angolo [rad]", ylabel="Periodo [s]")
scatter!(angles, ampl, label="")

savefig(joinpath(@OUTPUT, "period-vs-angle.svg")) # hide
````

\fig{period-vs-angle.svg}

Ecco alcuni dei valori in una tabella che associa ampiezza (in
radianti) e periodo (in secondi). In questo modo potrete
confrontarli con l'output del vostro programma, magari mediante
alcuni test con `assert` (usate ad esempio il primo e l'ultimo).

````julia:ex47
[angles ampl]
````

## Esercizio 8.4

Testo dell'esercizio: [carminati-esercizi-08.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-08.html#esercizio-8.4).

Come sopra, definiamo i parametri numerici del problema.

````julia:ex48
ω0 = 10;
α = 1.0 / 30;
````

Trattandosi di un esercizio complesso, definiamo una funzione che
invochi `rungekutta` con dei parametri sensati. Notate la sintassi
`do...end`, che in Julia permette di passare come primo argomento di
una funzione (nel nostro caso appunto `rungekutta`) una seconda
funzione. Questa sintassi è molto comoda per casi come il nostro.

````julia:ex49
function forcedpendulum(ω; init=[0., 0.], startt=0., endt=15. / α, deltat=0.01)
    rungekutta(init, startt, endt, deltat) do t, x
        [x[2], -ω0^2 * x[1] - α * x[2] + sin(ω * t)]
    end
end
````

Il valore di ritorno di `forcedpendulum` è come al solito una
matrice a tre colonne. Il plot mostra come il pendolo forzato con
smorzante arrivi presto ad una situazione di equilibrio:

````julia:ex50
oscillations = forcedpendulum(8.)
plot(oscillations[:, 1], oscillations[:, 2], label="")

savefig(joinpath(@OUTPUT, "forced-pendulum.svg")) # hide
````

\fig{forced-pendulum.svg}

Rispetto all'esercizio precedente, dobbiamo calcolare qui non il
periodo bensì l'ampiezza di oscillazione (che nell'esercizio
precedente era fissata dalla condizione iniziale). Come prima, anche
qui non possiamo avere la garanzia che l'integrazione con RK passerà
dall'istante in cui il valore della velocità si annulla esattamente.
Il modo migliore di procedere è quindi il seguente:

1. Iteriamo RK per un tempo ragionevole in modo da toglierci dalla
   regione iniziale di instabilità; qui integro fino al tempo
   $15/\alpha$;

2. A questo punto il codice cerca nuovamente una inversione nel
   segno della velocità;

3. Trovata l'inversione, sappiamo che il massimo avviene in qualche
   istante che sta tra $t$ e $t + h$. Troviamo questo istante
   $t_\text{inv}$ con una interpolazione lineare tra il punto $(t,
   \omega_0)$ e $(t + h, \omega_1)$

4. Eseguiamo di nuovo RK partendo dal tempo $t$, ma questa volta non
   usiamo come incremento $h$ bensì $t_\text{inv} - t$

5. Se abbiamo fatto le cose per bene, dopo una *singola* esecuzione
   di RK ci troviamo in corrispondenza del massimo. Stampare la
   velocità in questo punto dovrebbe quindi mostrare un numero
   pressoché nullo

6. Se effettivamente la velocità è praticamente nulla (diciamo
   $\left|v\right| \leq 10^{-6}\,\text{rad/s}$, il valore della
   posizione in questo punto corrisponde all'ampiezza.

````julia:ex51
function forced_amplitude(ω, oscillations)
    # Per comodità estraggo la prima colonna della matrice (quella che
    # contiene i tempi) nel vettore "timevec"
    timevec = oscillations[:, 1]

    # Questa maschera serve per trascurare le oscillazioni nella prima
    # parte della simulazione, ossia le prime righe della matrice.
    # Di fatto quindi ci concentriamo solo sulla "coda" della soluzione,
    # ossia le ultime righe della matrice
    mask = timevec .> 10 / α
    oscill_tail = oscillations[mask, :]

    # Calcolo il tempo in corrispondenza della prima inversione
    # nella "coda" della soluzione
    idx0 = search_inversion(oscill_tail[:, 3])
    ptA = oscill_tail[idx0, [1, 3]]
    ptB = oscill_tail[idx0 + 1, [1, 3]]
    t0 = interp(ptA, ptB)
    δt = t0 - oscill_tail[idx0, 1]
    newsol = forcedpendulum(ω,
        init=oscill_tail[idx0, 2:3],
        startt=oscill_tail[idx0, 1],
        endt=oscill_tail[idx0, 1] + 1.1 * δt,
        deltat=δt)

    @printf("t0 = %.4f, angle = %.4f, speed = %.4f, t0 + δt = %.4f, angle = %.4f, speed = %.4f\n",
        newsol[1, 1], newsol[1, 2], newsol[1,3], newsol[2, 1], newsol[2, 2], newsol[2, 3])
    abs(newsol[2, 2])
end
````

Chiamiamo la funzione `forced_amplitude` su un caso specifico:
questo è un numero buono per essere usato in un `assert`. Notate che
nel secondo punto (corrispondente al tempo $t + \delta t$) la
velocità è nulla.

````julia:ex52
forced_amplitude(9.5, forcedpendulum(9.5))
````

Ricreiamo ora il grafico presente sul sito del corso. La funzione
`forced_amplitude` stampa a video i due punti su cui esegue di nuovo
il RK: potete verificare che il secondo punto è effettivamente
quello di massimo, perché la velocità è pressoché nulla. Usate i
numeri scritti qui sotto per verificare che il vostro codice sia
corretto.

````julia:ex53
# Aggiungiamo 0.01 agli estremi (9 e 11) per evitare la condizione di risonanza
freq = 9.01:0.1:11.01
println("The frequencies to be sampled are: $(collect(freq))")
ampl = [forced_amplitude(ω, forcedpendulum(ω)) for ω in freq]
plot(freq, ampl,
     label="", xlabel="Frequenza [rad/s]", ylabel="Ampiezza")
scatter!(freq, ampl, label="")

savefig(joinpath(@OUTPUT, "forced-pendulum-resonance.svg")) # hide
````

\fig{forced-pendulum-resonance.svg}

