# This file was generated, do not modify it. # hide
@printf("%-14s\t%-14s\n", "δt [s]", "x(70) [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\n", deltat[i], lastpos[i])
end