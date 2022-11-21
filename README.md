# tnds-notebooks

Notebooks created with [Literate.jl](https://github.com/fredrikekre/Literate.jl) and [Franklin.jl](https://github.com/tlienart/Franklin.jl).

They are available here: https://ziotom78.github.io/tnds-notebooks/

To test the site, start `julia` and write

```julia
using Franklin
serve()  # No need to load Literate.jl, as it will be automatically called by Franklin
```

To serve the site using GitHub pages, just push a new commit: the `Deploy` action will call `Franklin.optimize()`, which takes care of re-generating the website and serving it to GitHub.
