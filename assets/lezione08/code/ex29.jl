# This file was generated, do not modify it. # hide
anim = @animate for h in deltat
    cur_result = eqdiff_simulation(
        rungekutta,
        oscillatore,
        [0., 1.],
        0.0,
        70.0,
        h,
    )
    plot(times, pos,
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(times, sin.(times), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "rk.gif"), fps = 1);