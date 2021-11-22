# This file was generated, do not modify it. # hide
# Aggiungiamo 0.01 agli estremi (9 e 11) per evitare la condizione di risonanza
freq = 9.01:0.1:11.01
println("The frequencies to be sampled are: $(collect(freq))")
ampl = [forced_amplitude(ω, forcedpendulum(ω)) for ω in freq]
plot(freq, ampl,
     label="", xlabel="Frequenza [rad/s]", ylabel="Ampiezza")
scatter!(freq, ampl, label="")

savefig(joinpath(@OUTPUT, "forced-pendulum-resonance.svg")) # hide