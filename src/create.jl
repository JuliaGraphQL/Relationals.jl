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
function create(T::Type{<:Relational}; kwargs...)
    create(T, nothing; kwargs...)
end

function create(T::Type{<:Relational}, fields; kwargs...)
    savenew(T, fields; kwargs...)
    getlastcreated(T, conn(T); kwargs...)
end

function savenew(T::Type{<:Relational}, fields; kwargs...)
    runmutation(T, conn(T), getcreate(T, fields); kwargs...)
    nothing
end

function getlastcreated(T::Type{<:Relational}, c::DBInterface.Connection; kwargs...)
    first(T, lastinsertrowid(c); kwargs...)
end

function getlastcreated(T::Type{<:Relational}, c::CSVConnection; kwargs...)
    last(T; kwargs...)
end