# This file was generated, do not modify it. # hide
anim = @animate for h in deltat
    result = euler(oscillatore, [0., 1.], 0.0, 70.0, h)
    plot(result[:, 1], result[:, 2],
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(result[:, 1], sin.(result[:, 1]), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "euler.gif"), fps = 1);