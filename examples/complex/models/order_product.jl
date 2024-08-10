using Relationals

struct OrderProduct <: Relational
    id::Int
    order_id::Int
    product_id::Int
    quantity::Int
end