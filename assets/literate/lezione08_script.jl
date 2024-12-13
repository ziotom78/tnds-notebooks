# This file was generated, do not modify it.

t = 0
h = 0.1
t += h

t += h
t += h

function simulate(t0, tf, h)
    t = t0

    println("Inizia la simulazione, da t=$t0 a $tf con h=$h")

    # Itera finché non abbiamo raggiunto il tempo finale
    while t < tf
        println("  t = $t")
        t += h
    end

    println("Simulazione terminata a t = $t")
end

simulate(0.0, 1.0, 0.1)

num_of_steps(t0, tf, h) = round(Int, (tf - t0) / h)

function simulate_method1(t0, tf, h)
    println("Inizia la simulazione, da t=$t0 a $tf con h=$h")

    # Calcola il numero di iterazioni prima di iniziare il ciclo
    # vero e proprio
    nsteps = num_of_steps(t0, tf, h)
    t = t0
    for i = 1:nsteps
        println("  t = $t")
        # Incrementa come al solito
        t += h
    end
    println("Simulazione terminata a t = $t")
end

simulate_method1(0, 1, 0.1)

function simulate_method2(t0, tf, h)
    println("Inizia la simulazione, da t=$t0 a $tf con h=$h")

    # Calcola il numero di iterazioni prima di iniziare il ciclo vero
    # e proprio
    nsteps = num_of_steps(t0, tf, h)
    t = t0
    for i = 1:nsteps
        println("  t = $t")
        # Ricalcola t partendo da t0 e da h, usando il contatore i
        t = t0 + i * h
    end
    println("Simulazione terminata a t = $t")
end

simulate_method2(0, 1, 0.1)

[1, 2, 4] .+ [3, 7, -5]

# Applica la funzione `log10` a tutti gli elementi dell'array
log10.([1, 2, 4])

euler(fn, x, t, h) = x .+ fn(t, x) .* h

oscillatore(time, x) = [x[2], -x[1]]  # ω0 = 1

h = 0.1
result = euler(oscillatore, [0., 1.], 0., h)

# Al posto della condizione iniziale, passiamo `result` (la
# soluzione al tempo t=h), e al posto del tempo 0.0 passiamo
# il tempo 0.0+h
result = euler(oscillatore, result, 0. + h, h)

lastt = 70.0;

function euler_simulation(x0, t0, tf, h)
    # Calcola il numero di iterazioni prima di iniziare il ciclo vero
    # e proprio
    nsteps = num_of_steps(t0, tf, h)

    # I tre vettori hanno `N + 1` elementi e non `N`, perché vogliamo
    # memorizzare anche la condizione iniziale.
    times = zeros(Float64, nsteps + 1)
    pos = zeros(Float64, nsteps + 1)
    vel = zeros(Float64, nsteps + 1)

    # Salviamo la condizione iniziale
    times[1] = t0
    pos[1] = x0[1]
    vel[1] = x0[2]

    t = t0
    x = x0
    for i = 1:nsteps
        x = euler(oscillatore, x, t, h)
        t += h

        times[i + 1] = t
        pos[i + 1] = x[1]
        vel[i + 1] = x[2]
    end

    # Contrariamente al C++, una funzione Julia può restituire
    # più di un valore
    return (times, pos, vel)
end

times, pos, vel = euler_simulation([0.0, 1.0], 0.0, lastt, 0.1);

using Printf

for i in 1:5
    @printf("%.2f\t%f\t%f\n", times[i], pos[i], vel[i])
end

for i in (length(times) - 5):length(times)
    @printf("%.2f\t%f\t%f\n", times[i], pos[i], vel[i])
end

nsteps = 7 * round.(Int, exp10.(2:0.2:4))

deltat = lastt ./ nsteps

using Plots

anim = @animate for h in deltat
    (time, pos, vel) = euler_simulation([0.0, 1.0], 0.0, lastt, h)
    plot(time, pos,
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(time, sin.(time), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "euler.gif"), fps = 1);

lastpos = [euler_simulation([0.0, 1.0], 0, lastt, h)[2][end] for h in deltat]
error_euler = abs.(lastpos .- sin(lastt))

@printf("%-14s\t%-14s%-14s\n", "δt [s]", "x(t = 70 s) [m]", "x vero [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\t%.12f\n", deltat[i], lastpos[i], sin(lastt))
end

