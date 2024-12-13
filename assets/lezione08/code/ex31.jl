# This file was generated, do not modify it. # hide
@printf("%-14s\t%-14s\t%-14s\n", "δt [s]", "x(t = 70 s) [m]", "x vero [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\t%.12f\n", deltat[i], lastpos[i], sin(lastt))
end