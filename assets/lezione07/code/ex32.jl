# This file was generated, do not modify it. # hide
list_of_t = 0.0:0.1:5.0
list_of_y = [trapezoids(x -> gauss(x, 0.0, t), 1e-5) for t in list_of_t]

plot(list_of_t, list_of_y,
     label = "",
     xlabel = "Numero di σ",
     ylabel = "Probabilità")