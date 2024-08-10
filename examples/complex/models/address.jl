using Relationals

struct Address <: Relational
    id::Int
    street::String
    city::String
    state::String
    zip::String
end