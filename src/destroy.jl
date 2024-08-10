"""
    destroy(T::Type{<:Relational}, key::Union{Int,UUID}; kwargs...)

Delete the record matching the unique key (either :id of type Int or :uuid of type UUID).

## Examples
```julia
# Gets the first User record.
julia> destroy(Manufacturer, 1)
```
"""
function destroy(T::Type{<:Relational}, key::Union{Int,UUID}; kwargs...)
    runmutation(T, conn(T), getdeletion(T, key); kwargs...)
    nothing
end