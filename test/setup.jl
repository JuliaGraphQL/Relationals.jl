cd(@__DIR__)
using Relationals, UUIDs
using Test

struct Flower <: Relational
    sepal_length::Float32
    sepal_width::Float32
    petal_length::Float32
    petal_width::Float32
    species::String
end

##########################

@source "../docs/sqlite.db"

struct User <: Relational
    id::Int
    uuid::UUID
    first_name::String
    last_name::String
    address_id::Int
end
@belongs_to User :address

struct Address <: Relational
    id::Int
    street::String
    city::String
    state::String
    zip::String
end
@col Address :zip=>:zipcode

struct Product <: Relational
    key::Int
    name::String
    manufacturer_id::Int
end
@tablename Product :items
@pk Product :key

struct Manufacturer <: Relational
    id::Int
    name::String
    admin_id::Int
end
@belongs_to Manufacturer :admin=>User
@has_many Manufacturer :products