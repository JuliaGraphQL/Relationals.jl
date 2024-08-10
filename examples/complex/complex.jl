using Relationals
cd(@__DIR__)

include("sources.jl")
include("./models/models.jl")

orders = first(User) |> getorders
@assert u1 isa Vector{Order}

order = first(orders)
@assert u1 isa Order

products = getproducts(m)
@assert m isa Vector{Product}

product = first(products)
@assert m isa Product

manufacturer = getmanufacturer(product)
@assert m isa Manufacturer

admin = getadmin(manufacturer)
@assert m isa User