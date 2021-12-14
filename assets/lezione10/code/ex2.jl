# This file was generated, do not modify it. # hide
mutable struct GLC
    a::UInt64
    c::UInt64
    m::UInt64
    seed::UInt64

    GLC(myseed) = new(1664525, 1013904223, 1 << 31, myseed)
end