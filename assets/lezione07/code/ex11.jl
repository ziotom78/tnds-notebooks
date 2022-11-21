# This file was generated, do not modify it. # hide
for i in eachindex(steps)  # `i` will go from 1 to the length of `step`
    # In Julia, writing $() in a string means that the expression
    # within parentheses gets evaluated and the result substituted
    # in the string. The '\t' character is the TAB, of course
    println("$(steps[i])\t$(errors[i])")
end