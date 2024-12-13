# This file was generated, do not modify it. # hide
anim = Luxor.Movie(500, 500, "Pendulum")

function animframe(scene, framenumber)
    Luxor.background("white")
    plot_pendulum(pos[framenumber])
end

Luxor.animate(anim, [Luxor.Scene(anim, animframe, 1:size(times, 1))],
    creategif=true, pathname=joinpath(@OUTPUT, "pendulum.gif"));