plot(deltat, error_euler,
     xscale = :log10, yscale = :log10,
     xlabel = "Passo d'integrazione",
     ylabel = @sprintf("Errore a t = %.1f", lastt),
     label = "")
scatter!(deltat, error_euler, label = "");

savefig(joinpath(@OUTPUT, "euler_error.svg")) # hide

function rungekutta(fn, x, t, h)
    k1 = fn(t, x)
    k2 = fn(t + h / 2.0, x .+ k1 .* h / 2.0)
    k3 = fn(t + h / 2.0, x .+ k2 .* h / 2.0)
    k4 = fn(t + h, x .+ k3 .* h)

    x .+ (k1 .+ 2k2 .+ 2k3 .+ k4) .* h / 6
end

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

maximum(abs.(pos_euler .- pos_eqdiff))

(time, pos, vel) = eqdiff_simulation(
    rungekutta,
    oscillatore,
    [0., 1.],
    0.0,
    70.0,
    0.1,
);

using Printf

for i in 1:5
    @printf("%.2f\t%f\t%f\n", times[i], pos[i], vel[i])
end

for i in (length(times) - 5):length(times)
    @printf("%.2f\t%f\t%f\n", times[i], pos[i], vel[i])
end

anim = @animate for h in deltat
    cur_result = eqdiff_simulation(
        rungekutta,
        oscillatore,
        [0., 1.],
        0.0,
        70.0,
        h,
    )
    plot(times, pos,
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(times, sin.(times), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "rk.gif"), fps = 1);

lastpos = [
    eqdiff_simulation(
        rungekutta,
        oscillatore,
        [0., 1.],
        0.0,
        lastt,
        h,
    )[2][end] for h in deltat
]
error_rk = abs.(lastpos .- sin(lastt))

@printf("%-14s\t%-14s\t%-14s\n", "δt [s]", "x(t = 70 s) [m]", "x vero [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\t%.12f\n", deltat[i], lastpos[i], sin(lastt))
end

plot(deltat, error_euler, label = "")
scatter!(deltat, error_euler, label = "Eulero")

plot!(deltat, error_rk,
     xscale = :log10, yscale = :log10,
     xlabel = "Passo d'integrazione",
     ylabel = @sprintf("Errore a t = %.1f", lastt),
     label = "")
scatter!(deltat, error_rk, label = "Runge-Kutta")

savefig(joinpath(@OUTPUT, "euler_rk_comparison.svg")) #hide

rodlength = 1.;
g = 9.81;

pendulum(t, x) = [x[2], -g / rodlength * sin(x[1])]

times, pos, vel = eqdiff_simulation(
    rungekutta,
    pendulum,
    [π / 3, 0.],
    0.0,
    3.0,
    0.01,
)

using Printf

for i in 1:5
    @printf("%.2f\t%f\t%f\n", times[i], pos[i], vel[i])
end

for i in (length(times) - 5):length(times)
    @printf("%.2f\t%f\t%f\n", times[i], pos[i], vel[i])
end

import Luxor

function plot_pendulum(angle)
    radius = 200  # Lunghezza del braccio del pendolo
    y, x = radius .* sincos(π / 2 + angle)

    Luxor.sethue("black")
    Luxor.line(Luxor.Point(0, 0), Luxor.Point(x, y), :stroke)
    Luxor.circle(Luxor.Point(x, y), 10, :fill)
end

size(times, 1)

anim = Luxor.Movie(500, 500, "Pendulum")

function animframe(scene, framenumber)
    Luxor.background("white")
    plot_pendulum(pos[framenumber])
end

Luxor.animate(anim, [Luxor.Scene(anim, animframe, 1:size(times, 1))],
    creategif=true, pathname=joinpath(@OUTPUT, "pendulum.gif"));

plot(times, pos,
     label = "",
     xlabel = "Tempo [s]",
     ylabel = "Velocità angolare [rad/s]");

savefig(joinpath(@OUTPUT, "oscillations1.svg")) # hide

interp(ptA, ptB, ω) = ptA[1] - (ptA[1] - ptB[1]) / (ptA[2] - ptB[2]) * (ptA[2] - ω)

interp(ptA, ptB) = interp(ptA, ptB, 0)

