using Relationals

struct Order <: Relational
    id::Int
    street::String
    city::String
    state::String
    zip::String
end

@has_many Manufacturer :order_products
@has_many Manufacturer :products :through=>:order_products

@setsource Order :sqlite