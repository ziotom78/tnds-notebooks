# This file was generated, do not modify it. # hide
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