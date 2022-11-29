# This file was generated, do not modify it. # hide
println("Prec\tValue of the integral\tAbsolute error")

for (cur_prec, cur_value, cur_error) in zip(prec, values, errors)
    println("$cur_prec\t$cur_value\t$cur_error")
end