"""
    pk(relational_type::Symbol, field) 

pk macro - todo
"""    
macro pk(relational_type::Symbol, field)
    quote
        function Relationals.getpkfield(
            ::Type{$(esc(relational_type))}
            )
            $(esc(field))
        end
    end
end