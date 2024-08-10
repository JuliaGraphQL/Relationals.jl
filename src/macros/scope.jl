macro scope(relational_type::Symbol, conds::Expr)
    quote
        function Relationals.getdefaultscope(
            ::Type{$(esc(relational_type))}
            )
            $(esc(conds))
        end
    end
end