struct RelationalQuery
    select_clause
    where_clause
end
Base.length(::RelationalQuery) = 1
Base.iterate(x::RelationalQuery, state=1) = state > length(x) ? nothing : (x, state+1)

concatclauses!(clauses, x::Nothing) = nothing
concatclauses!(clauses, x::String) = push!(clauses, x)

getleftjoin(args) = haskey(args, :left_join) ? args[:left_join] : nothing
getorderby(args) = haskey(args, :order) ? args[:order] : nothing

function getsql(T::Type{<:Relational}, q::RelationalQuery; kwargs...)
    clauses = [
        selectsql(T, q.select_clause), 
        fromsql(T),
    ]
    concatclauses!(clauses, leftjoinsql(T; kwargs...))
    concatclauses!(clauses, wheresql(T, q.where_clause; kwargs...))
    concatclauses!(clauses, orderbysql(T; kwargs...))
    concatclauses!(clauses, limitsql(T, kwargs[:limit]))
    concatclauses!(clauses, offsetsql(T, kwargs[:offset]))
    join(clauses, " ")
end

function getquery(select_clause; kwargs...)
    where_clause = haskey(kwargs, :where_clause) ? kwargs[:where_clause] : nothing
    RelationalQuery(
        select_clause,
        where_clause,
    )
end

function RelationalQuery(T::Type{<:Relational}, select, conditions, cursor_cols=nothing)
    getquery(
        selectclause(T, select, cursor_cols); 
        where_clause=whereclause(T, conditions),
    )
end