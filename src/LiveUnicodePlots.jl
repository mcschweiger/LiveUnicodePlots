module LiveUnicodePlots

using UnicodePlots
"""
    @live_unicode_monitor condition_expr begin
        plot_code
    end runflag

A terminal-based live monitor that re-runs `plot_code` whenever `condition_expr` is true,
using ANSI cursor control to overwrite the previous plot in-place.

### Features
- Saves and restores cursor position (once at first trigger)
- Clears the terminal region below before each redraw
- Redraws are throttled by your `condition_expr` logic (e.g. only update on new data)
- Controlled by a `runflag::Ref{Bool}` — stops when `runflag[] == false`

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

Use this inside a long-running sampler or async task to visualize progress in the terminal.
"""
macro live_unicode_monitor(trigger_expr, body_expr, runflag)
    esc(quote
        let monitor_task = @async begin
            try
                local _cursor_saved = false
                while $runflag[]
                    sleep(1)
                    if $trigger_expr
                        if !_cursor_saved
                            print("\033[s")
                            _cursor_saved = true
                        end
                        print("\033[u")
                        print("\033[J")
                        $body_expr
                    end
                end
            catch e
                @error "Live Unicode monitor crashed" exception=(e, catch_backtrace())
            end
        end
        print("\033[999E")
        monitor_task
        end
    end)
end



"""
    live_lp_plot(sampler::Sampler; delay=0.2, window=200,sampler_funcs)

Live-updating in-place Unicode plot of `sampler.meta[:lp]`.
- Only one plot shown at a time (no clutter)
- Uses ANSI cursor control to redraw
- `delay`: seconds between refresh
- `pl_len`: number of recent points to show (or `nothing` for all)
- `sampler_funcs`: context for header: what's being sampled `Vector{Functions}`
"""
function live_lp_plot(meta::Dict{Symbol, Any};  delay = 0.1f0, window::Int = 100)

    last_print_time = time()

    println("Live Log-Posterior Monitor:")


    
    lp = meta[:lp]

    nsteps = length(lp)
    @assert nsteps > 0
    T  = meta[:temperature]
    Δlp = lp[end] - maximum(lp[1:end-1])
    lp_toplot = lp[end - min(length(lp), window) + 1:end]


    # only replot if enough time has passed or Δlp changed
    t_now = time()
    if Δlp ≠ 0.0f0 || (t_now - last_print_time > delay)
        # print("\033[u")  # Restore cursor
        # print("\033[J")  # Clear below
        last_print_time = t_now

        # Clear the terminal (ANSI escape sequence)
        # print("\033[H\033[2J")

        plot_obj = lineplot(
            1:length(lp_toplot), lp_toplot;
            title = "Log-Posterior Trace (n = $nsteps)",
            xlabel = "Iteration",
            ylabel = "Log-Posterior",
            canvas = UnicodePlots.BrailleCanvas
        )

        println("Δlp = $(round(Δlp, sigdigits=4)) @ T = $(T[end]) ")
        println(plot_obj)
    end
        # sleep(delay)
end

export @live_unicode_monitor, live_lp_plot
end # module LiveUnicodePlots