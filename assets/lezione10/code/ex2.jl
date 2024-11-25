# This file was generated, do not modify it. # hide
mutable struct GLC
    a::UInt32
    c::UInt32
    m::UInt32
    seed::UInt32

    GLC(myseed) = new(1664525, 1013904223, 1 << 31, myseed)
end