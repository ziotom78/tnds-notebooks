# This file was generated, do not modify it. # hide
"""
    randexp(glc::GLC)

Return a positive pseudo-random number distributed with a
probability density ``p(x) = λ e^{-λ x}``.
"""
randexp(glc::GLC, λ) = -log(1 - rand(glc)) / λ