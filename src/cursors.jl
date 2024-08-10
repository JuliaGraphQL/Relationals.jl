gettotalcount(T, filters::Nothing; kwargs...) = count(T; kwargs...)
gettotalcount(T, filters; kwargs...) = count(T, getfilteredwhereclause(T, filters); kwargs...)
export gettotalcount

countbeforecursor(T, cursor::Nothing, filters; kwargs...) = 0

haspreviouspage(T, start_cursor::Nothing, filters; kwargs...) = false
function haspreviouspage(T, start_cursor, filters; kwargs...)
    haspage(T, getbeforecursorwhereclause, start_cursor, filters; kwargs...)
end

hasnextpage(T, end_cursor::Nothing, filters; kwargs...) = false
function hasnextpage(T, end_cursor, filters; kwargs...)
    haspage(T, getaftercursorwhereclause, end_cursor, filters; kwargs...)
end

getcursorstr(x) = string(x)
getcursorstr(x::DateTime) = Dates.format(x, dateformat"yyyy-mm-dd HH:MM:SS")

function getcursor(node, table_name, order::Tuple)
    cursor_cols = order[1]
    cursor_direction = order[2]
    join(
        [
            table_name,
            cursor_cols,
            cursor_direction,
            getcursorstr(getfield(node, cursor_cols)),
            node.id,
        ], 
        "|"
    )
end
getencodedcursor(node, table_name, order::Tuple) = getcursor(node, table_name, order) |> base64encode
# begin
#     x = Net(10, uuid4(), now(), now(), "sample net")
#     @assert "name|ASC|sample net|10" === getcursor(x, (:name, :ASC))
#     @assert "bmFtZXxBU0N8c2FtcGxlIG5ldHwxMA==" === getencodedcursor(x, (:name, :ASC))
# end

function getcursorwhereclause(T, cursor::AbstractDict, sort_field_operator)
    # copy(cursor) = Dict{Symbol, Any}(:cursor_dir => "DESC", :c => "2023-12-15 20:12:34", :cols => ["multipoint_samples.created_at"])

    #"""CONCAT(fig_actions.foo,'|',fig_actions.created_at) > "SOME FIG NAME|2023-12-15 20:12:34" """

    string(
        cursorcols2concat(cursor[:cols]),
        " $sort_field_operator ",
        "'$(cursor[:marker])'",
    )
end

function getaftercursorwhereclause(T, cursor::AbstractDict, cursor_direction::Val{:DESC})
    getcursorwhereclause(T, cursor, "<")
end
function getaftercursorwhereclause(T, cursor::AbstractDict, cursor_direction::Val{:ASC})
    getcursorwhereclause(T, cursor, ">")
end
function getbeforecursorwhereclause(T, cursor::AbstractDict, cursor_direction::Val{:DESC})
    getcursorwhereclause(T, cursor, ">")
end
function getbeforecursorwhereclause(T, cursor::AbstractDict,  cursor_direction::Val{:ASC})
    getcursorwhereclause(T, cursor, "<")
end

function getcursorsortfieldvaluesql(sort_field_value::Union{UUID,DateTime,String})
    string("'", sort_field_value, "'")
end

function getcursorsortfieldvaluesql(sort_field_value::Integer)
    string(sort_field_value)
end

# begin
#     x = Net(10, uuid4(), now(), now(), "sample net")
#     @assert "(name <= 'sample net' AND id < 10)" === getaftercursorwhereclause(x, :name, Val(:DESC))
#     @assert "(name >= 'sample net' AND id > 10)" === getaftercursorwhereclause(x, :name, Val(:ASC))
#     @assert "(created_at <= '$(x.created_at)' AND id < 10)" === getaftercursorwhereclause(x, :created_at, Val(:DESC))
#     @assert "(created_at >= '$(x.created_at)' AND id > 10)" === getaftercursorwhereclause(x, :created_at, Val(:ASC))
#     @assert "(uuid <= '$(x.uuid)' AND id < 10)" === getaftercursorwhereclause(x, :uuid, Val(:DESC))
#     @assert "(uuid >= '$(x.uuid)' AND id > 10)" === getaftercursorwhereclause(x, :uuid, Val(:ASC))
#     @assert "(id <= $(x.id) AND id < 10)" === getaftercursorwhereclause(x, :id, Val(:DESC))
#     @assert "(id >= $(x.id) AND id > 10)" === getaftercursorwhereclause(x, :id, Val(:ASC))

