"""
    create(T::Type{<:Relational}; kwargs...)
    create(T::Type{<:Relational}, cond::Pair; kwargs...)
    create(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Gets the first record of type T.

## Examples
```julia
# Gets the first User record.
julia> create(Manufacturer, :name=>"Sauron Supplies")
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record.
julia> create(Manufacturer, (:name=>"Sauron Supplies", :admin_id=>1))
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")
```
"""

function createmany(T::Type{<:Relational}, fields::Tuple; kwargs...)
    @assert all(x->isa(x,Pair), fields)
    len = length(fields[1][2])
    @assert all(x->length(x[2]) == len, fields)
    m = getcreatemany(T, fields)
    runmutation(T, conn(T), m; kwargs...)
    nothing
end