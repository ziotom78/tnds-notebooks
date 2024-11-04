<!--This file was generated, do not modify it.-->
In questo documento mostro come implementare gli algoritmi di
integrazione numerica visti durante la lezione 7. È una utile
traccia per capire quali risultati dovete aspettarvi, perché
fornisce i numeri da usare negli `assert` del vostro codice.

Invece di fornire gli esempi di codice in C++, ho scelto di usare il
linguaggio [Julia](https://julialang.org/), per i seguenti motivi:

- Non fornendo codici C++, vi obbligo ad implementare tutto da soli
  come nelle lezioni precedenti;

- Il linguaggio Julia è molto semplice da leggere, e non richiede
  competenze particolari per essere compreso;

- Essendo questo un notebook, include sia le spiegazioni che gli
  esempi di codice e gli output.

Tenete conto in Julia non esiste incapsulamento, e l'ereditarietà e
il polimorfismo sono implementati in maniera diversa dal C++, quindi
il modo in cui sono implementati i codici è profondamente diverso.
Essendo un linguaggio pensato per applicazioni scientifiche, la
notazione di Julia è molto «matematica», e non dovrebbe essere
difficile per voi capire cosa faccia il codice.

## Installazione di Julia

Questo documento è un documento creato con Julia e i pacchetti
[Literate.jl](https://github.com/fredrikekre/Literate.jl) e
[Franklin.jl](https://github.com/tlienart/Franklin.jl).

Julia è un linguaggio di programmazione moderno pensato soprattutto
per la scrittura di codici numerici e scientifici. È più semplice
del C++ ma, a differenza di altri linguaggi «facili» come Python, è
estremamente potente. Non è consigliabile installare Julia sui
computer del laboratorio, a causa dello scarso spazio disponibile
nelle home. Le istruzioni in questo paragrafo possono esservi utili
se desiderate installare Julia sul vostro computer.

Scaricate l'eseguibile per il vostro ambiente dal sito
https://julialang.org/ (al momento la versione più recente è la
1.8). Avviate poi Julia (da Linux eseguite `julia`, mentre sotto
Windows e Mac OS X dovrebbe essere presente un'icona), ed installate
alcuni pacchetti che saranno utili per questa lezione e la prossima.

```julia
import Pkg
Pkg.add("Plots")
Pkg.add("IJulia")
```

Una volta eseguiti i comandi, potete continuare a lavorare da linea
di comando nel prompt di `julia`, oppure aprire notebook esistenti e
crearne di nuovi con questi due comandi:

```julia
using IJulia
jupyterlab(dir=".")
```

Appena eseguite queste istruzioni, dovrebbe aprirsi il vostro
browser Internet (Firefox, Safari, …) e mostrare la pagina di
Jupyter-Lab, l'interfaccia che consente di gestire i notebook.

## Introduzione

Iniziamo col caricare due librerie che ci serviranno. In Julia si
caricano librerie col comando `import` (l'analogo di `#include` in
C++):

````julia:ex1
import Statistics

# In C++ si sarebbe scritto: Statistics::mean
# ("Statistics" è un namespace)
Statistics.mean([1, 2, 3])
````

Notate che in Julia i namespace sono molto più ordinati che in C++:
se si scrive `import Statistics`, questo non è messo nel namespace
`std` (come sarebbe stato in C++), ma nel namespace `Statistics`.
(Bjarne Stroustrup, il creatore del C++, ha dichiarato in una
conferenza che se potesse tornare indietro rivedrebbe il modo in cui
il namespace `std` è stato usato fino ad oggi!)

Esiste il comando `using`, che equivale alla combinazione in C++ di
`#include` e `using namespace`:

````julia:ex2
using Statistics

# Non è più necessario scrivere `Statistics.mean`
mean([1, 2, 3])
````

Nella lezione di oggi dovremo calcolare numericamente degli
integrali. Useremo come esempio la funzione $f(x) = x \sin(x)$,
sapendo che

$$\int_0^{\pi/2} x \sin x\,\mathrm{d}x = \left[\sin x - x \cos x\right]_0^{\pi/2} = 1$$

Useremo molto anche la capacità di Julia di creare liste mediante
la sintassi

```julia
result = [f(x) for x in input]
```

che equivale al codice seguente:

```julia
result = [f(input[1]), f(input[2]), f(input[3]), …]
```

Vediamo un esempio: creiamo un array `list` che contenga i valori
`1, 2, 3`, e poi creiamo un nuovo array `out` che contenga il
quadrato dei numeri in `list`, ossia `1, 4, 9`. In C++ avremmo
dovuto scrivere

```cpp
std::vector<int> list{1, 2, 3};
std::vector<int> out(ssize(list));   // Round parentheses here!
for (size_t i{}; i < list.size(); ++i) {
    // Save the squared value of list[i] into out[i]
    out[i] = list[i] * list[i];
}

// Now `out` contains the values {1, 4, 9}
```

In Julia è tutto molto più semplice:

```julia
list = [1, 2, 3]
# This gets expanded in [1*1, 2*2, 3*3], which is [1, 4, 9]
out = [x * x for x in list]
```

## Esercizio 7.0 – Integrazione con la formula del mid-point


Testo dell'esercizio:
[carminati-esercizi-07.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-07.html#esercizio-7.0).

Il metodo del mid-point consiste nell'approssimare l'integrale con
il valore del punto della funzione $f$ nel punto medio
dell'intervallo:

$$
\int_a^b f(x)\,\mathrm{d}x \approx
\sum_{k = 0}^{n - 1} h \cdot f\left(a + \left(k + \frac12\right) h\right).
$$

In Julia non esistono classi, quindi non è possibile definire una
classe `Integral`: si usa una tecnica più adatta per i calcoli che
si usano in fisica, basata sul *multiple dispatch*.

In Julia possiamo quindi immediatamente implementare il metodo del
mid-point tramite una semplice funzione `midpoint`. Non
specifichiamo il tipo di `f`, né di `a` o di `b` (in Julia si può, e
anzi di solito si fa così!), ma specifichiamo quello di `n`: il
motivo sarà chiaro quando risolveremo l'[esercizio 7.2](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-07.html#esercizio-7.2). Il tipo
`Integer` è l'analogo di una classe astratta in C++, ed è il padre
di tutti quei tipi che rappresentano numeri interi (`Int`, `Int8`,
`UInt32`, etc.). La scrittura `n::Integer` dice a Julia che `midpoint`
può accettare qualsiasi tipo di valore per `f`, `a` e `b`, ma `n`
deve essere per forza un numero intero.

````julia:ex3
function midpoint(f, a, b, n::Integer)
    h = (b - a) / n
    h * sum([f(a + (k + 0.5) * h) for k in 0:(n - 1)])
end
````

La scrittura `[f(a + (k + 0.5) * h) for k in 0:(n - 1)]` è l'analogo
della notazione matematica

$$\left\{f\bigl(a + (k + 0.5) h\bigr), k \in 0\ldots n - 1 \right\}$$

e il risultato dell'espressione è un array di valori che viene
passato alla funzione `sum`, la quale ovviamente ne calcola la
somma. In Julia non c'è quindi bisogno di implementare un ciclo
`for` (cosa che invece dovrete fare nella vostra implementazione
C++ del midpoint).

Possiamo invocare `midpoint` senza bisogno di definire una classe
che implementi il calcolo di `f(x)`: in Julia si possono definire
funzioni “anonime” (ossia, senza un nome come `f`) con la sintassi
`x -> espressione`. Ecco come calcolare l'integrale di $x\sin x$
sull'intervallo $[0, \pi / 2]$ con 10 passi:

````julia:ex4
midpoint(x -> x * sin(x), 0, pi / 2, 10)
````

Il risultato è confortante: non è molto dissimile da 1, che è il
valore calcolabile analiticamente.

Vediamo cosa succede cambiando il numero di passi:

````julia:ex5
midpoint(x -> x * sin(x), 0, pi / 2, 100)
````

Verifichiamo anche che il segno cambi se invertiamo gli estremi:

````julia:ex6
midpoint(x -> x * sin(x), pi / 2, 0, 10)
````

Notate la semplicità con cui è stata chiamata la funzione: a
differenza della programmazione OOP in C++, qui non abbiamo dovuto
derivare una classe `Seno` dalla classe `FunzioneBase` e ridefinire
un metodo `Eval` che chiamasse `x * sin(x)`.

Definiamo per maggiore comodità la funzione $f(x)$:

````julia:ex7
xsinx(x) = x * sin(x)
````

(funzioni brevi per cui basta una riga di codice possono essere
implementati con questa sintassi, anziché quella che usa `function`
che abbiamo impiegato sopra per `midpoint`).

Possiamo ora invocare `midpoint` passando direttamente `xsinx`:

````julia:ex8
midpoint(xsinx, pi / 2, 0, 10)
````

Con i numeri ottenuti potreste già implementare dei test nel vostro
codice C++. Però il caso $\int_0^{\pi/2} x \sin(x)\,\mathrm{d}x$ è
un po' troppo particolare per poter essere un buon caso per i test,
perché (1) l'estremo inferiore è zero, e (2) la funzione si annulla
nell'estremo sinistro.

Il problema è che alcune formule di integrazione che vedremo oggi
richiedono un trattamento speciale agli estremi di integrazione, e
un caso come questo potrebbe far passare inosservati dei bug
importanti (**è successo a molti studenti in passato!**). Calcoliamo
il valore dell'integrale con questo algoritmo in due casi meno banali:

$$
\int_0^1 x \sin(x)\,\mathrm{d}x, \qquad
\int_1^2 x \sin(x)\,\mathrm{d}x.
$$

````julia:ex9
println("Primo integrale:   ", midpoint(xsinx, 0, 1, 10))
println("Secondo integrale: ", midpoint(xsinx, 1, 2, 30))
````

In C++ possiamo quindi usare i seguenti `assert`:

```cpp
int test_midpoint() {
  XSinX xsinx{};
  Midpoint mp{};

  assert(are_close(i.Integrate(0, numbers::pi / 2, 10, xsinx),
                   0.9989696941917652);
  assert(are_close(i.Integrate(0, numbers::pi / 2, 100, xsinx),
                   0999989718940119);
  assert(are_close(i.Integrate(numbers::pi / 2, 0, 10, xsinx),
                   -0.998969694191765);
  assert(are_close(mp.integrate(0, 1, 10, xsinx),
                   0.3005925674684609));
  assert(are_close(mp.integrate(1, 2, 30, xsinx),
                   1.440482828731412));
  fmt::println(stderr, "The midpoint function works correctly! 🥳");
}
```

D'ora in poi non fornirò più liste di `assert` belle e pronte, ma
dovrete voi ricavare i numeri dagli output di Julia e scrivere gli
`assert` corrispondentemente. Ormai avete fatto esperienza!


## Errore del metodo mid-point

Calcoliamo ora l'andamento dell'errore rispetto alla funzione di riferimento $f(x) = \sin(x)$.

````julia:ex10
steps = [10, 20, 50, 100, 200, 500, 1000]
errors = [abs(midpoint(xsinx, 0, pi / 2, n) - 1) for n in steps]

using Plots
plot(steps, errors, xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "midpoint-error.svg")); # hide
````

\fig{midpoint-error.svg}

Il grafico precedente non è chiaro perché ci sono escursioni di
alcuni ordini di grandezza sia per la variabile $x$ che per la
variabile $y$. Usiamo allora un grafico bilogaritmico, in cui si
rappresentano i punti $(x', y') = (\log x, \log y)$ anziché $(x,
y)$. Questo è l'ideale per i grafici di leggi del tipo $y =
x^\alpha$, come si vede da questi conti:

$$
\begin{aligned}
y &= C x^\alpha,\\
\log y &= \log\left(C x^\alpha\right),\\
\log y &= \alpha \log x + \log C, \\
y' &= \alpha x' + \log C,
\end{aligned}
$$

che è della forma $y' = m x' + q$, ossia una retta, dove il
coefficiente angolare $m$ è proprio l'esponente $\alpha$ che
cerchiamo.

````julia:ex11
using Plots # hide
plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "midpoint-error-log.svg")); # hide
````

\fig{midpoint-error-log.svg}

Dal grafico bilogaritmico è facile stimare $\alpha$: vedete infatti
che sull'asse $x$ c'è una escursione da 10¹ a 10³, quindi **due**
ordini di grandezza, mentre sull'asse $y$ si va da 10⁻² a 10⁻⁶,
ossia **meno quattro** ordini di grandezza. La pendenza della retta,
ossia l'esponente $\alpha$, è il coefficiente angolare degli ordini
di grandezza: $\alpha = -4/2 = -2$, che è esattamente quanto ci
aspettavamo, perché l'errore deve essere $\epsilon \propto N^{-2}$.

Nel vostro codice vorrete probabilmente creare un grafico come
questo. Siccome la realizzazione di grafici può essere complessa, il
mio consiglio è quello di stampare dapprima i numeri a video usando
`cout` o `fmt::print`, e solo una volta che sembrano ragionevoli
procedere a creare il plot. Dovreste quindi scrivere l'equivalente
in C++ del seguente codice Julia:

````julia:ex12
for i in eachindex(steps)  # `i` will go from 1 to the length of `step`
    # In Julia, writing $() in a string means that the expression
    # within parentheses gets evaluated and the result substituted
    # in the string. The '\t' character is the TAB, of course
    println("$(steps[i])\t$(errors[i])")
end
````

Implementiamo ora una funzione che consenta di calcolare rapidamente
l'errore di una funzione di integrazione numerica per un dato numero
di passi di integrazione: ci servirà per studiare non solo il metodo
del mid-point, ma anche i metodi di Simpson e dei trapezi.

Inizializziamo per prima cosa le costanti che caratterizzano il caso
che useremo come esempio, $\int_0^\pi\sin x\,\mathrm{d}x = \pi$: la
funzione da integrare (`REF_FN`), gli estremi (`REF_A` e `REF_B`), e
il valore esatto dell'integrale (`REF_INT`).

````julia:ex13
const REF_FN = xsinx;  # La funzione da integrare
const REF_A = 0;       # Estremo inferiore di integrazione
const REF_B = pi / 2;  # Estremo superiore di integrazione
const REF_INT = 1;     # Valore dell'integrale noto analiticamente
````

La funzione `compute_errors` calcola il valore assoluto della
differenza tra la stima dell'integrale con la funzione `fn` (che può
essere ad esempio `midpoint`) e il valore vero dell'integrale,
`REF_INT`.

