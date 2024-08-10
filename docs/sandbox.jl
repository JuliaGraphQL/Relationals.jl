cd(@__DIR__)
using Relationals, UUIDs, Dates

struct Flower <: Relational
    sepal_length::Float32
    sepal_width::Float32
    petal_length::Float32
    petal_width::Float32
    species::String
end

first(Flower)
all(Flower; limit=3)
all(Flower)
first(Flower; order=(:sepal_length, :ASC))
first(Flower; order=(:sepal_length, :DESC))
last(Flower; order=(:sepal_length, :ASC))
last(Flower; order=(:sepal_length, :DESC))
last(Flower)

create(Flower, (:sepal_length=>1.0, :sepal_width=>1.1, :petal_length=>1.2, :petal_width=>1.3, :species=>"abc3"))
@showsql last(Flower)

###########################################

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
    created_at::String
    updated_at::String
    name::String
    manufacturer_id::Int
    archived::Bool
end
@tablename Product :items
@pk Product :key
@scope Product :archived=>false

archive(::Type{Product}, key) = update(Product, key, :archived=>true)
unarchive(::Type{Product}, key) = update(Product, key, :archived=>false; unscoped=true)

all(Product; order=(:key,:DESC))
all(Product; unscoped=true)
archive(Product, 1)
#all(Product)
unarchive(Product, 2)
unarchive(Product, 1)
all(Product)


@showsql update(Product, 2, :archived=>false; unscoped=true)
# CORRECT: UPDATE items SET archived=false WHERE (key=2)
# INCORRECT: UPDATE items SET key=2 WHERE (archived=false)

@showsql update(Manufacturer, 1, :name=>:foo)

struct Manufacturer <: Relational
    id::Int
    created_at::String
    updated_at::String
    name::String
    admin_id::Int
end
@belongs_to Manufacturer :admin=>User
@has_many Manufacturer :products

getaddress(first(User))
first(Manufacturer)
getadmin(first(Manufacturer))
getaddress(getadmin(first(Manufacturer)))
getproducts(first(Manufacturer))
count.([User,Address,Product,Manufacturer])

# m = RelationalMutation(Manufacturer, (:name=>"foo",), (:id=>1,))
# getsql(Manufacturer, m)

all(Product; scope=:region_east)

@showsql first(User)
@showsql update(Manufacturer, 1, :name=>"test")

#create(Manufacturer, :name=>"Sauron Supplies"; show_sql=true)
create(Manufacturer, (:name=>"Sauron Supplies 2", :admin_id=>2))
@showsql createmany(Manufacturer, (:name=>["x","y","z"], :admin_id=>[11,22,33]))
createmany(Manufacturer, (:name=>[:x,:y,:z], :admin_id=>[11,22,33]))

update(Manufacturer, 1, :name=>:foo)
update(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), :address_id=>1)
update(Manufacturer, 1, (:name=>:bar, :admin_id=>5))
update(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"), (:first_name=>:bar, :address_id=>3))

@showsql updatemany(Manufacturer, :zone=>:EST; values=:name=>:bar)
@showsql updatemany(Manufacturer, :zone=>:EST; values=(:name=>:bar, :admin_id=>5))
@showsql updatemany(Manufacturer, (:zone=>:EST, :id=>1); values=:name=>:bar)
@showsql updatemany(Manufacturer, (:zone=>:EST, :id=>1); values=(:name=>:bar, :admin_id=>5))

@showsql destroy(Manufacturer, 1)
all(Manufacturer)
@showsql destroymany(Manufacturer, :zone=>:EST)
@showsql destroymany(Manufacturer, (:zone=>:EST, :id=>1))

#####################################################################################

first(User)
first(User, 1)
first(User, "uuid IS NOT NULL")
first(User, :last_name=>"Baggins")
first(User, :first_name=>:Bilbo)
first(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))
first(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))
first(User, (:last_name=>:Baggins, "uuid IS NOT NULL"))
first(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"]))
first(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'"))

#######

all(User)
all(User, "uuid IS NOT NULL")
all(User, :last_name=>"Baggins")
all(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2)

#######

tfirst(User)
tfirst(User, 1)
tfirst(User, "uuid IS NOT NULL")
tfirst(User, :last_name=>"Baggins")
tfirst(User, :first_name=>:Bilbo)
tfirst(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))
tfirst(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))
tfirst(User, (:last_name=>:Baggins, "uuid IS NOT NULL"))
tfirst(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"]))
tfirst(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'"))

#######

tall(User)
tall(User, "uuid IS NOT NULL")
tall(User, :last_name=>"Baggins")
tall(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2)

#######

dfirst(User)
dfirst(User, 1)
dfirst(User, "uuid IS NOT NULL")
dfirst(User, :last_name=>"Baggins")
dfirst(User, :first_name=>:Bilbo)
dfirst(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))
dfirst(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))
dfirst(User, (:last_name=>:Baggins, "uuid IS NOT NULL"))
dfirst(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"]))
dfirst(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'"))

#######

dall(User)
dall(User, "uuid IS NOT NULL")
dall(User, :last_name=>"Baggins")
dall(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2)

#######

ffirst(User)
ffirst(User, 1)
ffirst(User, "uuid IS NOT NULL")
ffirst(User, :last_name=>"Baggins")
ffirst(User, :first_name=>:Bilbo)
ffirst(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))
ffirst(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))
ffirst(User, (:last_name=>:Baggins, "uuid IS NOT NULL"))
ffirst(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"]))
ffirst(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'"))

#######

fall(User)
fall(User, "uuid IS NOT NULL")
fall(User, :last_name=>"Baggins")
fall(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2)