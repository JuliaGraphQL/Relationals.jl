
"""
    @has_many(model_type::QuoteNode, attr_name::Expr)

Generates a function named "get{attr_name}" to retrieve a collection of objects that are mapped to the model object. 

## Examples
```julia
# Configure a "getproducts" function for a Manufacturer object.
@has_many Manufacturer :products

# Configure a "getadmins" function for a Manufacturer object.
@has_many Manufacturer :admins=>User
```

```julia
# Gets all products of a manufacturer.
julia> getproducts(first(Manufacturer))
2-element Vector{Product}:
  Product(1, "Frying Pan")
  Product(2, "Pipeweed")

# Gets all admins of manufacturer.
julia> getadmins(first(Manufacturer))
2-element Vector{User}:
  User(1, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), "Bilbo", "Baggins")
  User(2, UUID("0bb0cdc4-b1d3-43ac-93ad-693a94fc9ceb"), "Frodo", "Baggins")
```

"""
macro has_many(model_type, name_sym::QuoteNode)
    name = name_sym.value
    name_str = "get$(name)"
    name_sym = Symbol(name_str)
    name_singular = singularize(string(name))
    name_type = Symbol(titlecase(name_singular))
    model_id_field = Symbol(snakecase("$(model_type)Id"))
    search_id = Meta.parse(":$model_id_field")
    param_value = Meta.parse("x.id")
    param_name = :x
    quote
        function $(esc(name_sym))($(esc(param_name))::$(esc(model_type)))
            #first($(esc(name_type)))
            all($(esc(name_type)), $(esc(search_id))=>$(esc(param_value)))
        end
    end
end

function singularize(str)
    root = lowercase(replace(str, r"([0-9a-z])([A-Z])" => s"\1_\2"))
    m = match(r"(.+)(es|s)$", root)
    isnothing(m) ? str : m[1]
end