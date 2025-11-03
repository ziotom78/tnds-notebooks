# This file was generated, do not modify it. # hide
function simpson(f, a, b, n::Integer)
    # Siccome il metodo funziona solo quando il numero di
    # intervalli è pari, usiamo "truen" anziché "n" nei
    # calcoli sotto
    truen = (n % 2 == 0) ? n : (n + 1)

    h = (b - a) / truen
    # In Julia, 1/3 viene interpretato come 1.0 / 3.0
    # (a differenza del C++)
    acc = 1/3 * (f(a) + f(b))
    for k = 1:(truen - 1)
        acc += 2/3 * (1 + k % 2) * f(a + k * h)
    end

    acc * h
end