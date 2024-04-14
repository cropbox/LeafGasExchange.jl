import PrecompileTools

PrecompileTools.@compile_workload begin
    ge_weather = :Weather => (
        PFD = 1500,
        CO2 = 400,
        RH = 60,
        T_air = 30,
        wind = 2.0,
    )

    ge_spad = :Nitrogen => (
        _a = 0.0004,
        _b = 0.0120,
        _c = 0,
        SPAD = 60,
    )

    ge_water = :StomataTuzet => (
        #WP_leaf = 0,
        sf = 2.3,
        Ψf = -1.2,
    )

    ge_base = @config(ge_weather, ge_spad, ge_water)

    ge_canopy = @config(
        ge_base,
        :Sun => (;
            d = 1,
            h = 12,
        ),
        :Canopy => (;
            LAI = 5,
        ),
        :Radiation => (;
            leaf_angle_factor = 3,
            leaf_angle = LeafGasExchange.horizontal,
        )
    )

    xstep = :Weather => :CO2 => 100:100:1000

    for m in (ModelC3BB, ModelC3MD, ModelC4BB, ModelC4MD)
        for backend in (:UnicodePlots, :Gadfly)
            visualize(m, :Ci, :A_net; config = ge_base, xstep, backend)
        end
    end

    for m in (ModelC3BBC, ModelC3MDC, ModelC4BBC, ModelC4MDC)
        for backend in (:UnicodePlots, :Gadfly)
            visualize(m, "weather.CO2", :A_net; config = ge_canopy, xstep, backend)
        end
    end
end
