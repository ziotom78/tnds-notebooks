# This file was generated, do not modify it.

import Statistics

# In C++ si sarebbe scritto: Statistics::mean
# ("Statistics" è un namespace)
Statistics.mean([1, 2, 3])

using Statistics

# Non è più necessario scrivere `Statistics.mean`
mean([1, 2, 3])

using Plots

function midpoint(f, a, b, n::Integer)
    h = (b - a) / n
    h * sum([f(a + (k + 0.5) * h) for k in 0:(n - 1)])
end

midpoint(sin, 0, pi, 10)

midpoint(sin, 0, pi, 100)

midpoint(sin, pi, 0, 10)

println("Primo integrale:   ", midpoint(sin, 0, 1, 10))
println("Secondo integrale: ", midpoint(sin, 1, 2, 30))

steps = [10, 50, 100, 500, 1000]
errors = [abs(midpoint(sin, 0, pi, n) - 2) for n in steps]

plot(steps, errors, xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "midpoint-error.svg")) # hide

plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "midpoint-error-log.svg")) # hide

for i in eachindex(steps)  # `i` will go from 1 to the length of `step`
    # In Julia, writing $() in a string means that the expression
    # within parentheses gets evaluated and the result substituted
    # in the string. The '\t' character is the TAB, of course
    println("$(steps[i])\t$(errors[i])")
end

const REF_FN = sin;  # La funzione da integrare
const REF_A = 0;     # Estremo inferiore di integrazione
const REF_B = pi;    # Estremo superiore di integrazione
const REF_INT = 2.;  # Valore dell'integrale noto analiticamente

compute_errors(fn, steps) = [abs(fn(REF_FN, REF_A, REF_B, n) - REF_INT)
                             for n in steps]

errors = compute_errors(midpoint, steps)

function error_slope(steps, errors)
    deltax = log(steps[end]) - log(steps[1])
    deltay = log(errors[end]) - log(errors[1])

    deltay / deltax
end

error_slope(steps, errors)

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

println("Primo caso:   ", simpson(sin, 0, pi, 10))
println("Secondo caso: ", simpson(sin, 0, pi, 100))
println("Terzo caso:   ", simpson(sin, 0, 1, 10))
println("Quarto caso:  ", simpson(sin, 1, 2, 30))

errors = compute_errors(simpson, steps)

plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "simpson-error.svg")) # hide

error_slope(steps, errors)

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

errors = compute_errors(trapezoids, steps)
plot(steps, errors,
     xscale = :log10, yscale = :log10,
     xlabel = "Numero di passi", ylabel = "Errore")

savefig(joinpath(@OUTPUT, "trapezoids-error.svg")) # hide

error_slope(steps, errors)

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

# La funzione `collect` obbliga Julia a stampare l'elenco completo
# degli elementi di una lista anziché usare la forma compatta (poco
# interessante in questo caso, perché vogliamo almeno per una volta
# vedere uno per uno gli elementi dell'intervallo 1:2:10)
collect(1:2:10)

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

    newint
end

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

