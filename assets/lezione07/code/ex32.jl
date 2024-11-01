# This file was generated, do not modify it. # hide
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