# This file was generated, do not modify it. # hide
oscillations = rungekutta(pendulum, [π / 3, 0.], 0.0, 3.0, 0.01)
oscillations[1:10, :]