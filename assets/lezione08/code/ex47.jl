# This file was generated, do not modify it. # hide
angles = 0.1:0.1:3.0
ampl = [period(angle) for angle in angles]

@printf("%14s\t%-14s\n", "Angolo [rad]", "Periodo [s]")
for i in eachindex(angles)
    @printf("%14.1f\t%.7f\n", angles[i], ampl[i])
end

plot(angles, ampl, label="", xlabel="Angolo [rad]", ylabel="Periodo [s]");
scatter!(angles, ampl, label="");
savefig(joinpath(@OUTPUT, "period-vs-angle.svg")); # hide