# LiveUnicodePlots are here !

### Usage Example
```julia
lp = Float32[]
runflag = Ref(true)
last_len = Ref(0)

@live_unicode_monitor length(lp) > last_len[] begin
    last_len[] = length(lp)
    live_lp_plot(meta; window=100)
end runflag
```

Please see (UnicodePlots.jl)[https://github.com/JuliaPlots/UnicodePlots.jl] for info on plotting routines in the REPL.