#     @assert "(name >= 'sample net' AND id > 10)" === getcursorwherebeforeclause(x, :name, Val(:DESC))
#     @assert "(name <= 'sample net' AND id < 10)" === getcursorwherebeforeclause(x, :name, Val(:ASC))
#     @assert "(created_at >= '$(x.created_at)' AND id > 10)" === getcursorwherebeforeclause(x, :created_at, Val(:DESC))
#     @assert "(created_at <= '$(x.created_at)' AND id < 10)" === getcursorwherebeforeclause(x, :created_at, Val(:ASC))
#     @assert "(uuid >= '$(x.uuid)' AND id > 10)" === getcursorwherebeforeclause(x, :uuid, Val(:DESC))
#     @assert "(uuid <= '$(x.uuid)' AND id < 10)" === getcursorwherebeforeclause(x, :uuid, Val(:ASC))
#     @assert "(id >= $(x.id) AND id > 10)" === getcursorwherebeforeclause(x, :id, Val(:DESC))
#     @assert "(id <= $(x.id) AND id < 10)" === getcursorwherebeforeclause(x, :id, Val(:ASC))
# end

function getcursororderstr(cols, direction) 
    string(cursorcols2concat(cols), " ", direction)
end

function getconnectionnodes(
    T, 
    after::Missing, 
    before::Missing, 
    filters; 
    kwargs...
    )
    allwithcursor(
        T, 
        calccursorwhereclause(T, nothing, nothing, filters); 
        kwargs...
    )
end
export getconnectionnodes

function getconnectionnodes(
    T, 
    after::Missing, 
    before::Missing, 
    filters::Nothing;
    kwargs...
    )
    allwithcursor(T; kwargs...)
end

function getconnectionnodes(
    T, 
    after::String, 
    before::Missing, 
    filters;
    kwargs...
    )
    allwithcursor(
        T, 
        calccursorwhereclause(T, getaftercursorwhereclause, after, filters); 
        kwargs...
    )
end

function getconnectionnodes(
    T, 
    after::Missing, 
    before::String, 
    filters;
    kwargs...
    )
    allwithcursor(
        T, 
        calccursorwhereclause(T, getbeforecursorwhereclause, before, filters);
        offset=max(0, countbeforecursor(T, before, filters; kwargs...) - kwargs[:limit]),
        kwargs...,
        show_sql=false,
    )
end

function haspage(T, cursor_where_clause_fn, cursor::String, filters; kwargs...)
    getcount(T, cursor_where_clause_fn, cursor, filters; kwargs...) > 0
end

getfilteredwhereclause(T, ::Nothing) = nothing

function getfilteredwhereclause(T, filters)
    parts = join(map(x->"($x)", filters), " AND ")
    isempty(parts) ? nothing : string("(", parts, ")")
end

calccursorwhereclause(T, ::Nothing, ::Nothing, filters) = getfilteredwhereclause(T, filters)
calccursorwhereclause(T, ::Nothing, ::Nothing, ::Nothing) = nothing

function calccursorwhereclause(T, cursor_where_clause_fn, encoded_cursor, filters)
    cursor = JSON3.read(encoded_cursor)
    cursor_where_clause = cursor_where_clause_fn(
        T,
        cursor,
        Val(Symbol(cursor[:direction])),
    )
    filtered_where_clause = getfilteredwhereclause(T, filters)
    if !isnothing(filtered_where_clause) && !isempty(filtered_where_clause)
        return string(filtered_where_clause, " AND ", cursor_where_clause)
    end
    cursor_where_clause
end

function getcount(T, cursor_where_clause_fn, cursor::String, filters; kwargs...)
    count(T, calccursorwhereclause(T, cursor_where_clause_fn, cursor, filters); kwargs...)
end

function countbeforecursor(T, cursor, filters; kwargs...)
    getcount(T, getbeforecursorwhereclause, cursor, filters; kwargs...)
end