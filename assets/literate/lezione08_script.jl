# This file was generated, do not modify it.

using Plots
using Printf

t = 0
h = 0.1
t += h

t += h

# Esegue per `nruns` volte l'incremento `increment`, partendo da
# `start`
function simulate(nruns, start, increment)
    t = start
    for i in 1:nruns
        t += increment
    end
    println("Incrementando di $increment per $nruns volte, il risultato è $t")
end

simulate(10, 0, h)

function simulate(t0, tf, increment)
    t = t0

    println("Inizia la simulazione, da t=$t0 a $tf con h=$increment")

    # Itera finché non abbiamo raggiunto il tempo finale
    while t < tf
        println("  t = $t")
        t += increment
    end

    println("Simulazione terminata a t = $t")
end

simulate(0.0, 1.0, 0.1)

function simulate_method1(t0, tf, increment)
    println("Inizia la simulazione, da t=$t0 a $tf con h=$increment")

    # Calcola il numero di iterazioni prima di iniziare il ciclo vero e proprio
    nsteps = round(Int, (tf - t0) / h)
    t = t0
    for i = 1:nsteps
        println("  t = $t")
        # Incrementa come al solito
        t += h
    end
    println("Simulazione terminata a t = $t")
end

simulate_method1(0, 1, 0.1)

function simulate_method2(t0, tf, increment)
    println("Inizia la simulazione, da t=$t0 a $tf con h=$increment")

    # Calcola il numero di iterazioni prima di iniziare il ciclo vero
    # e proprio
    nsteps = round(Int, (tf - t0) / h)
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

function euler(fn, x0, startt, endt, h)
    # La scrittura startt:h:endt indica il vettore
    #
    #     [startt, startt + h, startt + 2h, startt + 3h, …, startt + N * h]
    #
    # dove N è il più grande intero tale che
    #
    #     startt + N * h ≤ endt
    timerange = startt:h:endt
    result = Array{Float64}(undef, length(timerange), 1 + length(x0))
    cur = x0
    for (i, t) in enumerate(timerange)
        result[i, 1] = t
        result[i, 2:end] = cur
        cur .+= fn(t, cur) * h
    end

    result
end

oscillatore(time, x) = [x[2], -x[1]]  # ω0 = 1

h = 0.1
result = euler(oscillatore, [0., 1.], 0.0, 70.0, h);

result[1:10, :]

result[(end - 10):end, :]

lastt = 70.0;

nsteps = 7 * round.(Int, exp10.(2:0.2:4))

deltat = lastt ./ nsteps

anim = @animate for h in deltat
    result = euler(oscillatore, [0., 1.], 0.0, 70.0, h)
    plot(result[:, 1], result[:, 2],
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(result[:, 1], sin.(result[:, 1]), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "euler.gif"), fps = 1);

lastpos = [euler(oscillatore, [0., 1.], 0.0, lastt, h)[end, 2] for h in deltat]
error_euler = abs.(lastpos .- sin(lastt))

@printf("%-14s\t%-14s\n", "δt [s]", "x(70) [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\n", deltat[i], lastpos[i])
end

plot(deltat, error_euler,
     xscale = :log10, yscale = :log10,
     xlabel = "Passo d'integrazione",
     ylabel = @sprintf("Errore a t = %.1f", lastt),
     label = "")
scatter!(deltat, error_euler, label = "")

savefig(joinpath(@OUTPUT, "euler_error.svg")) # hide

function rungekutta(fn, x0, startt, endt, h)
    timerange = startt:h:endt
    result = Array{Float64}(undef, length(timerange), 1 + length(x0))
    cur = copy(x0)
    for (i, t) in enumerate(timerange)
        result[i, 1] = t
        result[i, 2:end] = cur

        k1 = fn(t,          cur)
        k2 = fn(t + h / 2., cur .+ k1 .* h / 2.0)
        k3 = fn(t + h / 2., cur .+ k2 .* h / 2.0)
        k4 = fn(t + h,      cur .+ k3 .* h)

        cur .+= (k1 .+ 2k2 .+ 2k3 .+ k4) .* h / 6
    end

    result
end

result = rungekutta(oscillatore, [0., 1.], 0.0, 70.0, 0.1);

result[1:10, :]

result[(end - 10):end, :]

anim = @animate for h in deltat
    cur_result = rungekutta(oscillatore, [0., 1.], 0.0, 70.0, h)
    plot(cur_result[:, 1], cur_result[:, 2],
         title = @sprintf("h = %.5f", h),
         label="Eulero", ylim=(-2, 2),
         xlabel="Tempo [s]", ylabel="Posizione [m]")
    plot!(cur_result[:, 1], sin.(cur_result[:, 1]), label = "Risultato atteso")
end

gif(anim, joinpath(@OUTPUT, "rk.gif"), fps = 1);

lastpos = [rungekutta(oscillatore, [0., 1.], 0.0, lastt, h)[end, 2] for h in deltat]
error_rk = abs.(lastpos .- sin(lastt))

@printf("%-14s\t%-14s\n", "δt [s]", "x(70) [m]")
for i in 1:length(deltat)
    @printf("%.12f\t%.12f\n", deltat[i], lastpos[i])
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

rodlength = 1.
g = 9.81

pendulum(t, x) = [x[2], -g / rodlength * sin(x[1])]

oscillations = rungekutta(pendulum, [π / 3, 0.], 0.0, 3.0, 0.01)
oscillations[1:10, :]

