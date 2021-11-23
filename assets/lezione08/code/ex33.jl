# This file was generated, do not modify it. # hide
function plot_pendulum(angle)
    radius = 200  # Lunghezza del braccio del pendolo
    y, x = radius .* sincos(π / 2 + angle)

    Luxor.sethue("black")
    Luxor.line(Luxor.Point(0, 0), Luxor.Point(x, y), :stroke)
    Luxor.circle(Luxor.Point(x, y), 10, :fill)
end