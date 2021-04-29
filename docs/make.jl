using Documenter
using Cropbox

makedocs(
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://cropbox.github.io/LeafGasExchange.jl/stable/",
        assets = ["assets/favicon.ico"],
        analytics = "UA-192782823-1",
    ),
    sitename = "LeafGasExchange.jl",
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/cropbox/LeafGasExchange.jl.git",
    devbranch = "main",
)
