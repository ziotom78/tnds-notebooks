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