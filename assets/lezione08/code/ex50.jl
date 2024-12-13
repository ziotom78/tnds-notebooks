# This file was generated, do not modify it. # hide
# Usiamo `_` per indicare che non ci interessa salvare la velocità
# in una variabile, e usiamo una funzione “lambda”
(time, pos, _) = eqdiff_simulation(
    rungekutta,
    (time, x) -> forcedpendulum(time, x, 8.0),
    [0., 0.],
    0.,
    endt,
    0.1,
)

plot(time, pos, label="", xlabel="Tempo [s]", ylabel="Posizione [m]");

savefig(joinpath(@OUTPUT, "forced-pendulum.svg")) # hide