let p1x = -0.4, p1y = -0.7, p2x = 0.5, p2y = 0.8, y = 0.3
    # Il comando `plot` richiede di passare un array con le ascisse
    # e uno con le coordinate…
    plot([p1x, p2x], [p1y, p2y], label = "")
    # …mentre la nostra `interp` richiede due coppie (x, y)
    let x = interp([p1x, p1y], [p2x, p2y], y)
        @printf("La retta interpolante passa per (%.1f, %.1f)\n", x, y)
        # Il comando `scatter` funziona come `plot`
        scatter!([p1x, x, p2x], [p1y, y, p2y], label = "")
    end
end

savefig(joinpath(@OUTPUT, "interp-test.svg")) # hide

function period(θ₀; h = 0.01)
    # Simuliamo finché ω non diventa negativa

    x = [θ₀, 0.]
    oldx = [0., 0.]
    t = 0.0
    while x[2] ≤ 0
        oldx = x  # Ci serve poi per fare l'interpolazione
        x = rungekutta(pendulum, x, t, h)
        t += h
    end

    # A questo punto, t è un po' più di un semiperiodo.

    # Calcoliamo mediante interpolazione l'istante in cui
    # si è avuto ω=0
    t_semip = interp((t - h, oldx[2]), (t, x[2]))

    # Il periodo è due volte il semiperiodo
    return 2t_semip
end

ideal_period = 2π / √(g / rodlength)

angles = 0.1:0.1:3.0
ampl = [period(angle) for angle in angles]

@printf("%14s\t%-14s\n", "Angolo [rad]", "Periodo [s]")
for i in eachindex(angles)
    @printf("%14.1f\t%.7f\n", angles[i], ampl[i])
end

plot(angles, ampl, label="", xlabel="Angolo [rad]", ylabel="Periodo [s]");
scatter!(angles, ampl, label="");
savefig(joinpath(@OUTPUT, "period-vs-angle.svg")) # hide

ω0 = 10;
α = 1.0 / 30;
endt = 600.0;

forcedpendulum(time, x, ω) = [
    x[2],
    -ω0^2 * x[1] - α * x[2] + sin(ω * time),
]

# Usiamo `_` per indicare che non ci interessa salvare la velocità
# in una variabile, e usiamo una funzione “lambda”
(time, pos, _) = eqdiff_simulation(
    rungekutta,
    (time, x) -> forcedpendulum(time, x, 8.0),
    [0., 0.],
    0.,
    endt,
    0.1,
)

plot(time, pos, label="", xlabel="Tempo [s]", ylabel="Posizione [m]");

savefig(joinpath(@OUTPUT, "forced-pendulum.svg")) # hide

function forced_pendulum_amplitude(ω)
    # In Julia posso assegnare a una variabile la definizione di una
    # funzione!
    fn = (time, x) -> forcedpendulum(time, x, ω)

    # Step 1: lascio che la simulazione proceda finché l'oscillatore
    # non si stabilizza

    x = [0., 0.]
    t = 0.0

    while t < 15 / α
        x = rungekutta(fn, x, t, h)
        t += h
    end

    # Step 2: continuo a simulare finché il segno della velocità non
    # si inverte

    oldx = [0., 0.]
    while true
        oldx = x
        x = rungekutta(fn, x, t, h)
        t += h

        if x[2] * oldx[2] < 0
            break
        end
    end

    # Step 3: eseguo una interpolazione per sapere di quanto
    # “arretrare” col tempo. Dovrà essere per forza h_new < 0
    h_new = interp((-h, oldx[2]), (0, x[2]))
    @assert h_new < 0

    x = rungekutta(fn, x, t, h_new)

    # Devo usare `abs`: non so a priori se il corpo sarà a destra o a
    # sinistra dello zero
    return abs(x[1])
end

forced_pendulum_amplitude(9.5)

# Aggiungiamo 0.01 agli estremi (9 e 11) per evitare la condizione di risonanza
freq = 9.01:0.05:11.01
ampl = [forced_pendulum_amplitude(ω) for ω in freq]

@printf("%14s\t%-14s\n", "ω [Hz]", "Ampiezza [m]")
for i in eachindex(freq)
    @printf("%14.2f\t%.9f\n", freq[i], ampl[i])
end

plot(freq, ampl,
     label="", xlabel="Frequenza [rad/s]", ylabel="Ampiezza");
scatter!(freq, ampl, label="");

savefig(joinpath(@OUTPUT, "forced-pendulum-resonance.svg")) # hide
