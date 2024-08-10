struct RelationalMutation
    update_clause
    set_clause
    where_clause
end

function RelationalMutation(T::Type{<:Relational}, set, conds)
    RelationalMutation(
        updateclause(T),
        setclause(T, set),
        whereclause(T, conds)
    )
end

function getsql(T::Type{<:Relational}, m::RelationalMutation; kwargs...)
    clauses = [
        updatesql(T, m), 
        setsql(T, m.set_clause),
        wheresql(T, m.where_clause; kwargs...),
    ]
    join(clauses, " ")
end

updateclause(T) = tablename(T)
updatesql(T, m) = "UPDATE $(m.update_clause)"
setclause(T::Type{<:Relational}, set) = isempty(set) ? nothing : set
setclause(T::Type{<:Relational}, set::Union{Tuple,AbstractArray}) = set2string.(set)
setsql(T::Type{<:Relational}, set_clause) = setsqlclause(T, set_clause)

setsqlclause(T::Type{<:Relational}, set::Nothing) = nothing

function setsqlclause(T::Type{<:Relational}, set::Union{Tuple,AbstractArray,Dict})
    string(
        :SET,
        " ",
        join([set2string(x) for x in set], ", ")
    )
end

function set2string(set)
    string(set[1], "=", value2string(set[2]))
end

function getmutation(T::Type{<:Relational}, id::Int, fields::Pair)
    getmutation(T, (getpkfield(T)=>id,), (fields,))
end
function getmutation(T::Type{<:Relational}, uuid::UUID, fields::Pair)
    getmutation(T, (getuuidfield(T)=>uuid,), (fields,))
end
function getmutation(T::Type{<:Relational}, id::Int, fields::Union{Tuple,AbstractArray})
    getmutation(T, (getpkfield(T)=>id,), fields)
end
function getmutation(T::Type{<:Relational}, uuid::UUID, fields::Union{Tuple,AbstractArray})
    getmutation(T, (getuuidfield(T)=>uuid,), fields)
end

function getmutation(T::Type{<:Relational}, conds::Pair, fields::Pair)
    getmutation(T, (conds,), (fields,))
end
function getmutation(T::Type{<:Relational}, conds::Pair, fields::Union{Tuple,AbstractArray})
    getmutation(T, (conds,), fields)
end
function getmutation(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}, fields::Pair)
    getmutation(T, conds, (fields,))
end
function getmutation(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray}, fields::Union{Tuple,AbstractArray})
    d = Dict{Symbol,Any}(fields)
    if in(:updated_at, fieldnames(T))
        d[:updated_at] = timestamp()
    end
    RelationalMutation(T, d, conds)
end