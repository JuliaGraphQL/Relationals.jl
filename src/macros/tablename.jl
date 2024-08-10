macro tablename(relational_type::Symbol, table_name::QuoteNode)
    quote
        Relationals.tablename(::Type{$(esc(relational_type))}) = $table_name
    end
end