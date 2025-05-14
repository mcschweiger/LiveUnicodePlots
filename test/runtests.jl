using Test
using LiveUnicodePlots
using UnicodePlots

@testset "Minimal live unicode monitor test" begin
    data = Float32[0.0]
    runflag = Ref(true)
    last_len = Ref(0)

    # Simulate new data arriving
    producer = @async begin
        for i in 1:10
            push!(data, data[end] + randn())
            sleep(0.5)
        end
        runflag[] = false
    end

    # Monitor task using only UnicodePlots
    @live_unicode_monitor length(data) > last_len[] begin
        last_len[] = length(data)
        plot = lineplot(1:length(data), data; title = "Test", canvas = BrailleCanvas)
        println(plot)
    end runflag

    wait(producer)
    @test length(data) ≥ 11
end
@testset "LiveUnicodePlots - live monitor and plot" begin
    # Simulated sampler meta
    meta = Dict{Symbol, Any}(
        :lp => Float32[0.0],
        :temperature => Float32[1.0]
    )

    # Flags and trigger
    runflag = Ref(true)
    last_len = Ref(0)

    # Background task to simulate updates
    producer_task = @async begin
        for i in 1:20
            push!(meta[:lp], meta[:lp][end] + randn())
            sleep(0.5)
        end
        runflag[] = false
    end

    # Monitor task (should live-plot in terminal)
    @live_unicode_monitor length(meta[:lp]) > last_len[] begin
        last_len[] = length(meta[:lp])
        live_lp_plot(meta, delay = 0.02, window=10)
    end runflag

    wait(producer_task)

    @test length(meta[:lp]) > 20
end