oscillations[(end - 10):end, :]

import Luxor

function plot_pendulum(angle)
    radius = 200
    y, x = radius .* sincos(π / 2 + angle)

    Luxor.sethue("black")
    Luxor.line(Luxor.Point(0, 0), Luxor.Point(x, y), :stroke)
    Luxor.circle(Luxor.Point(x, y), 10, :fill)
end

size(oscillations, 1)

anim = Luxor.Movie(500, 500, "Pendulum")

function animframe(scene, framenumber)
    Luxor.background("white")
    plot_pendulum(oscillations[framenumber, 2])
end

Luxor.animate(anim, [Luxor.Scene(anim, animframe, 1:size(oscillations, 1))],
    creategif=true, pathname=joinpath(@OUTPUT, "pendulum.gif"));

plot(oscillations[:, 1], oscillations[:, 3],
     label = "",
     xlabel = "Tempo [s]",
     ylabel = "Velocità angolare [rad/s]")

savefig(joinpath(@OUTPUT, "oscillations1.svg")) # hide

oscillations[abs.(oscillations[:, 3]) .< 0.1, :]

scatter(oscillations[:, 1], oscillations[:, 3],
        label = "",
        xlim = (1.0, 1.2),
        xlabel = "Tempo [s]",
        ylabel = "Velocità angolare [rad/s]")

savefig(joinpath(@OUTPUT, "oscillations2.svg")) # hide

function search_inversion(vect)
    prevval = vect[1]
    for i in 2:length(vect)
        if prevval * vect[i] < 0
            return i - 1
        end
        prevval = vect[i]
    end

    println("No inversion found, run the simulation for a longer time")

    # Return a negative (impossible) index
    -1
end

search_inversion([4, 3, 1, -2, -5])

interp(ptA, ptB, x) = ptA[1] + (ptA[1] - ptB[1]) / (ptA[2] - ptB[2]) * (x - ptA[2])
interp(ptA, ptB) = interp(ptA, ptB, 0)

interp((-0.4, -0.7), (0.5, 0.8), 0.3)

function invtime(time, vec)
    idx = search_inversion(vec)
    timeA, timeB = time[idx:idx + 1]
    vecA, vecB = vec[idx:idx + 1]

    abs(interp((timeA, vecA), (timeB, vecB)))
end

period(oscillations) = 2 * invtime(oscillations[:, 1], oscillations[:, 3])

period(oscillations)

ideal_period = 2π / √(g / rodlength)

angles = 0.1:0.1:3.0
ampl = [period(rungekutta(pendulum, [angle, 0.], 0.0, 3.0, 0.01)) for angle in angles]
plot(angles, ampl, label="", xlabel="Angolo [rad]", ylabel="Periodo [s]")
scatter!(angles, ampl, label="")

savefig(joinpath(@OUTPUT, "period-vs-angle.svg")) # hide

[angles ampl]

ω0 = 10;
α = 1.0 / 30;

function forcedpendulum(ω; init=[0., 0.], startt=0., endt=15. / α, deltat=0.01)
    rungekutta(init, startt, endt, deltat) do t, x
        [x[2], -ω0^2 * x[1] - α * x[2] + sin(ω * t)]
    end
end

oscillations = forcedpendulum(8.)
plot(oscillations[:, 1], oscillations[:, 2], label="")

savefig(joinpath(@OUTPUT, "forced-pendulum.svg")) # hide

function forced_amplitude(ω, oscillations)
    # Per comodità estraggo la prima colonna della matrice (quella che
    # contiene i tempi) nel vettore "timevec"
    timevec = oscillations[:, 1]

    # Questa maschera serve per trascurare le oscillazioni nella prima
    # parte della simulazione, ossia le prime righe della matrice.
    # Di fatto quindi ci concentriamo solo sulla "coda" della soluzione,
    # ossia le ultime righe della matrice
    mask = timevec .> 10 / α
    oscill_tail = oscillations[mask, :]

    # Calcolo il tempo in corrispondenza della prima inversione
    # nella "coda" della soluzione
    idx0 = search_inversion(oscill_tail[:, 3])
    ptA = oscill_tail[idx0, [1, 3]]
    ptB = oscill_tail[idx0 + 1, [1, 3]]
    t0 = interp(ptA, ptB)
    δt = t0 - oscill_tail[idx0, 1]
    newsol = forcedpendulum(ω,
        init=oscill_tail[idx0, 2:3],
        startt=oscill_tail[idx0, 1],
        endt=oscill_tail[idx0, 1] + 1.1 * δt,
        deltat=δt)

    @printf("t0 = %.4f, angle = %.4f, speed = %.4f, t0 + δt = %.4f, angle = %.4f, speed = %.4f\n",
        newsol[1, 1], newsol[1, 2], newsol[1,3], newsol[2, 1], newsol[2, 2], newsol[2, 3])
    abs(newsol[2, 2])
end

forced_amplitude(9.5, forcedpendulum(9.5))

# Aggiungiamo 0.01 agli estremi (9 e 11) per evitare la condizione di risonanza
freq = 9.01:0.1:11.01
println("The frequencies to be sampled are: $(collect(freq))")
ampl = [forced_amplitude(ω, forcedpendulum(ω)) for ω in freq]
plot(freq, ampl,
     label="", xlabel="Frequenza [rad/s]", ylabel="Ampiezza")
scatter!(freq, ampl, label="")

savefig(joinpath(@OUTPUT, "forced-pendulum-resonance.svg")) # hide

