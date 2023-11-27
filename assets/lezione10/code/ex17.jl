# This file was generated, do not modify it. # hide
glc = GLC(1)
# Array di *due* elementi
vec = Array{Float64}(undef, 2)
# Chiediamo che in ogni elemento vengano sommati *cinque*
# numeri. Quindi ogni elemento di `vec` sarà un numero
# casuale nell'intervallo 0…5.
computesums!(glc, 5, vec)
println("vec[1] = ", vec[1])
println("vec[2] = ", vec[2])