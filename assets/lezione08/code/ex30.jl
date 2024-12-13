# This file was generated, do not modify it. # hide
lastpos = [
    eqdiff_simulation(
        rungekutta,
        oscillatore,
        [0., 1.],
        0.0,
        lastt,
        h,
    )[2][end] for h in deltat
]
error_rk = abs.(lastpos .- sin(lastt))