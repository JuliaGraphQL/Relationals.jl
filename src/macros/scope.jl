"""
    scope(relational_type::Symbol, conds) 

    scope macro - todo
"""    
macro scope(relational_type::Symbol, conds::Expr)
    quote
        function Relationals.getdefaultscope(
            ::Type{$(esc(relational_type))}
            )
            $(esc(conds))
        end
    end
end