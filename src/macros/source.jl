using SQLite

# macro connection(target::String)
#     @show target, typeof(target)
#     quote
#         const SQLITE_DB = SQLite.DB($target)
#         Relationals.getconnection(::Type{<:Relational}) = SQLITE_DB
#     end
# end

function initsource(ext::Val{:csv}, key::QuoteNode, path::String)
    real_path = realpath(path)
    qn = QuoteNode(key)
    quote
        const CONN = CSVConnection($key, $(esc(real_path)))
        function Relationals.getconnection(::Val{$key})
            CONN
        end
    end
end

function initsource(ext::Val{:db}, key::QuoteNode, path::String)
    real_path = realpath(path)
    qn = QuoteNode(key)
    quote
        const CONN = SQLite.DB($(esc(real_path)))
        function Relationals.getconnection(::Val{$key})
            CONN
        end
    end
end

"""
    @source(fname::String)
    @source(c::Expr)
    @source(key::QuoteNode, conn::Expr)
    @source(key::QuoteNode, fname::String)

## Examples
```
# Configure a MySQL data source as the default.
@source DBInterface.connect(
    MySQL.Connection,
    "127.0.0.1", 
    "username", 
    "password";
    db="widgets",
    port=3306,
)

# Configure an SQLite data source only for the Product model.
@source Product "sqlite.db"

```
"""
macro source(key::QuoteNode, path::String)
    initsource(Val(getfileext(fname)), key, path)
end

macro source(model_type::Symbol, source::String)
    file_ext = getfileext(source)
    dsource_name = Symbol("$(lowercase(string(model_type)))_$(file_ext)")
    dsource_sym = Meta.parse(":$dsource_name")
    a = quote 
        Relationals.getsourcekey(T::Type{$(esc(model_type))}) = $(esc(dsource_sym))
    end
    Expr(
        :block, 
        a, 
        initsource(Val(file_ext), QuoteNode(dsource_name), source),
    )
end

# @source :mysql connection
# @source :sqlite connection
macro source(key::QuoteNode, conn::Expr)
    quote
        const CONN = $(esc(conn))
        function Relationals.getconnection(::Val{$key})
            CONN
        end
    end
end

macro source(fname::String)
    initsource(Val(getfileext(fname)), QuoteNode(:default), fname)
end

# @source mysql_connection
macro source(c)
    quote
        const CONN = $(esc(c))
        Relationals.getconnection(::Val{:default}) = CONN
    end
end

function getfileext(fname)
    Symbol(split(splitext(fname)[end], ".")[end])
end