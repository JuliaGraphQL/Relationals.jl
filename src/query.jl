using DBInterface
using StructTypes
using DataFrames
using JSON3
using JSONTables
using UUIDs
# using CSV

StructTypes.StructType(::Type{<:Relational}) = StructTypes.Struct()

struct DictRow
    d::Dict
end
Base.propertynames(dr::DictRow) = keys(dr.d)
Base.getindex(dr::DictRow, sym::Symbol) = dr.d[sym]

getunscoped(args) = haskey(args, :unscoped) && args[:unscoped]

function runmutation(T::Type, connection::DBInterface.Connection, m; kwargs...)
    runquery(T, conn(T), m; kwargs...)
end

function runmutation(T::Type, c::CSVConnection, q; kwargs...)
    sql = getsql(T, q; kwargs...)
    sql2 = "SELECT * FROM flowers"
    if haskey(kwargs, :show_sql) && kwargs[:show_sql]
        println("\nRelationals.show_sql:\n$(sql)\n")
    end
    mode_csv = ".mode csv"
    import_path_as = ".import $(c.fname) $(tablename(T))"
    fname = tempname()
    cmd = `sqlite3 :memory: -cmd '.headers on' -cmd $mode_csv -cmd $import_path_as $sql $sql2`
    if haskey(kwargs, :log_cmd) && kwargs[:log_cmd]
        @show cmd
    end          
    open(fname, "w") do file                      
        write(file, read(cmd, String))
    end
    mv(fname, c.fname; force=true)
    nothing
end

function runquery(T::Type, connection, q; kwargs...)
    sql = getsql(T, q; kwargs...)
    if haskey(kwargs, :show_sql) && kwargs[:show_sql]
        println("\nRelationals.show_sql:\n$(sql)\n")
    end
    runsql(T, connection, sql; kwargs...)
end

getdfbyrowfn(::Any) = ==
getdfbyrowfn(::AbstractArray) = in

function getdffilters(q)
    if isnothing(q.where_clause)
        return nothing
    end
    map(q.where_clause) do filter
        (k,v) = filter
        k => ByRow(getdfbyrowfn(v)(v))
    end
end

function runquery(T::Type, connections::Tuple, q; kwargs...)
    Iterators.flatten(runquery.(T, connections, q; kwargs...)) |> collect
end

function queryconstructmodels(::Type{T}, q; kwargs...) where T
    ds = queryconstructdicts(T, q; kwargs...)
    convert(
        Vector{T},
        StructTypes.constructfrom.(
            T, 
            ds
        ),
    )
end

function queryconstructmodelscursors(T, q; kwargs...)
    direction =  kwargs[:cursor_direction]
    cols = kwargs[:cursor_cols]
    order = getcursororderstr(cols, direction)
    ds = queryconstructdicts(T, q; order=order, kwargs...)
    cursors = map(ds) do d
        marker = d[Symbol("__cursor")]
        JSON3.write(Dict(:marker=>marker, :cols=>cols, :direction=>direction))
    end
    [
        (node=x[1], cursor=x[2]) 
        for x in zip(
            StructTypes.constructfrom.(T, ds),
            cursors,
        )
    ]
end

function fieldname2selectcol(T, V::Val{N}) where {N}
    col_name = fieldname2colname(T, V)
    if isequal(N, col_name)
        return col_name
    end
    "$col_name AS $N"
end

colexpr2col(T, col_expr::String) = col_expr

function colexpr2col(T, col_expr::Symbol)
    string(tablename(T), ".", fieldname2selectcol(T, Val(col_expr)))
end

function colexprs2cols(T, ::Nothing)
    string.(tablename(T), ".", fieldname2selectcol.(T, Val.(fieldnames(T))))
end

function colexprs2cols(T, col_exprs)
    colexpr2col.(T, col_exprs)
end

function cursorcols2concat(cursor_cols)
    if length(cursor_cols) === 1
        return cursor_cols[1]
    end
    string(
        "CONCAT(",
        join(insertbetween(cursor_cols, "'|'"), ","),
        ")"
    )
end

function cursorcols2sql(T, cursor_cols)
    "$(cursorcols2concat(cursor_cols)) AS __cursor"
end

function selectclause(T, select=nothing, cursor_cols=nothing)
    cols = collect(colexprs2cols(T, select))
    if !isnothing(cursor_cols)
        push!(cols, cursorcols2sql(T, cursor_cols))
    end
    # @show cols
    cols
end

selectsql(T, select_clause) = "SELECT $(join(select_clause, ","))"
selectsql(T, select_clause::String) = "SELECT $select_clause"

fromsql(T) = "FROM $(tablename(T))"

limitclause(T, i) = i
limitsql(T, limit::Integer) = "LIMIT $limit"
limitsql(T, ::Nothing) = nothing

