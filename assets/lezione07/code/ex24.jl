# This file was generated, do not modify it. # hide
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

        for k in 1:2:(n - 1) # Itera solo sui numeri dispari
            acc += f(a + k * h)
        end

        newint = acc * h
        # 4//3 è la frazione 4/3 in Julia. In C++ *non* scrivete
        # 4/3, perché sarebbe una divisione intera: scrivete 4.0/3
        if 4//3 * abs(newint - oldint) < prec
            break
        end
    end

    newint
end