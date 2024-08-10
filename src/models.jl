"""
    first(T::Type{<:Relational}; kwargs...)
    first(T::Type{<:Relational}, cond::Int; kwargs...)
    first(T::Type{<:Relational}, cond::String; kwargs...)
    first(T::Type{<:Relational}, cond::Pair; kwargs...)
    first(T::Type{<:Relational}, cond::UUID; kwargs...)
    first(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Gets the first record of type T.

## Examples
```julia
# Gets the first User record.
julia> first(User)
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record with id=1.
julia> first(User, 1)
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record where "uuid IS NOT NULL".
> first(User, "uuid IS NOT NULL")
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record where last_name="Baggins".
> first(User, :last_name=>"Baggins")
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record where first_name="Bilbo".
> first(User, :first_name=>:Bilbo)
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record where uuid="c6dacd6f-0023-4aba-bf24-374f4042fc47".
> first(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record where id=1 and uuid="c6dacd6f-0023-4aba-bf24-374f4042fc47".
> first(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record where last_name="Baggins" and uuid is not null.
> first(User, (:last_name=>:Baggins, "uuid IS NOT NULL"))
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record where last_name="Baggins" and first_name is "Frodo" or "Bilbo". 
> first(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"]))
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")

# Gets the first User record where first_name="Frodo" and (id > 1 OR last_name="Baggins").
> first(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'"))
User(2, UUID("0bb0cdc4-b1d3-43ac-93ad-693a94fc9ceb"), "Frodo", "Baggins")
```
"""
Base.first(T::Type{<:Relational}; kwargs...) = first(T, (); kwargs...)
Base.first(T::Type{<:Relational}, cond::Int; kwargs...) = first(T, getpkfield(T)=>cond; kwargs...)
Base.first(T::Type{<:Relational}, cond::UUID; kwargs...) = first(T, :uuid=>cond; kwargs...)
Base.first(T::Type{<:Relational}, cond::String; kwargs...) = first(T, (cond,); kwargs...)
Base.first(T::Type{<:Relational}, cond::Pair; kwargs...) = first(T, (cond,); kwargs...)
function Base.first(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)
    firstornothing(
        queryconstructmodels(
            T, 
            RelationalQuery(T, nothing, conds);
            kwargs..., 
            limit=1,
            offset=0,
        )
    )
end

function batchedfirst(T::Type{<:Relational}, int_pks::AbstractVector{<:Integer}; kwargs...)
    items = all(T, getpkfield(T)=>int_pks)
    pk2item = Dict((getfield(x, getpkfield(T)), x) for x in items)
    [get(pk2item, int_pk, nothing) for int_pk in int_pks]
end

batchedfirst(T::Type{<:Relational}, uuids::AbstractVector{Missing}) = fill(nothing, length(uuids))
batchedfirst(T::Type{<:Relational}, uuids::AbstractVector{Nothing}) = fill(nothing, length(uuids))

function batchedfirst(T::Type{<:Relational}, uuids::AbstractVector{<:Union{Missing, Nothing, UUID}}; kwargs...)
    filtered = convert(Array{UUID}, filter(x->!ismissing(x) && !isnothing(x), uuids))
    items = isempty(filtered) ? [] : all(T, :uuid=>filtered)
    uuid2item = Dict((x.uuid, x) for x in items)
    [get(uuid2item, uuid, nothing) for uuid in uuids]
end

