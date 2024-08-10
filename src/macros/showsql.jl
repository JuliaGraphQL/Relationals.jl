"""
    showsql(relational_type::Symbol, field) 

showsql macro - todo
"""    
macro showsql(expr)
    if expr.args[2] isa Expr
        push!(expr.args[2].args, :($(Expr(:kw, :show_sql, true))))
    else
        str = string(expr)
        expr = Meta.parse(string(str[1:end-1], "; show_sql=true)"))
    end
    quote
        try
            $(esc(expr))
        catch e
            if e isa SQLAlert
                println(e.sql)
            else 
                rethrow(e)
            end
        end
    end
end