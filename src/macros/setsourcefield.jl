macro setsourcefield(model_type::Symbol, source_key::QuoteNode, field::QuoteNode, fn::Expr)
    quote
        function Relationals.setsourcefield!(::Type{$(esc(model_type))}, ::Val{$source_key}, ::Val{$field}, row)
            f = $fn
            row[$field] = f(row)
        end
    end
end