# This file was generated, do not modify it. # hide
lastpos = [rungekutta(oscillatore, [0., 1.], 0.0, lastt, h)[end, 2] for h in deltat]
error_rk = abs.(lastpos .- sin(lastt))