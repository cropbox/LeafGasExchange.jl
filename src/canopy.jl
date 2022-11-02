include("sun.jl")
include("radiation.jl")

@system ModelAdapter(ModelBase) begin
    weather ~ bring::Weather(override)

    PPFD: photosynthetic_photon_flux_density ~ track(u"μmol/m^2/s" #= Quanta =#, override)
    LAI: leaf_area_index                     ~ track(override)

    A_net_total(A_net, LAI): net_photosynthesis_total       => A_net * LAI   ~ track(u"μmol/m^2/s" #= CO2 =#)
    A_gross_total(A_gross, LAI): gross_photosynthesis_total => A_gross * LAI ~ track(u"μmol/m^2/s" #= CO2 =#)
    E_total(E, LAI): transpiration_total                    => E * LAI       ~ track(u"mmol/m^2/s" #= H2O =#)
end

@system C3BBAdapter(ModelAdapter, StomataBallBerry, C3)
@system C4BBAdapter(ModelAdapter, StomataBallBerry, C4)

@system C3MDAdapter(ModelAdapter, StomataMedlyn, C3)
@system C4MDAdapter(ModelAdapter, StomataMedlyn, C4)

@system Canopy{GasExchange => C3BBAdapter} begin
    weather(context)             ~ ::Weather
    sun(context, weather)        ~ ::Sun
    radiation(context, sun, LAI) ~ ::Radiation

    LAI: leaf_area_index => 5  ~ preserve(parameter)
    PD: planting_density => 55 ~ preserve(parameter, u"m^-2")

    H2O_weight  => 18.01528 ~ preserve(u"g/mol")
    CO2_weight  => 44.0098  ~ preserve(u"g/mol")
    CH2O_weight => 30.031   ~ preserve(u"g/mol")

    sunlit_gasexchange(context, weather, PPFD=Q_sun, LAI=LAI_sunlit) ~ ::GasExchange
    shaded_gasexchange(context, weather, PPFD=Q_sh,  LAI=LAI_shaded) ~ ::GasExchange

    leaf_width => begin
        # to be calculated when implemented for individal leaves
        #5.0 # for maize
        1.5 # for garlic
    end ~ preserve(u"cm", parameter)

    LAI_sunlit(radiation.sunlit_leaf_area_index): sunlit_leaf_area_index ~ track
    LAI_shaded(radiation.shaded_leaf_area_index): shaded_leaf_area_index ~ track

    Q_sun(radiation.irradiance_Q_sunlit): sunlit_irradiance ~ track(u"μmol/m^2/s" #= Quanta =#)
    Q_sh(radiation.irradiance_Q_shaded): shaded_irradiance ~ track(u"μmol/m^2/s" #= Quanta =#)

    A_gross(a=sunlit_gasexchange.A_gross_total, b=shaded_gasexchange.A_gross_total): gross_CO2_umol_per_m2_s => begin
        a + b
    end ~ track(u"μmol/m^2/s" #= CO2 =#)

    A_net(a=sunlit_gasexchange.A_net_total, b=shaded_gasexchange.A_net_total): net_CO2_umol_per_m2_s => begin
        a + b
    end ~ track(u"μmol/m^2/s" #= CO2 =#)

    gross_assimilation(A_gross, PD, w=CH2O_weight) => begin
        # grams carbo per plant per hour
        #FIXME check unit conversion between C/CO2 to CH2O
        A_gross / PD * w
    end ~ track(u"g/d")

    net_assimilation(A_net, PD, w=CH2O_weight) => begin
        # grams carbo per plant per hour
        #FIXME check unit conversion between C/CO2 to CH2O
        A_net / PD * w
    end ~ track(u"g/d")

    conductance(gs_sun=sunlit_gasexchange.gs, LAI_sunlit, gs_sh=shaded_gasexchange.gs, LAI_shaded, LAI) => begin
        #HACK ensure 0 when one of either LAI is 0, i.e., night
        # average stomatal conductance Yang
        c = ((gs_sun * LAI_sunlit) + (gs_sh * LAI_shaded)) / LAI
        #c = max(zero(c), c)
        iszero(LAI) ? zero(c) : c
    end ~ track(u"mol/m^2/s/bar")
end

@system ModelC3BBC{GasExchange => C3BBAdapter}(Canopy, Controller)
@system ModelC3MDC{GasExchange => C3MDAdapter}(Canopy, Controller)

@system ModelC4BBC{GasExchange => C4BBAdapter}(Canopy, Controller)
@system ModelC4MDC{GasExchange => C4MDAdapter}(Canopy, Controller)

export ModelC3BBC, ModelC3MDC, ModelC4BBC, ModelC4MDC
