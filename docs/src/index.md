# Relationals.jl
### Simple, fast access to relational data sources. Inspired by Rails ActiveRecord.

Works with MySQL/SQLite/PostgreSQL (any DB APIs listed [here](https://juliadatabases.org/)) and CSV files. Supports querying, but does not yet support writing to data sources.


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


## Advanced Usage
```julia
using Relationals, UUIDs

@source "sqlite.db"

struct User <: Relational
    id::Int
    uuid::UUID
    first_name::String
    last_name::String
    address_id::Int
end
@belongs_to User :address

struct Address <: Relational
    id::Int
    street::String
    city::String
    state::String
    zip::String
end
@col Address :zip=>:zipcode

struct Product <: Relational
    key::Int
    name::String
    manufacturer_id::Int
end
@tablename Product :items
@pk Product :key

struct Manufacturer <: Relational
    id::Int
    name::String
    admin_id::Int
end
@belongs_to Manufacturer :admin=>User
@has_many Manufacturer :products
```

```julia
# Gets the first Manufacturer record.
julia> manufacturer = first(Manufacturer)
Manufacturer(1, "Shire Product Co.", 1)

julia> user = getadmin(manufacturer)
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins", 1)

julia> getaddress(user)
Address(1, "1 Bagshot Row", "Shire", "Middle Earth", "37012")

julia> getproducts(manufacturer)
2-element Vector{User}:
  Product(1, "Frying Pan")
  Product(2, "Pipeweed")
```
The "sqlite.db" file can be found here:\
[https://github.com/JuliaGraphQL/Relationals.jl/tree/master/docs](https://github.com/JuliaGraphQL/Relationals.jl/tree/master/docs)


## Queries

The primary two functions for querying data are: [`first`](@ref) and [`all`](@ref). These functions return a single record and a collection of records, respectively.


```@meta
CurrentModule = Relationals
```

```@docs
first
```

```@docs
all
```

## Response Formats

There are several variants of [`first`](@ref) and [`all`](@ref), depending on the format you want. 
* [`tfirst`](@ref) returns a NamedTuple ([`tall`](@ref) returns a vector of NamedTuples)
* [`dfirst`](@ref) returns a Dict ([`dall`](@ref) returns a vector of Dicts)
* [`ffirst`](@ref) returns a DataFrame with one record  ([`fall`](@ref) returns a DataFrame of records)

```@docs
tfirst
```

```@docs
tall
```

```@docs
dfirst
```

```@docs
dall
```

```@docs
ffirst
```

```@docs
fall
```

## Mutations

```@docs
create
```

```@docs
update
```

```@docs
destroy
```

## Data sources

Relationals.jl supports MySQL abd SQLite files as data sources. The [`@source`](@ref) macro configures the data source connection. 

```@docs
@source
```

```@docs
tablename
```

```@docs
getconnection
```

```@docs
conn
```

```@docs
count
```

```@docs
updatemany
```

```@docs
@showsql
```

## Relational macros

The [`@has_many`](@ref) and [`@belongs_to`](@ref) configure one-to-many and many-to-one relationships, respectively.

```@docs
@has_many
```

```@docs
@belongs_to
```

```@docs
@pk
```

```@docs
@col
```

## API index

```@index
```