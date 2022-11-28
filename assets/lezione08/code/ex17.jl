# This file was generated, do not modify it. # hide
lastpos = [euler(oscillatore, [0., 1.], 0.0, lastt, h)[end, 2] for h in deltat]
error_euler = abs.(lastpos .- sin(lastt))

@printf("%-14s\t%-14s\n", "δt [s]", "x(70) [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\n", deltat[i], lastpos[i])
end