offsetclause(T, i) = i
offsetsql(T, offset::Integer) = "OFFSET $offset"
offsetsql(T, ::Nothing) = nothing

expandcolname(T, name) = "$(tablename(T)).$(string(name))"

cond2string(T, cond::AbstractString) = cond
cond2string(T, cond::UUID) = cond2string(T, :uuid=>cond)
cond2string(T, cond::Pair{Symbol,UUID}) = string("LOWER($(expandcolname(T, cond[1]))) = \"", string(cond[2]), "\"")
cond2string(T, cond::Pair{Symbol,Nothing}) = string(expandcolname(T, cond[1]), " IS NULL")
cond2string(T, cond::Pair{Symbol,<:Number}) = string(expandcolname(T, cond[1]), "=", cond[2])
cond2string(T, cond::Pair{Symbol,<:AbstractString}) = cond2string(T, string(cond[1])=>cond[2])
cond2string(T, cond::Pair{<:AbstractString,<:AbstractString}) = string(expandcolname(T, cond[1]), "=\"", cond[2], "\"")
cond2string(T, cond::Pair{Symbol,Symbol}) = cond2string(T, cond[1]=>string(cond[2]))
# 
# commented out on 2024-1-30 as it causes ambiguity issues with ":uuid=>UUID[]"
# cond2string(T, cond::Pair{Symbol,<:AbstractArray{<:Missing}}) = "FALSE"
#
cond2string(T, cond::Pair{Symbol,<:AbstractVector{UUID}}) = isempty(cond[2]) ? "FALSE" : cond2string(T, cond[1]=>string.(cond[2]))

function cond2string(T, cond::Pair{Symbol, <:AbstractVector{String}})
    if isempty(cond[2])
        return "FALSE"
    end
    v = cond[2]
    list = join(["\"$x\"" for x in v], ",")
    "$(expandcolname(T, cond[1])) IN ($list)"
end

function cond2string(T, cond::Pair{Symbol,<:AbstractVector{<:Integer}})
    if isempty(cond[2])
        return "FALSE"
    end
    string(
        expandcolname(T, cond[1]), " IN ", "(", join(cond[2], ","), ")"
    )
end

# function test_cond2string()
#     @assert cond2string("id=1")         == "id=1"
#     @assert cond2string(:id=>1)         == "id=1"
#     @assert cond2string(:name=>"foo")   == "name=\"foo\""
#     @assert cond2string(:name=>:foo)    == "name=\"foo\""
#     @assert cond2string(:id=>[1,2,3])    == "id IN (1,2,3)"
# end
#test_cond2string()

whereclause(T::Type{<:Relational}, conds) = isempty(conds) ? nothing : conds

concatconds!(conds, ::Nothing) = nothing
concatconds!(conds, p::Pair) = push!(conds, p)
concatconds!(conds, v::Union{Tuple,AbstractArray}) = append!(conds, v)

function leftjoinsql(T::Type{<:Relational}; kwargs...)
    left_join = getleftjoin(kwargs)
    if isnothing(left_join)
        return nothing
    end
    getleftjoinstr(left_join)
end
getleftjoinstr(left_join::String) = "LEFT JOIN $left_join"
getleftjoinstr(left_join::Tuple) = join(["LEFT JOIN $x" for x in left_join], " ")

function orderbysql(T::Type{<:Relational}; kwargs...)
    order_by = getorderby(kwargs)
    if isnothing(order_by)
        return nothing
    end
    join(["ORDER BY", getorderbystr(order_by)], " ")
end
getorderbystr(order::String) = order
getorderbystr(order::Tuple) = join(order, " ")

function wheresql(T::Type{<:Relational}, where_clause; kwargs...)
    unscoped = getunscoped(kwargs)
    conds = []
    if !unscoped
        concatconds!(conds, getdefaultscope(T))
    end
    concatconds!(conds, where_clause)
    if isempty(conds)
        return nothing
    end
    wheresqlconds(T, conds)
end

wheresqlconds(T::Type{<:Relational}, conds::Nothing) = nothing

function wheresqlconds(T::Type{<:Relational}, conds::Union{Tuple,AbstractArray})
    string(
        :WHERE,
        " ",
        join(["($cond)" for cond in cond2string.(T, conds)], " AND ")
    )
end
function test_wheresql()
    @assert wheresql(nothing, ["id=1"]) == "WHERE id=1"
    @assert wheresql(nothing, [:id=>1]) == "WHERE id=1"
    @assert wheresql(nothing, [:id=>[1,2,3]]) == "WHERE id IN (1,2,3)"
end
#test_wheresql()

jfirst(T::Type{<:Relational}) = dfirst(T) |> JSON3.write

tojson(x) = JSON3.write(x)
tojson(df::DataFrame) = arraytable(df)

firstornothing(l) = isempty(l) ? nothing : first(l)