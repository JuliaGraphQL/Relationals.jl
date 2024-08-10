function queryconstructdicts(T, q; kwargs...)
    map(runquery(T, conn(T), q; kwargs...)) do result
        d = Dict()
        for name in propertynames(result)
            try
                if hasfield(T, name)
                    d[name] = StructTypes.constructfrom(
                        fieldtype(T, name), 
                        result[name]
                    )
                else
                    d[name] = result[name]
                end
            catch e
                @error "$(T) Construction Error ~~~~~~~~ field: $name ($(fieldtype(T, name))), value: $(result[name])"
                return e
            end
        end
        d
    end
end

"""
    dfirst(T::Type{<:Relational}; kwargs...)
    dfirst(T::Type{<:Relational}, cond::Int; kwargs...)
    dfirst(T::Type{<:Relational}, cond::String; kwargs...)
    dfirst(T::Type{<:Relational}, cond::Pair; kwargs...)
    dfirst(T::Type{<:Relational}, cond::UUID; kwargs...)
    dfirst(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Identical to [`first`](@ref), but returns the record as a Dict.

## Example
```
julia> dfirst(User)
Dict{Any, Any} with 5 entries:
  :address_id => 1
  :id         => 1
  :uuid       => UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")
  :last_name  => "Baggins"
  :first_name => "Bilbo"
```
"""
dfirst(T::Type{<:Relational}; kwargs...) = dfirst(T, (); kwargs...)
dfirst(T::Type{<:Relational}, cond::Int; kwargs...) = dfirst(T, getpkfield(T)=>cond; kwargs...)
dfirst(T::Type{<:Relational}, cond::UUID; kwargs...) = dfirst(T, :uuid=>cond; kwargs...)
dfirst(T::Type{<:Relational}, cond::String; kwargs...) = dfirst(T, (cond,); kwargs...)
dfirst(T::Type{<:Relational}, cond::Pair; kwargs...) = dfirst(T, (cond,); kwargs...)
function dfirst(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)
    select = haskey(kwargs, :select) ? kwargs[:select] : nothing
    firstornothing(
        queryconstructdicts(
            T, 
            RelationalQuery(T, select, conds); 
            kwargs...,
            limit=1,
            offset=0,
        )
    )
end


"""
    dall(T::Type{<:Relational}; kwargs...)
    dall(T::Type{<:Relational}, cond::String; kwargs...)
    dall(T::Type{<:Relational}, cond::Pair; kwargs...)
    dall(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Identical to [`all`](@ref), but returns the records as a vector of Dicts.
"""
dall(T::Type{<:Relational}; kwargs...) = dall(T, (); kwargs...)
dall(T::Type{<:Relational}, cond::String; kwargs...) = dall(T, (cond,); kwargs...)
dall(T::Type{<:Relational}, cond::Pair; kwargs...) = dall(T, (cond,); kwargs...)
function dall(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)
    select = haskey(kwargs, :select) ? kwargs[:select] : nothing
    queryconstructdicts(
        T, 
        RelationalQuery(T, select, conds); 
        limit=1000,
        offset=0,
        kwargs...
    )
end