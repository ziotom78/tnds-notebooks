# This file was generated, do not modify it. # hide
(time_euler, pos_euler, vel_euler) = euler_simulation(
    [0.0, 1.0],
    0.0,
    lastt,
    h,
);
(time_eqdiff, pos_eqdiff, vel_eqdiff) = eqdiff_simulation(
    euler,
    oscillatore,
    [0.0, 1.0],
    0.0,
    lastt,
    h,
);