# This file was generated, do not modify it. # hide
function eqdiff_simulation(method_fn, problem_fn, x0, t0, tf, h)
    nsteps = num_of_steps(t0, tf, h)

    times = zeros(Float64, nsteps + 1)
    pos = zeros(Float64, nsteps + 1)
    vel = zeros(Float64, nsteps + 1)

    times[1] = t0
    pos[1] = x0[1]
    vel[1] = x0[2]

    t = t0
    x = x0
    for i = 1:nsteps
        x = method_fn(problem_fn, x, t, h)
        t += h

        times[i + 1] = t
        pos[i + 1] = x[1]
        vel[i + 1] = x[2]
    end

    return (times, pos, vel)
end