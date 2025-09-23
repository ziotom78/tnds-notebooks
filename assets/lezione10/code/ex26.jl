# This file was generated, do not modify it. # hide
println("N       Errore")
for (cur_n, cur_err) in zip(list_of_N, list_of_errors)
    @printf("%d\t%.5f\n", cur_n, cur_err)
end