````julia:ex14
compute_errors(fn, steps) = [abs(fn(REF_FN, REF_A, REF_B, n) - REF_INT)
                             for n in steps]
````

Applichiamo `compute_errors` alla funzione `midpoint`:

````julia:ex15
errors = compute_errors(midpoint, steps)
````

Come ricavare la legge di potenza dovrebbe essere ovvio dal discorso
fatto sopra circa i grafici bilogaritmici… Se nel grafico
logaritmico la curva si riduce a una retta, basta calcolare la
pendenza della retta passante per i due punti estremi, che in Julia
hanno indice `1` (gli array in Julia non iniziano da 0) e `end` (che
in Julia indica l'ultima posizione in un array):

````julia:ex16
function error_slope(steps, errors)
    deltax = log(steps[end]) - log(steps[1])
    deltay = log(errors[end]) - log(errors[1])

    deltay / deltax
end

error_slope(steps, errors)
````

Domanda: È importante nell'implementazione di `error_slope` sopra
fissare la base del logaritmo, oppure no? In altre parole, si
ottengono risultati diversi se si usa $\log_2$, $\log_{10}$ oppure
$\log_e$?


## Esercizio 7.1 – Integrazione alla Simpson

Testo dell'esercizio:
[carminati-esercizi-07.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-07.html#esercizio-7.1).

Si usa la formula

$$
\int_a^b f(x)\,\mathrm{d}x \approx \left(
\frac13 f(x_0) +
\frac43 f(x_1) +
\frac23 f(x_2) +
\ldots +
\frac43 f(x_{N - 2}) +
\frac13 f(x_{N - 1})
\right) h,
$$

con $x_k = a + k h$.

Come sopra, implementiamo l'algoritmo senza definire classi (come
faremmo in C++), ma scrivendo direttamente una funzione.

````julia:ex17
function simpson(f, a, b, n::Integer)
    # Siccome il metodo funziona solo quando il numero di
    # intervalli è pari, usiamo "truen" anziché "n" nei
    # calcoli sotto
    truen = (n % 2 == 0) ? n : (n + 1)

    h = (b - a) / truen
    acc = 1/3 * (f(a) + f(b))
    for k = 1:(truen - 1)
        acc += 2/3 * (1 + k % 2) * f(a + k * h)
    end

    acc * h
end
````

Verifichiamone il funzionamento sul nostro caso di riferimento.
Anche questi numeri sono utili per implementare degli assert nel
vostro codice C++; in particolare, il metodo di Simpson usa
coefficienti per estremi $f(a)$ e $f(b)$ che sono diversi da quelli
per i punti intermedi, quindi gli ultimi due test sono
particolarmente importanti!

````julia:ex18
println("Primo caso:   ", simpson(xsinx, 0, pi / 2, 10))
println("Secondo caso: ", simpson(xsinx, 0, pi / 2, 100))
println("Terzo caso:   ", simpson(xsinx, 0, 1, 10))
println("Quarto caso:  ", simpson(xsinx, 1, 2, 30))
````

Come ho scritto sopra, stavolta non fornisco gli `assert` da usare
nel vostro codice: dovreste essere in grado di implementarli da soli
usando i quattro risultati. È molto importante che implementiate
tutti e quattro i test, perché in questo modo verificate che la
vostra implementazione consideri correttamente il valore
dell'integranda su più estremi di integrazione.

Passiamo ora a calcolare gli errori del metodo di Simpson, usando
ancora una volta un grafico bilogaritmico.

````julia:ex19
errors = compute_errors(simpson, steps)

plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "simpson-error.svg")); # hide
````

