<a href="https://github.com/cropbox/Cropbox.jl"><img src="https://github.com/cropbox/Cropbox.jl/raw/main/docs/src/assets/logo.svg" alt="Cropbox" width="150"></a>

# LeafGasExchange.jl

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://cropbox.github.io/LeafGasExchange.jl/stable/)
[![Latest Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://cropbox.github.io/LeafGasExchange.jl/dev/)

[LeafGasExchange.jl](https://github.com/cropbox/LeafGasExchange.jl) implements a coupled leaf gas-exchange model using [Cropbox](https://github.com/cropbox/Cropbox.jl) modeling framework. Biochemical photosynthesis models (C₃, C₄) are coupled with empirical stomatal conductance models (Ball--Berry, Medlyn) in addition to radiative energy balance model. Users can run model simulations with custom configuration and visualize simulation results. Model parameters may be calibrated with observation dataset if provided.

## Examples

- [plants2020](https://github.com/cropbox/plants2020): coupled leaf gas-exchange model for C₄ leaves comparing stomatal conductance models