"""
    all(T::Type{<:Relational}; kwargs...)
    all(T::Type{<:Relational}, cond::String; kwargs...)
    all(T::Type{<:Relational}, cond::Pair; kwargs...)
    all(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Gets a collection of records of type T.

## Examples
```julia
julia> all(User)
3-element Vector{User}:
 User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins", 1)
 User(2, UUID("32002bdb-0435-42e4-9c7b-e7dea3162abb"), "Frodo", "Baggins", 1)
 User(3, UUID("fe6fe463-10c0-4bbc-bb39-bbd6f55a9e06"), "Samwise", "Gamgee", 2)

julia> all(User, "uuid IS NOT NULL")
3-element Vector{User}:
 User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins", 1)
 User(2, UUID("32002bdb-0435-42e4-9c7b-e7dea3162abb"), "Frodo", "Baggins", 1)
 User(3, UUID("fe6fe463-10c0-4bbc-bb39-bbd6f55a9e06"), "Samwise", "Gamgee", 2)

julia> all(User, :last_name=>"Baggins")
2-element Vector{User}:
 User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins", 1)
 User(2, UUID("32002bdb-0435-42e4-9c7b-e7dea3162abb"), "Frodo", "Baggins", 1)

julia> all(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2)
2-element Vector{User}:
 User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins", 1)
 User(2, UUID("32002bdb-0435-42e4-9c7b-e7dea3162abb"), "Frodo", "Baggins", 1)

```
"""
Base.all(T::Type{<:Relational}; kwargs...) = allcommon(T, (); kwargs...)
Base.all(T::Type{<:Relational}, cond::String; kwargs...) = allcommon(T, (cond,); kwargs...)
Base.all(T::Type{<:Relational}, cond::Pair; kwargs...) = allcommon(T, (cond,); kwargs...)
Base.all(T::Type{<:Relational}, conds::AbstractArray; kwargs...) = allcommon(T, conds; kwargs...)
Base.all(T::Type{<:Relational}, conds::Tuple; kwargs...) = allcommon(T, conds; kwargs...)
function allcommon(T::Type{<:Relational}, conds::Union{<:AbstractArray,Tuple}; kwargs...)
    queryconstructmodels(
        T, 
        RelationalQuery(T, nothing, conds);
        limit=1000,
        offset=0,
        kwargs...
    )
end

allwithcursor(T::Type{<:Relational}; kwargs...) = allwithcursor(T, (); kwargs...)
allwithcursor(T::Type{<:Relational}, cond::String; kwargs...) = allwithcursor(T, (cond,); kwargs...)
allwithcursor(T::Type{<:Relational}, cond::Pair; kwargs...) = allwithcursor(T, (cond,); kwargs...)
function allwithcursor(T::Type{<:Relational}, conds::Union{<:AbstractArray,Tuple}; kwargs...)
    queryconstructmodelscursors(
        T, 
        RelationalQuery(T, nothing, conds, kwargs[:cursor_cols]);
        limit=1000,
        offset=0,
        kwargs...
    )
end

"""
    count(T::Type{<:Relational}; kwargs...)
    count(T::Type{<:Relational}, cond::String; kwargs...)
    count(T::Type{<:Relational}, cond::Pair; kwargs...)
    count(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}; kwargs...)

Gets the count of matching records.

"""
Base.count(T::Type{<:Relational}; kwargs...) = countcommon(T, (); kwargs...)
Base.count(T::Type{<:Relational}, cond::String; kwargs...) = countcommon(T, (cond,); kwargs...)
Base.count(T::Type{<:Relational}, cond::Pair; kwargs...) = countcommon(T, (cond,); kwargs...)
Base.count(T::Type{<:Relational}, conds::AbstractArray; kwargs...) = countcommon(T, conds; kwargs...)
Base.count(T::Type{<:Relational}, conds::Tuple; kwargs...) = countcommon(T, conds; kwargs...)
function countcommon(T::Type{<:Relational}, conds::Union{<:AbstractArray,Tuple}; kwargs...)
    q = RelationalQuery(T, ["COUNT(*) AS __count"], conds)
    first(runquery(T, conn(T), q; kwargs..., limit=1, offset=0))[:__count]
end



Base.last(T::Type{<:Relational}; kwargs...) = lastcommon(T, (); kwargs...)
Base.last(T::Type{<:Relational}, cond::Int; kwargs...) = lastcommon(T, getpkfield(T)=>cond; kwargs...)
Base.last(T::Type{<:Relational}, cond::UUID; kwargs...) = lastcommon(T, :uuid=>cond; kwargs...)
Base.last(T::Type{<:Relational}, cond::String; kwargs...) = lastcommon(T, (cond,); kwargs...)
Base.last(T::Type{<:Relational}, cond::Pair; kwargs...) = lastcommon(T, (cond,); kwargs...)
Base.last(T::Type{<:Relational}, conds::AbstractArray; kwargs...) = lastcommon(T, conds; kwargs...)
Base.last(T::Type{<:Relational}, conds::Tuple; kwargs...) = lastcommon(T, conds; kwargs...)
function lastcommon(T::Type{<:Relational}, conds::Union{<:AbstractArray,Tuple}; kwargs...)
    if haskey(kwargs, :order)
        field, sort = kwargs[:order]
        order = (field, sort == :ASC ? :DESC : :ASC)
    else 
        order = (getpkfield(T), :DESC)
    end
    first(T, conds; kwargs..., order)
end