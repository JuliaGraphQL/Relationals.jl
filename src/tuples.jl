function queryconstructtuples(T, q; kwargs...)
    map(runquery(T, conn(T), q; kwargs...)) do result
        NamedTuple{tuple(propertynames(result)...)}(
            map(propertynames(result)) do name
                if hasfield(T, name)
                    return StructTypes.constructfrom(
                        fieldtype(T, name), 
                        result[name]
                    )
                end
                result[name]
            end
        )
    end
end


"""
    tfirst(T::Type{<:Relational}; kwargs...)
    tfirst(T::Type{<:Relational}, cond::Int; kwargs...)
    tfirst(T::Type{<:Relational}, cond::String; kwargs...)
    tfirst(T::Type{<:Relational}, cond::Pair; kwargs...)
    tfirst(T::Type{<:Relational}, cond::UUID; kwargs...)
    tfirst(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Identical to [`first`](@ref), but returns the record as a NamedTuple.

## Example
```julia
julia> tfirst(User)
(id = 1, uuid = UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), first_name = "Bilbo", last_name = "Baggins", address_id = 1)
```
"""
tfirst(T::Type{<:Relational}; kwargs...) = tfirst(T, (); kwargs...)
tfirst(T::Type{<:Relational}, cond::Int; kwargs...) = tfirst(T, getpkfield(T)=>cond; kwargs...)
tfirst(T::Type{<:Relational}, cond::UUID; kwargs...) = tfirst(T, :uuid=>cond; kwargs...)
tfirst(T::Type{<:Relational}, cond::String; kwargs...) = tfirst(T, (cond,); kwargs...)
tfirst(T::Type{<:Relational}, cond::Pair; kwargs...) = tfirst(T, (cond,); kwargs...)
function tfirst(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)
    select = haskey(kwargs, :select) ? kwargs[:select] : nothing
    firstornothing(
        queryconstructtuples(
            T, 
            RelationalQuery(T, select, conds);
            kwargs...,
            limit=1,
            offset=0,
        )
    )
end


"""
    tall(T::Type{<:Relational}; kwargs...)
    tall(T::Type{<:Relational}, cond::String; kwargs...)
    tall(T::Type{<:Relational}, cond::Pair; kwargs...)
    tall(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Identical to [`all`](@ref), but returns the records as a vector of NamedTuples.
"""
tall(T::Type{<:Relational}; kwargs...) = tall(T, (); kwargs...)
tall(T::Type{<:Relational}, cond::String; kwargs...) = tall(T, (cond,); kwargs...)
tall(T::Type{<:Relational}, cond::Pair; kwargs...) = tall(T, (cond,); kwargs...)
function tall(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)
    select = haskey(kwargs, :select) ? kwargs[:select] : nothing
    queryconstructtuples(
        T, 
        RelationalQuery(T, select, conds);
        limit=1000,
        offset=0,
        kwargs...,
    )
end