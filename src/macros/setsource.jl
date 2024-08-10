# @source User :mysql
# @source User :sqlite
macro setsource(relational_type::Symbol, source_key::QuoteNode)
    quote
        function getconnection(::Type{$(esc(relational_type))})
            getconnection(Val($source_key))
        end
    end
end