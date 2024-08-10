using Dates

struct SQLAlert <: Exception
    sql::String
end

function lastinsertrowid(connection)
    first(
        DBInterface.execute(connection, "SELECT LAST_INSERT_ID() AS last_id")
    )[:last_id] |> Int
end

runsql(sql) = DBInterface.execute(getconnection(:default), sql)

function runsql(T::Type, c::DBInterface.Connection, sql; kwargs...)
    try
        # println("\n\n***SQL:\n", sql, "\n\n")
        return DBInterface.execute(c, sql)
    catch e
        error("\n\n***SQL Error:\n", sql, "\n\n")
        throw(e)
    end
end

timestamp() = Dates.format(now(), "yyyy-mm-dd HH:MM:SS")

# function runsql(T::Type, c::CSVConnection, sql; kwargs...)
#     mode_csv = ".mode csv"
#     import_path_as = ".import $(c.fname) $(tablename(T))"
#     fname = tempname()  
#     #once_cmd = ".once $fname"
#     #sql = string("update flowers set sepal_length=4;", sql)
#     #@show sql
#     cmd = `sqlite3 :memory: -cmd '.headers on' -cmd $mode_csv -cmd $import_path_as $sql`
#     if haskey(kwargs, :log_cmd) && kwargs[:log_cmd]
#         @show cmd
#     end          
#     open(fname, "w") do file                      
#         write(file, read(cmd, String))
#     end
#     df = DataFrame(CSV.File(fname))
#     rm(fname)
#     copy.(eachrow(df))
# end

function insertbetween(arr::AbstractArray, element)
    new_arr = []
    for i in 1:length(arr)
        push!(new_arr, arr[i])
        if i != length(arr)
            push!(new_arr, element)
        end
    end
    new_arr
end