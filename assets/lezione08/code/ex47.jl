# This file was generated, do not modify it. # hide
angles = 0.1:0.1:3.0
ampl = [period(rungekutta(pendulum, [angle, 0.], 0.0, 3.0, 0.01)) for angle in angles]
plot(angles, ampl, label="", xlabel="Angolo [rad]", ylabel="Periodo [s]")
scatter!(angles, ampl, label="")

savefig(joinpath(@OUTPUT, "period-vs-angle.svg")) # hide