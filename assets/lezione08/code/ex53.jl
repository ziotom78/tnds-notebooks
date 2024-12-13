# This file was generated, do not modify it. # hide
# Aggiungiamo 0.01 agli estremi (9 e 11) per evitare la condizione di risonanza
freq = 9.01:0.05:11.01
ampl = [forced_pendulum_amplitude(ω) for ω in freq]

@printf("%14s\t%-14s\n", "ω [Hz]", "Ampiezza [m]")
for i in eachindex(freq)
    @printf("%14.2f\t%.9f\n", freq[i], ampl[i])
end

plot(freq, ampl,
     label="", xlabel="Frequenza [rad/s]", ylabel="Ampiezza");
scatter!(freq, ampl, label="");

savefig(joinpath(@OUTPUT, "forced-pendulum-resonance.svg")) # hide