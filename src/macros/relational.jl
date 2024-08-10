macro relational(model_type::Symbol)
    initrelational(model_type)
end

macro relational(model_type::Symbol, source_path::String)
    initrelational(model_type; source_path=source_path)
end

# @relational User :json 
macro relational(model_type::Symbol, source_key::QuoteNode)
    initrelational(model_type; source_key=source_key)
end

# @relational User (:json1,:json2) "employees"
macro relational(model_type::Symbol, source_key::Expr, source_path::String)
    initrelational(
        model_type; 
        source_key=source_key,
        source_path=source_path,
    )
end

# @relational User (:json1,:json2)
macro relational(model_type::Symbol, source_keys::Expr)
    initmultirelational(
        model_type,
        source_keys,
    )
end

function initmultirelational(
    model_type,
    source_keys;
    source_path=defaultsourcepath(model_type),
    )
    quote
        Relationals.getsourcekey(T::Type{$(esc(model_type))}) = $source_keys
        Relationals.tablename(T::Type{$(esc(model_type))}) = $source_path
    end
end

function initrelational(
    model_type; 
    source_key=QuoteNode(:default), 
    source_path=defaultsourcepath(model_type),
    )
    quote
        Relationals.getsourcekey(T::Type{$(esc(model_type))}) = $source_key
        Relationals.tablename(T::Type{$(esc(model_type))}) = $source_path
    end
end

snakecase(s) = lowercase(replace(s, r"([0-9a-z])([A-Z])" => s"\1_\2"))

function defaultsourcepath(model_type)
    root = snakecase(string(model_type))
    string(
        root,
        root[end] == 's' ? "es" : "s"
    )
end