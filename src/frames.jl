function queryconstructdf(T, q; kwargs...)
    runquery(T, conn(T), q; kwargs...) |> DataFrame
end


"""
    ffirst(T::Type{<:Relational}; kwargs...)
    ffirst(T::Type{<:Relational}, cond::Int; kwargs...)
    ffirst(T::Type{<:Relational}, cond::String; kwargs...)
    ffirst(T::Type{<:Relational}, cond::Pair; kwargs...)
    ffirst(T::Type{<:Relational}, cond::UUID; kwargs...)
    ffirst(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Identical to [`first`](@ref), but returns the record in a DataFrame.

## Example
```
julia> ffirst(User)
1×5 DataFrame
 Row │ id     uuid                               first_name  last_name  address_id 
     │ Int64  String                             String      String     Int64      
─────┼─────────────────────────────────────────────────────────────────────────────
   1 │     1  c6dacd6f-0023-4aba-bf24-374f4042…  Bilbo       Baggins             1
```
"""
ffirst(T::Type{<:Relational}; kwargs...) = ffirst(T, (); kwargs...)
ffirst(T::Type{<:Relational}, cond::Int; kwargs...) = ffirst(T, getpkfield(T)=>cond; kwargs...)
ffirst(T::Type{<:Relational}, cond::UUID; kwargs...) = ffirst(T, :uuid=>cond; kwargs...)
ffirst(T::Type{<:Relational}, cond::String; kwargs...) = ffirst(T, (cond,); kwargs...)
ffirst(T::Type{<:Relational}, cond::Pair; kwargs...) = ffirst(T, (cond,); kwargs...)
function ffirst(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)
    select = haskey(kwargs, :select) ? kwargs[:select] : nothing
    queryconstructdf(
        T, 
        RelationalQuery(T, select, conds); 
        kwargs...,
        limit=1,
        offset=0,
    )
end


"""
    fall(T::Type{<:Relational}; kwargs...)
    fall(T::Type{<:Relational}, cond::String; kwargs...)
    fall(T::Type{<:Relational}, cond::Pair; kwargs...)
    fall(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Identical to [`all`](@ref), but returns the records in a DataFrame.
"""
fall(T::Type{<:Relational}; kwargs...) = fall(T, (); kwargs...)
fall(T::Type{<:Relational}, cond::String; kwargs...) = fall(T, (cond,); kwargs...)
fall(T::Type{<:Relational}, cond::Pair; kwargs...) = fall(T, (cond,); kwargs...)
function fall(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)
    select = haskey(kwargs, :select) ? kwargs[:select] : nothing
    queryconstructdf(
        T, 
        RelationalQuery(T, select, conds);
        limit=1000,
        offset=0,
        kwargs...
    )
end