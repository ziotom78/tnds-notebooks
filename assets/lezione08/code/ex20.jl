# This file was generated, do not modify it. # hide
lastpos = [euler_simulation([0.0, 1.0], 0, lastt, h)[2][end] for h in deltat]
error_euler = abs.(lastpos .- sin(lastt))

@printf("%-14s\t%-14s%-14s\n", "δt [s]", "x(t = 70 s) [m]", "x vero [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\t%.12f\n", deltat[i], lastpos[i], sin(lastt))
end