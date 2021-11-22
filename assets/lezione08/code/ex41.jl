# This file was generated, do not modify it. # hide
interp(ptA, ptB, x) = ptA[1] + (ptA[1] - ptB[1]) / (ptA[2] - ptB[2]) * (x - ptA[2])
interp(ptA, ptB) = interp(ptA, ptB, 0)