# This file was generated, do not modify it. # hide
function trapezoids(f, a, b, n::Integer)
    h = (b - a) / n
    acc = (f(a) + f(b)) / 2
    for k in 1:(n - 1)
        acc += f(a + k * h)
    end

    acc * h
end

println("Primo caso:   ", trapezoids(xsinx, 0, pi, 10))
println("Secondo caso: ", trapezoids(xsinx, 0, pi, 100))
println("Terzo caso:   ", trapezoids(xsinx, 0, 1, 10))
println("Quarto caso:  ", trapezoids(xsinx, 1, 2, 30))