# This file was generated, do not modify it. # hide
using Plots

anim = @animate for h in deltat
    (time, pos, vel) = euler_simulation([0.0, 1.0], 0.0, lastt, h)
    plot(time, pos,
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(time, sin.(time), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "euler.gif"), fps = 1);