cd(@__DIR__)
import Pkg
Pkg.activate(".")
using Documenter, Relationals
makedocs(
    sitename="Relationals.jl",
    modules=[Relationals],
)
deploydocs(
    repo = "github.com/JuliaGraphQL/Relationals.jl.git",
)