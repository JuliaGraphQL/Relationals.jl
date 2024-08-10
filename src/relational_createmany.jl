struct RelationalCreateMany
    insert_clause
    values_clause
end

function RelationalCreateMany(T::Type{<:Relational}, values)
    RelationalCreateMany(
        insertclause(T, values),
        valuesclause(T, values),
    )
end

function getsql(T::Type{<:Relational}, c::RelationalCreateMany; kwargs...)
    clauses = [
        insertsql(T, c.insert_clause), 
        valuesetssql(T, c.values_clause),
    ]
    join(clauses, " ")
end

valuesetssql(T::Type{<:Relational}, values_clause) = valuesetssqlclause(T, values_clause)
valuesetssqlclause(T::Type{<:Relational}, values_clause::Nothing) = nothing

function valuesetssqlclause(T::Type{<:Relational}, valuesets::Union{Tuple,AbstractArray})
    num_records = length(valuesets[1])
    tuples = map(
        n->[values[n] for values in valuesets],
        1:num_records
    )
    string(
        "VALUES ",
        join([string("(",join(value2string.(tuple), ","), ")") for tuple in tuples], ","),
    )
end

function getcreatemany(T::Type{<:Relational}, fields)
    num_records = length(fields[1][2])
    d = Dict{Symbol,Any}(fields)
    at = timestamp()
    if in(:created_at, fieldnames(T))
        d[:created_at] = [at for i in 1:num_records]
    end
    if in(:updated_at, fieldnames(T))
        d[:updated_at] = [at for i in 1:num_records]
    end
    RelationalCreateMany(T, d)
end

getcreatemany(T::Type{<:Relational}, fields::Pair) = getcreatemany(T, (fields,))