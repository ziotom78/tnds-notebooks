# This file was generated, do not modify it. # hide
function simulate(glc::GLC, δx, δt, δR)
    # Misura dell'altezza iniziale
    cur_x0 = randgauss(glc, x0, δx)
    # Misura dell'altezza finale
    cur_x1 = randgauss(glc, x1, δx)

    # Questo array di 2 elementi conterrà le due stime di η
    # (corrispondenti ai due possibili raggi della sferetta)
    estimated_η = zeros(2)
    for case in [1, 2]
        # Misura delle dimensioni della sferetta
        cur_R = randgauss(glc, R_true[case], δR)
        cur_Δx = cur_x1 - cur_x0

        # Misura del tempo necessario per cadere da cur_x0 a cur_x1
        cur_Δt = randgauss(glc, Δt_true[case], δt)

        # Stima di η
        estimated_η[case] = η(cur_R, cur_Δt, cur_Δx)
    end

    estimated_η
end