
"""
    @belongs_to(model_type::QuoteNode, attr_name::Expr) 

Generates a function named "get{attr_name}" to retrieve a single object that is mapped to the model object. 

## Examples
```julia
# Configure a "getaddress" function for a User object.
@belongs_to User :address

# Configure a "getadmin" function for a Manufacturer object.
@belongs_to Manufacturer :admin=>User
```

```julia
# Gets the address of a user.
julia> getaddress(first(User))
Address(1, "1 Bagshot Row", "Shire", "Middle Earth", "37012")

# Gets the location of a manufacturer.
julia> getadmin(first(Manufacturer, 1))
User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")
```

"""
macro belongs_to(model_type, name_sym::QuoteNode)
    name = name_sym.value
    name_str = "get$name"
    name_sym = Symbol(name_str)
    name_type = Symbol(titlecase("$name"))
    quote
        function $(esc(name_sym))(user::$(esc(model_type)))
            first($(esc(name_type)))
        end
    end
end

macro belongs_to(model_type, name_expr::Expr)
    name = name_expr.args[2].value
    name_type = name_expr.args[3]
    name_str = "get$name"
    name_sym = Symbol(name_str)
    quote
        function $(esc(name_sym))(user::$(esc(model_type)))
            first($(esc(name_type)))
        end
    end
end

# macro belongs_to(model_type::Symbol, attr_name::QuoteNode)
#     @show model_type
#     @show dump(attr_name)
#     @show string(attr_name.value)
#     funname = Symbol("get$(string(attr_name.value))")
#     @show funname
#     quote
#         function $(esc(funname))(x::Main.$model_type)
#             nothing
#         end
#     end
# end