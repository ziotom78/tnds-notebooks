# This file was generated, do not modify it. # hide
v_L(R, η) = 2R^2 / (9η) * (ρ - ρ0) * g;
Δt(R, Δx, η) = Δx / v_L(R, η);
Δt_true = Float64[Δt(R, Δx_true, η_true) for R in R_true];
η(R, Δt, Δx) = 2R^2 * g * Δt / (9Δx) * (ρ - ρ0);