# Relationals.jl

[![][docs-dev-img]][docs-dev-url]

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://juliagraphql.github.io/Relationals.jl/dev/

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://juliagraphql.github.io/Relationals.jl/stable/

# Relationals.jl
### Simple, fast access to relational data sources. Inspired by Rails ActiveRecord.

Works with MySQL/SQLite/PostgreSQL (any DB APIs listed [here](https://juliadatabases.org/)). Supports querying, but does not yet support writing to data sources.


## Basic Usage

```julia
using Relationals

struct Flower <: Relational
    sepal_length::Float32
    sepal_width::Float32
    petal_length::Float32
    petal_width::Float32
    species::String
end
```

```julia
# Gets the first Flower record.
julia> first(Flower)
Flower(5.1f0, 3.5f0, 1.4f0, 0.2f0, "Iris-setosa")

# Get all Flower records with "sepal_length=5.9" and limit to 2 records.
julia> all(Flower, :sepal_length=>5.9; limit=2)
3-element Vector{Flower}:
 Flower(5.9f0, 3.0f0, 4.2f0, 1.5f0, "Iris-versicolor")
 Flower(5.9f0, 3.2f0, 4.8f0, 1.8f0, "Iris-versicolor")
```
