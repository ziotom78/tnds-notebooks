# This file was generated, do not modify it. # hide
function forcedpendulum(
    ω;
    init = [0., 0.],
    startt = 0.,
    endt = 600.0,  # Deve essere ≫ 1/α
    deltat = 0.01,
)
    rungekutta(init, startt, endt, deltat) do t, x
        [x[2], -ω0^2 * x[1] - α * x[2] + sin(ω * t)]
    end
end