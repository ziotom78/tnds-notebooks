# This file was generated, do not modify it. # hide
prec = [1e-1, 1e-2, 1e-3, 1e-4, 1e-5];
values = [trapezoids(REF_FN, REF_A, REF_B, eps) for eps in prec];
errors = [abs(x - REF_INT) for x in values];