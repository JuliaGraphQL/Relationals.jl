using Dates

struct RelationalCreate
    insert_clause
    values_clause
end

function RelationalCreate(T::Type{<:Relational}, values)
    RelationalCreate(
        insertclause(T, values),
        valuesclause(T, values),
    )
end

function getsql(T::Type{<:Relational}, c::RelationalCreate; kwargs...)
    clauses = [
        insertsql(T, c.insert_clause), 
        valuessql(T, c.values_clause),
    ]
    join(clauses, " ")
end

insertclause(T, v::Pair) = (v[1],)
insertclause(T, values::Union{Tuple,AbstractArray,Dict}) = [v[1] for v in values]

function insertsql(T, insert_clause)
    string(
        "INSERT INTO ",
        tablename(T),
        "(",
        join(fieldname2colname.(T, Val.(insert_clause)), ","),
        ")",
    )
end

#valuesclause(T::Type{<:Relational}, value) = isempty(value) ? nothing : value
valuesclause(T::Type{<:Relational}, values::Union{Tuple,AbstractArray,Dict}) = [x[2] for x in values]
valuessql(T::Type{<:Relational}, values_clause) = valuessqlclause(T, values_clause)
valuessqlclause(T::Type{<:Relational}, values_clause::Nothing) = nothing

function valuessqlclause(T::Type{<:Relational}, values::Union{Tuple,AbstractArray})
    string(
        "VALUES (",
        join(value2string.(values), ", "),
        ")"
    )
end

value2string(value) = "\"$(string(value))\""

function value2string(value::AbstractVector)
    if isempty(value)
        return "\"[]\""
    end
    "\"$(string(value))\""
end

value2string(::Nothing) = "NULL"
value2string(value::String) = "\"$(string(escape_string(value)))\""
value2string(value::Number) = string(value)
value2string(value::DateTime) = string("\"", Dates.format(value, "yyyy-mm-dd HH:MM:SS"), "\"")
function getcreate(T::Type{<:Relational}, fields)
    d = Dict{Symbol,Any}(fields)
    at = timestamp()
    if in(:created_at, fieldnames(T))
        d[:created_at] = at
    end
    if in(:updated_at, fieldnames(T))
        d[:updated_at] = at
    end
    RelationalCreate(T, d)
end
getcreate(T::Type{<:Relational}, fields::Pair) = getcreate(T, (fields,))