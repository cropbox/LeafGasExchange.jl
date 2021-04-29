# LeafGasExchange.jl

[LeafGasExchange.jl](https://github.com/cropbox/LeafGasExchange.jl) implements a coupled leaf gas-exchange model using [Cropbox](https://github.com/cropbox/Cropbox.jl) modeling framework. Biochemical photosynthesis models (C₃, C₄) are coupled with empirical stomatal conductance models (Ball--Berry, Medlyn) in addition to radiative energy balance model. Users can run model simulations with custom configuration and visualize simulation results. Model parameters may be calibrated with observation dataset if provided.

## Installation

```julia
using Pkg
Pkg.add("LeafGasExchange")
```

## Getting Started

```@setup aci
ENV["UNITFUL_FANCY_EXPONENTS"] = true
```

```@example aci
using Cropbox
using LeafGasExchange
```

The package exports four combinations of model (`ModelC3BB`, `ModelC3MD`, `ModelC4BB`, `ModelC4MD`) from two photosynthesis models (`C3`, `C4`) and two stomatal conductance models (`BB` for Ball-Berry, `MD` for Medlyn).

```@example aci
parameters(ModelC4MD; alias = true)
```

By default, most parameters are already filled in for a casual run, except driving variables which describe surrounding environment.

```@example aci
config = :Weather => (
    PFD = 1500,
    CO2 = 400,
    RH = 60,
    T_air = 30,
    wind = 2.0,
)
; # hide
```

Let's define a wide range of atmospheric CO₂ for simulation.

```@example aci
xstep = :Weather => :CO2 => 50:10:1500
; # hide
```

Then, net photosynthesis rate (`A_net`), Rubisco-limited rate (`Ac`), and electron transport-limited rate (`Aj`) responding to the range of CO₂ can be simulated and visualized in a plot.

```@example aci
visualize(ModelC4MD, :Ci, [:Ac, :Aj, :A_net]; config, xstep, kind = :line)
```

The output of simulation can be visualized in terms of other variables such as stomatal conductance (`gs`) whose coupling with photosynthesis  is solved via vapor pressure at the leaf surface.

```@example aci
visualize(ModelC4MD, :Ci, :gs; config, xstep, kind = :line)
```

Similarly, we can visualize changes in leaf temperature (`T`) which has to be numerically optimized through energy balance equation.

```@example aci
visualize(ModelC4MD, :Ci, :T; config, xstep, kind = :line)
```

For more information about using the framework such as `parameters()` and `visualize()` functions, please refer to the [Cropbox documentation](http://cropbox.github.io/Cropbox.jl/stable/).
