# This file was generated, do not modify it. # hide
plot(prec, errors,
     label = "Misurato",
     xscale = :log10, yscale = :log10,
     xlabel = "Precisione impostata",
     ylabel = "Precisione ottenuta")
plot!(prec, prec, label = "Caso teorico peggiore");

savefig(joinpath(@OUTPUT, "trapezoids-vs-theory.svg")); # hide