\fig{simpson-error.svg}

Verifichiamo che la pendenza sia quella attesa: l'errore $\epsilon$
dovrebbe essere tale che $\epsilon \propto N^{-4}$.

````julia:ex20
error_slope(steps, errors)
````

## Metodo dei trapezoidi

In questo caso si approssima l'integrale con l'area del trapezio.

````julia:ex21
function trapezoids(f, a, b, n::Integer)
    h = (b - a) / n
    acc = (f(a) + f(b)) / 2
    for k in 1:(n - 1)
        acc += f(a + k * h)
    end

    acc * h
end

println("Primo caso:   ", trapezoids(xsinx, 0, pi / 2, 10))
println("Secondo caso: ", trapezoids(xsinx, 0, pi / 2, 100))
println("Terzo caso:   ", trapezoids(xsinx, 0, 1, 10))
println("Quarto caso:  ", trapezoids(xsinx, 1, 2, 30))
````

Come al solito, usate questi quattro risultati per implementare
degli `assert` nel vostro programma C++.

Facciamo un plot come prima:

````julia:ex22
errors = compute_errors(trapezoids, steps)
plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "trapezoids-error.svg")); # hide
````

\fig{trapezoids-error.svg}

Calcoliamo anche la pendenza della curva $\epsilon \propto N^\alpha$:

