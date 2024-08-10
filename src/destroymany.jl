function destroymany(T::Type{<:Relational}, conds; kwargs...)
    runmutation(T, conn(T), getdeletion(T, conds); kwargs...)
    nothing
end