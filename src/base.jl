@system TemperatureDependence begin
    T: leaf_temperature ~ hold
    Tk(T): absolute_leaf_temperature ~ track(u"K")

    Tb: base_temperature => 25 ~ preserve(u"°C", parameter)
    Tbk(Tb): absolute_base_temperature ~ preserve(u"K")

    kT(T, Tk, Tb, Tbk; Ea(u"kJ/mol")): arrhenius_equation => begin
        exp(Ea * (T - Tb) / (u"R" * Tk * Tbk))
    end ~ call

    kTpeak(Tk, Tbk, kT; Ha(u"kJ/mol"), Hd(u"kJ/mol"), ΔS(u"J/mol/K")): peaked_function => begin
        kT(Ha) * (1 + exp((ΔS*Tbk - Hd) / (u"R"*Tbk))) / (1 + exp((ΔS*Tk - Hd) / (u"R"*Tk)))
    end ~ call

    ΔS(; Ha(u"kJ/mol"), Hd(u"kJ/mol"), To(u"K")): entropy_factor => begin
        Hd / To + u"R" * log(Ha / (Hd - Ha))
    end ~ call(u"J/mol/K")

    kTpeakT(kTpeak, ΔS; Ha(u"kJ/mol"), Hd(u"kJ/mol"), To(u"K")): peaked_function_with_optimal_temperature => begin
        kTpeak(Ha, Hd, ΔS(Ha, Hd, To))
    end ~ call

    Q10 => 2 ~ preserve(parameter)
    kTQ10(T, Tb, Q10): q10_rate => begin
        Q10^((T - Tb) / 10u"K")
    end ~ track
end

@system NitrogenDependence begin
    N: leaf_nitrogen_content ~ hold

    s => 2.9 ~ preserve(u"m^2/g", parameter)
    N0 => 0.25 ~ preserve(u"g/m^2", parameter)

    kN(N, s, N0): nitrogen_limited_rate => begin
        2 / (1 + exp(-s * (max(N0, N) - N0))) - 1
    end ~ track
end

@system CBase(TemperatureDependence, NitrogenDependence) begin
    Ci: intercellular_co2 ~ hold
    I2: effective_irradiance ~ hold
end