````julia:ex23
error_slope(steps, errors)
````

Tracciamo ora un grafico comparativo dei due metodi.

````julia:ex24
plot(steps, compute_errors(midpoint, steps),
     label = "Mid-point",
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi",
     ylabel = "Errore")
plot!(steps, compute_errors(trapezoids, steps),
      label = "Trapezoidi")
plot!(steps, compute_errors(simpson, steps),
      label = "Simpson")

savefig(joinpath(@OUTPUT, "error-comparison.svg")); # hide
````

\fig{error-comparison.svg}

Notate che il metodo del mid-point e dei trapezi hanno la stessa
legge di scala, ma non si sovrappongono: la costante $C$ nella legge
di scala $\epsilon = CN^{-\alpha}$ è diversa (e quindi è diversa
l'intercetta $q = \log_{10} C$ nel grafico bilogaritmico).


## Esercizio 7.2 – Integrazione con trapezoidi a precisione fissata

Testo dell'esercizio:
[carminati-esercizi-07.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-07.html#esercizio-7.2).

L'esercizio 7.2 è diverso dagli esercizi 7.0 e 7.1, perché richiede
di iterare il calcolo finché non si raggiunge una precisione
fissata. Usiamo il suggerimento del testo per non dover ricalcolare
da capo il valore approssimato dell'integrale.

Sfruttiamo la capacità di Julia di esprimere sequenze con la
sintassi `start:delta:end`:

````julia:ex25
# La funzione `collect` obbliga Julia a stampare l'elenco completo
# degli elementi di una lista anziché usare la forma compatta (poco
# interessante in questo caso, perché vogliamo almeno per una volta
# vedere uno per uno gli elementi dell'intervallo 1:2:10)
collect(1:2:10)
````

Ora appare chiaro perché nell'implementare `midpoint`, `simpsons` e
`trapezoids` sopra avevamo dichiarato esplicitamente come `Integer`
il tipo dell'ultimo parametro, `n`: adesso vogliamo invece invocare
`trapezoids` passando la precisione, che indichiamo col tipo
`AbstractFloat`. Questo tipo è analogo a una classe astratta C++ da
cui derivano i tipi floating-point, come `Float16`, `Float32`, e
`Float64`.

````julia:ex26
function trapezoids(f, a, b, prec::AbstractFloat)
    n = 2

    h = (b - a) / n
    # Valore dell'integrale nel caso n = 2
    acc = (f(a) + f(b)) / 2 + f((a + b) / 2)
    newint = acc * h
    while true
        oldint = newint
        n *= 2
        h /= 2

        for k in 1:2:(n - 1) # Just iterate on odd numbers
            acc += f(a + k * h)
        end

        newint = acc * h
        # In Julia, the / operator always returns a floating-point
        # number. This is not true in C++, so remember to write 4.0/3
        if 4/3 * abs(newint - oldint) < prec
            break
        end
    end

    # L'errore 4/3 × (newint - oldint) è teoricamente
    # quello associato al valore `oldint` (che si riferisce
    # al passo h), ma restituiamo `newint` perché comunque
    # l'abbiamo già calcolato, e comunque sicuramente ha
    # un errore ≤ prec.
    newint
end
````

Notate che dopo aver compilato la definizione precedente, Julia ha
scritto `trapezoids (generic function with 2 methods)`. Ha quindi
capito che abbiamo fornito una nuova implementazione di
`trapezoids`, e non ha quindi sovrascritto la vecchia (che accettava
come ultimo argomento un intero, ossia il numero di passaggi).

Per verificare il funzionamento della nuova funzione `trapezoids`,
possiamo verificare che l'integrale calcolato sulla nostra funzione
di riferimento $f(x) = x \sin x$ abbia un errore sempre inferiore alla
precisione richiesta.

````julia:ex27
prec = [1e-1, 1e-2, 1e-3, 1e-4, 1e-5];
values = [trapezoids(REF_FN, REF_A, REF_B, eps) for eps in prec];
errors = [abs(x - REF_INT) for x in values];
````

Stampiamo innanzitutto i valori di `prec` (precisione), `values`
(integrale col metodo dei trapezoidi) ed `errors` (discrepanza dal
valore vero), così che possiate avere dei riferimenti con cui
implementare dei test mediante `assert`:

````julia:ex28
println("Prec\tValue of the integral\tAbsolute error")

for (cur_prec, cur_value, cur_error) in zip(prec, values, errors)
    println("$cur_prec\t$cur_value\t$cur_error")
end
````

Infine, facciamo un grafico bilogaritmico:

````julia:ex29
plot(prec, errors,
     label = "Misurato",
     xscale = :log10, yscale = :log10,
     xlabel = "Precisione impostata",
     ylabel = "Precisione ottenuta")
plot!(prec, prec, label = "Caso teorico peggiore");

savefig(joinpath(@OUTPUT, "trapezoids-vs-theory.svg")); # hide
````

\fig{trapezoids-vs-theory.svg}

## Esercizio 7.3 – Integrazione di una funzione Gaussiana (facoltativo)

Testo dell'esercizio:
[carminati-esercizi-07.html](https://ziotom78.github.io/tnds-tomasi-notebooks/carminati-esercizi-07.html#esercizio-7.3).

Svolgiamo infine l'esercizio facoltativo al termine della lezione.
Incominciamo col definire la funzione Gaussiana, e sfruttiamo la
comoda possibilità che offre Julia di usare lettere greche per i
nomi di variabili:

````julia:ex30
gauss(x, µ, σ) = exp(-(x - µ)^2 / 2σ^2) / sqrt(2π * σ^2)
````

Apparentemente, questa definizione è problematica: la funzione
`gauss` accetta ben tre parametri, ma `midpoint` può integrare solo
le funzioni che accettano **un** parametro! Per risolvere questo
problema, il testo di Carminati suggerisce di passare i valori di
`µ` e `σ` al costruttore della vostra classe `Gaussian`, in modo che
il metodo `Eval` debba accettare solo `x`.

In Julia è tutto molto più semplice grazie alla sintassi `x ->
espressione`, che crea una funzione anonima usa-e-getta. Ad esempio,
per calcolare l'integrale della Gaussiana usando Simpson e passando
un intervallo ampio, possiamo verificare se la normalizzazione
è corretta:

````julia:ex31
simpson(x -> gauss(x, 1.0, 2.0), -10.0, 10.0, 1000)
````

Il risultato è approssimativamente 1, il che vuol dire che abbiamo
implementato correttamente la Gaussiana.

Il grafico dell'integrale col metodo dei trapezoidi è banale da
produrre; assumiamo che $\mu = 0$ e $\sigma = 1$, e usiamo
l'istruzione `let` per definire variabili che verranno “distrutte”
quando si arriva all'`end` finale:

````julia:ex32
let µ = 0.0, σ = 1.0
  # Do *not* start from t = 0, as the Gaussian is undefined
  # when σ = 0!
  list_of_t = 0.1:0.1:5.0
  list_of_y = [trapezoids(x -> gauss(x, µ, σ), -t * σ, t * σ, 1e-5)
               for t in list_of_t]

  plot(list_of_t, list_of_y,
       label = "",
       xlabel = "Numero di σ",
       ylabel = "Probabilità")
  savefig(joinpath(@OUTPUT, "exercise-7.3.svg")); # hide
end
; # hide
````

\fig{exercise-7.3.svg}

