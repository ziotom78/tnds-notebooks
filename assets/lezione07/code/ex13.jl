# This file was generated, do not modify it. # hide
compute_errors(fn, steps) = [abs(fn(REF_FN, REF_A, REF_B, n) - REF_INT)
                             for n in steps]