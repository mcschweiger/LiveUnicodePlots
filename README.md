# LiveUnicodePlots are here !

### Usage Example
```julia
# Initialize a fake metadata dict
meta = Dict{Symbol, Any}(
    :lp => Float32[0.0],
    :temperature => Float32[1.0]
)

# Flags and trigger
runflag = Ref(true)
last_len = Ref(0)

# Background task to simulate updates
# (e.g. appending new values of some metric [:lp], to metadata)
producer_task = @async begin
    for i in 1:20
        push!(meta[:lp], meta[:lp][end] + randn())
        sleep(0.5)
    end
    runflag[] = false
end

# Monitor task (live-plots in terminal)
@live_unicode_monitor length(meta[:lp]) > last_len[] begin
    last_len[] = length(meta[:lp])
    live_lp_plot(meta, delay = 0.02, window=10)
end runflag

wait(producer_task)

@live_unicode_monitor length(lp) > last_len[] begin
    last_len[] = length(lp)
    live_lp_plot(meta; window=100)
end runflag
```

Please see (UnicodePlots.jl)[https://github.com/JuliaPlots/UnicodePlots.jl] for info on plotting routines in the REPL.
