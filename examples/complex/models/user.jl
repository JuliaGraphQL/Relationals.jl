using Relationals

struct User <: Relational
    id::Int
    uuid::UUID
    first_name::String
    last_name::String
    address_id::Int
end

@belongs_to User, :address