# This file was generated, do not modify it. # hide
forcedpendulum(time, x, ω) = [
    x[2],
    -ω0^2 * x[1] - α * x[2] + sin(ω * time),
]