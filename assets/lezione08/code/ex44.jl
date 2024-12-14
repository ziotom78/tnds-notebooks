# This file was generated, do not modify it. # hide
let p1x = -0.4, p1y = -0.7, p2x = 0.5, p2y = 0.8, y = 0.3
    # Il comando `plot` richiede di passare un array con le ascisse
    # e uno con le coordinate…
    plot([p1x, p2x], [p1y, p2y], label = "");
    # …mentre la nostra `interp` richiede due coppie (x, y)
    let x = interp([p1x, p1y], [p2x, p2y], y)
        @printf("La retta interpolante passa per (%.1f, %.1f)\n", x, y)
        # Il comando `scatter` funziona come `plot`
        scatter!([p1x, x, p2x], [p1y, y, p2y], label = "");
    end
end;

savefig(joinpath(@OUTPUT, "interp-test.svg")); # hide