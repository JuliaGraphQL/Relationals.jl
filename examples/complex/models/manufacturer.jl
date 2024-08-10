using Relationals

struct Manufacturer <: Relational
    id::Int
    name::String
    admin_id::Int
end

@belongs_to Manufacturer :admin=>User
@has_many Manufacturer :products