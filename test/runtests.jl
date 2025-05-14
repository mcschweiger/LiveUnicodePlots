using Test
using LiveUnicodePlots

@testset "LiveUnicodePlots - live monitor and plot" begin
    # Simulated sampler meta
    meta = Dict(
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
            sleep(0.05)
        end
        runflag[] = false
    end

    # Monitor task (should live-plot in terminal)
    @live_unicode_monitor length(meta[:lp]) > last_len[] begin
        last_len[] = length(meta[:lp])
        live_lp_plot(meta; pl_len=10)
    end runflag

    wait(producer_task)

    @test length(meta[:lp]) > 20
end
