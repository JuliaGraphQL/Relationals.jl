cd(@__DIR__)
using Relationals
using SQLite
using UUIDs
using BenchmarkTools

@source SQLite.DB("basic.db")

struct User <: Relational
    id::Int
    uuid::UUID
    last_name::String
end

#####################
# Model results
#####################

first(User)
@assert ans isa User

first(User, 1)
@assert ans isa User

first(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))
@assert ans isa User

first(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))
@assert ans isa User

first(User, "uuid IS NOT NULL")
@assert ans isa User

first(User, :last_name=>"who?")
@assert ans isa User

first(User, :last_name=>:harhar)
@assert ans isa User

first(User, (:last_name=>:harhar, "uuid IS NOT NULL"))
@assert ans isa User

all(User)
@assert ans isa Array{User}

all(User, "uuid IS NOT NULL")
@assert ans isa Array{User}

all(User, ("uuid IS NOT NULL", "last_name IS NOT NULL"); limit=10)
@assert ans isa Array{User}


#####################
# NamedTuple results
#####################

tfirst(User)
@assert ans isa NamedTuple

tfirst(User, :last_name=>"who?")
@assert ans isa NamedTuple

tall(User)
@assert ans isa Array{<:NamedTuple}


#####################
# Dict results
#####################

dfirst(User)
@assert ans isa Dict

dfirst(User; select=[:last_name, "last_name AS lname"])
@assert ans isa Dict

dall(User)
@assert ans isa Array{<:Dict}


#####################
# DataFrame results
#####################

using DataFrames

ffirst(User)
@assert ans isa DataFrame

fall(User)
@assert ans isa DataFrame




#####################
# Updates
#####################

create(User, :name=>"Frodo")
create(User, (:name=>"Bilbo", :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))
create(User, Dict(:name=>"Pippen", :uuid=>UUID("b6dacd6f-0023-4aba-bf24-374f4042fc47")))

u1 = first(User)
update!(u1, :first_name=>"Luke")
update!(u1, (:first_name=>"Luke", :last_name=>"Skywalker"))
update(User, 1, :first_name=>"Luke")
update(User, 1, (:first_name=>"Luke", :last_name=>"Skywalker"))
update(User, 1, Dict(:first_name=>"Luke", :last_name=>"Skywalker"))
update(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), (:first_name=>"Luke", :last_name=>"Skywalker"))
update(u1)

u1 = first(User)
destroy(User, 1)
destroy(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))
destroy(u1)
destroy(User, (:first_name=>"Luke", :last_name=>"Skywalker"))
destroy(User, Dict(:first_name=>"Luke", :last_name=>"Skywalker"))

destroyall(User, :last_name=>"Skywalker")
destroyall([u1, u2])


#####################
# JSON format
#####################


# "tojson" results
user_json = u1 |> tojson
@assert user_json isa String
users_json = users |> tojson
@assert users_json isa String

user_dict_json = user_dict |> tojson
@assert user_dict_json isa String
users_dict_json = users_dict |> tojson
@assert users_dict_json isa String

user_df_json = user_df |> tojson
@assert user_df_json isa String
users_df_json = users_df |> tojson
@assert users_df_json isa String







u1_dict = dfirst(User; select=[:id,:last_name])
@assert typeof(u1_dict) isa Dict

users_dictarray = dall(User; :select=>[:id,:last_name])
@assert typeof(u1_dict) isa Array{Dict}

u1_df = ffirst(User; select=[:id,:last_name])
@assert typeof(u1_df) isa DataFrame

users_dataframe = fall(User; :select=>[:id,:last_name])
@assert typeof(users_dataframe) isa DataFrame

u1_jsonobject = jfirst(User; :select=>[:id,:last_name])
users_jsonarray = jall(User; :select=>[:id,:last_name])

using JSON3
json_string = """[{"a": 1, "b": "hello, world"},{"a": 2, "b": "foo"}]"""
hello_world = JSON3.read(json_string)

using JSONTables
using DataFrames
jtable = jsontable(hello_world)
df = DataFrame(jtable)

using DBInterface
using MySQL
using SQLite

db = SQLite.DB("basic.db")
SQLite.tables(db)
results_df = DBInterface.execute(db, "select * from users") |> DataFrame

# 'id':               { mysqlType: Utils.MYSQL_INT,       mysqlLen: 11,   mysqlAllowNull: false,  mysqlDefault: null },
# 'uuid':             { mysqlType: Utils.MYSQL_CHAR,      mysqlLen: 36,   mysqlAllowNull: false,  mysqlDefault: null },
# 'created_at':       { mysqlType: Utils.MYSQL_DATETIME,  mysqlLen: null, mysqlAllowNull: true,   mysqlDefault: null },
# 'updated_at':       { mysqlType: Utils.MYSQL_DATETIME,  mysqlLen: null, mysqlAllowNull: true,   mysqlDefault: null },
# 'full_name':        { mysqlType: Utils.MYSQL_VARCHAR,   mysqlLen: 255,  mysqlAllowNull: true,   mysqlDefault: null },
# 'first_name':       { mysqlType: Utils.MYSQL_VARCHAR,   mysqlLen: 255,  mysqlAllowNull: true,   mysqlDefault: null },
# 'last_name':        { mysqlType: Utils.MYSQL_VARCHAR,   mysqlLen: 255,  mysqlAllowNull: true,   mysqlDefault: null },


hello_world = Dict("a" => Dict("b" => 1, "c" => 2), "b" => Dict("c" =>3, "d" => 4))
JSON3.write(hello_world)


#################
# Performance
#################

@btime first(User) # 32.209 μs (87 allocations: 5.52 KiB)
@btime tfirst(User) # 31.533 μs (88 allocations: 5.50 KiB)
@btime dfirst(User) # 28.134 μs (78 allocations: 5.12 KiB)

@btime all(User) # 33.727 μs (87 allocations: 5.28 KiB)
@btime dall(User) # 29.010 μs (80 allocations: 4.95 KiB)
@btime tall(User) # 35.686 μs (97 allocations: 5.44 KiB)

@btime selectclause(User) # 375.689 ns (9 allocations: 416 bytes)
@btime limitclause(User, 1) # 153.409 ns (5 allocations: 256 bytes)
@btime colexprs2cols(User, nothing) # 0.035 ns (0 allocations: 0 bytes)

@btime tablename(User) # 1.391 ns (0 allocations: 0 bytes)
@btime fieldname2selectcol(User, Val(:last_name)) # 0.035 ns (0 allocations: 0 bytes)

select_clause = selectclause(User)
limit_clause = limitclause(User, 1)
@btime q = getquery(
    select_clause; 
    limit_clause=limit_clause,
) # 572.793 ns (10 allocations: 624 bytes)
q = getquery(
    select_clause; limit_clause=limit_clause,
)
@btime queryconstructdicts(User,q) # 26.232 μs (47 allocations: 2.95 KiB)
@btime queryconstructtuples(User,q) #  30.095 μs (56 allocations: 3.30 KiB)
@btime queryconstruct(User, q) # 29.260 μs (52 allocations: 3.17 KiB)