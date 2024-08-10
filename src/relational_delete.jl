struct RelationalDelete
    where_clause
end

function RelationalDelete(T::Type{<:Relational}, conds)
    RelationalDelete(
        whereclause(T, conds)
    )
end

function getsql(T::Type{<:Relational}, m::RelationalDelete; kwargs...)
    clauses = [
        :DELETE, 
        fromsql(T), 
        wheresql(T, m.where_clause; kwargs...),
    ]
    join(clauses, " ")
end

function getdeletion(T::Type{<:Relational}, id::Int)
    RelationalDelete(T, (getpkfield(T)=>id,))
end

function getdeletion(T::Type{<:Relational}, uuid::UUID)
    RelationalDelete(T, (getuuidfield(T)=>uuid,))
end

function getdeletion(T::Type{<:Relational}, cond::Pair)
    RelationalDelete(T, (cond,))
end

function getdeletion(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray})
    RelationalDelete(T, conds)
end
