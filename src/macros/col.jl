"""
    col(relational_type::Symbol, field2col::Expr) 

col macro - todo
"""   
macro col(relational_type::Symbol, field2col::Expr)
    field_name = field2col.args[2].value
    field_sym = Meta.parse(":$field_name")
    col_name = getcolname(field2col.args[3])
    col_sym = Meta.parse(":$col_name")
    quote
        function Relationals.fieldname2colname(
            ::Type{$(esc(relational_type))}, 
            ::Val{$(esc(field_sym))}
            )
            $(esc(col_sym))
        end
    end
end

getcolname(q::QuoteNode) = q.value
getcolname(s::String) = Symbol(s)