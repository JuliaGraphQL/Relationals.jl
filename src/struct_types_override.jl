using StructTypes, Dates

StructTypes.constructfrom(::Type{String}, n::Number) = string(n)

function StructTypes.constructfrom(::Type{DateTime}, s::String)
    DateTime(s, dateformat"yyyy-mm-dd HH:MM:SS")
end