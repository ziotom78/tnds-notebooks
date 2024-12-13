# This file was generated, do not modify it. # hide
for i in (length(times) - 5):length(times)
    @printf("%.2f\t%f\t%f\n", times[i], pos[i], vel[i])
end