module Relationals

using Memoization
include("imports.jl")

abstract type Relational end
function getconnection end

getdefaultscope(T::Type{<:Relational}) = nothing

"""
    tablename(T::Type{<:Relational})

Returns the table name of type T.
"""
function tablename(T::Type{<:Relational})
    @memoize defaultsourcepath(T)
end

"""
    getconnection(source_key)

Gets the database connection for "source_key".
"""
getconnection(source_key) = getconnection(Val(source_key))

"""
    getconnection(source_keys::Tuple)

Gets multiple database connections for "source_keys".
"""
getconnection(source_keys::Tuple) = getconnection.(Val.(source_keys))


"""
    conn(T)

Gets the database connections for type T.
"""
conn(T) = getconnection(getsourcekey(T))

getsourcekey(::Type{<:Relational}) = :default

function getpkfield(T::Type{<:Relational})
    in(:id, fieldnames(T)) ? :id : nothing
end

getuuidfield(::Type{<:Relational}) = :uuid

function fieldname2colname(::Type{<:Relational}, ::Val{T}) where {T}
    T
end

include("csv.jl")
include("struct_types_override.jl")
include("relational_query.jl")
include("query.jl")

include("models.jl")
export allwithcursor, cursorcols2sql, batchedfirst

include("dicts.jl")
include("tuples.jl")
include("frames.jl")
include("./macros/relational.jl")
include("./macros/source.jl")
include("./macros/setsourcefield.jl")
include("./macros/col.jl")
include("./macros/pk.jl")
include("./macros/setsource.jl")
include("./macros/tablename.jl")
include("./macros/has_many.jl")
include("./macros/belongs_to.jl")
include("./macros/showsql.jl")
include("./macros/scope.jl")
include("./relational_mutation.jl")
include("./mutate.jl")
include("./relational_create.jl")
include("./create.jl")
include("./relational_delete.jl")
include("./destroy.jl")
include("./relational_createmany.jl")
include("./createmany.jl")
include("./updatemany.jl")
include("./destroymany.jl")
include("./util.jl")

include("./cursors.jl")

setsourcefield!(::Type{<:Relational}, ::Val, ::Val, row) = nothing

export @source, @setsource, @tablename, @relational, @setsourcefield, getsourcekey, setsourcefield!,
@has_many, @belongs_to, @col, @pk, @showsql, @scope

export first
export all

export lastinsertrowid

export Relational, getconnection, tablename, tojson, conn, fieldname2colname, 
selectclause, limitclause, getquery, queryconstruct, fieldname2selectcol, colexprs2cols,
queryconstructdicts, queryconstructtuples, whereclause,runquery, initmultirelational, CSVConnection, 
count, RelationalQuery, getsql, RelationalMutation, update, RelationalCreate, create, 
RelationalDelete, destroy, save, savenew, createmany, SQLAlert, updatemany, destroymany,
getdefaultscope, getpkfield, last, snakecase, singularize, getsubscribekey, newmessageavailable

end
