# This file was generated, do not modify it. # hide
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