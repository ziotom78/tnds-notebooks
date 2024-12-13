# This file was generated, do not modify it. # hide
times, pos, vel = eqdiff_simulation(
    rungekutta,
    pendulum,
    [π / 3, 0.],
    0.0,
    3.0,
    0.01,
)

using Printf

for i in 1:5
    @printf("%.2f\t%f\t%f\n", times[i], pos[i], vel[i])
end