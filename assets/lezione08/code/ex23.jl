# This file was generated, do not modify it. # hide
anim = @animate for h in deltat
    cur_result = rungekutta(oscillatore, [0., 1.], 0.0, 70.0, h)
    plot(cur_result[:, 1], cur_result[:, 2],
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(cur_result[:, 1], sin.(cur_result[:, 1]), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "rk.gif"), fps = 1);