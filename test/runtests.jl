include("setup.jl")
using DataFrames

@testset "source macro" begin
end

@testset "relational macro" begin
    # @test typeof(getaddress(first(User))) == Address
    @test typeof(getadmin(first(Manufacturer))) == User
    # @test typeof(getaddress(getadmin(first(Manufacturer)))) == Address
    @test typeof(getproducts(first(Manufacturer))) == Vector{Product}
end

@testset "pk macro" begin
    @test first(Product, 1).key == 1
end

@testset "col macro" begin
    # @test !isnothing(first(Address).zip)
end

@testset "first" begin
    @test typeof(first(Manufacturer)) == Manufacturer
    @test first(Flower).sepal_length == 5.1f0
    @test first(User).id == 1
    @test first(User, 1).id == 1
    @test first(User, "uuid IS NOT NULL").id == 1
    @test first(User, :last_name=>"Baggins").id == 1
    @test first(User, :first_name=>:Bilbo).id == 1
    @test first(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")).id == 1
    @test first(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))).id == 1
    @test first(User, (:last_name=>:Baggins, "uuid IS NOT NULL")).id == 1
    @test first(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"])).id == 1
    @test first(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'")).id == 2
end

@testset "all" begin
    a1 = all(Flower, :sepal_length=>5.9; limit=2)
    @test typeof(a1) == Vector{Flower}
    @test length(a1) == 2
    @test typeof(all(User)) == Vector{User}
    @test 3 == length(all(User, "uuid IS NOT NULL"))
    @test 2 == length(all(User, :last_name=>"Baggins"))
    @test 2 == length(all(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2))
end

@testset "tfirst" begin
    @test tfirst(User).id == 1
    @test tfirst(User, 1).id == 1
    @test tfirst(User, "uuid IS NOT NULL").id == 1
    @test tfirst(User, :last_name=>"Baggins").id == 1
    @test tfirst(User, :first_name=>:Bilbo).id == 1
    @test tfirst(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")).id == 1
    @test tfirst(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))).id == 1
    @test tfirst(User, (:last_name=>:Baggins, "uuid IS NOT NULL")).id == 1
    @test tfirst(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"])).id == 1
    @test tfirst(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'")).id == 2
end

@testset "tall" begin
    @test tall(User) isa Vector{<:NamedTuple}
    @test 3 == length(tall(User, "uuid IS NOT NULL"))
    @test 2 == length(tall(User, :last_name=>"Baggins"))
    @test 2 == length(tall(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2))
end

@testset "dfirst" begin
    @test dfirst(User)[:id] == 1
    @test dfirst(User, 1)[:id] == 1
    @test dfirst(User, "uuid IS NOT NULL")[:id] == 1
    @test dfirst(User, :last_name=>"Baggins")[:id] == 1
    @test dfirst(User, :first_name=>:Bilbo)[:id] == 1
    @test dfirst(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))[:id] == 1
    @test dfirst(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))[:id] == 1
    @test dfirst(User, (:last_name=>:Baggins, "uuid IS NOT NULL"))[:id] == 1
    @test dfirst(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"]))[:id] == 1
    @test dfirst(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'"))[:id] == 2
end

@testset "dall" begin
    @test dall(User) isa Vector{<:Dict}
    @test 3 == length(dall(User, "uuid IS NOT NULL"))
    @test 2 == length(dall(User, :last_name=>"Baggins"))
    @test 2 == length(dall(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2))
end

@testset "ffirst" begin
    @test ffirst(User)[1,:id] == 1
    @test ffirst(User, 1)[1,:id] == 1
    @test ffirst(User, "uuid IS NOT NULL")[1,:id] == 1
    @test ffirst(User, :last_name=>"Baggins")[1,:id] == 1
    @test ffirst(User, :first_name=>:Bilbo)[1,:id] == 1
    @test ffirst(User, UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47"))[1,:id] == 1
    @test ffirst(User, (:id=>1, :uuid=>UUID("c6dacd6f-0023-4aba-bf24-374f4042fc47")))[1,:id] == 1
    @test ffirst(User, (:last_name=>:Baggins, "uuid IS NOT NULL"))[1,:id] == 1
    @test ffirst(User, (:last_name=>:Baggins, :first_name=>["Frodo", "Bilbo"]))[1,:id] == 1
    @test ffirst(User, (:first_name=>:Frodo, "id > 1 OR last_name='Baggins'"))[1,:id] == 2
end

@testset "fall" begin
    @test fall(User) isa DataFrame
    @test 3 == size(fall(User, "uuid IS NOT NULL"), 1)
    @test 2 == size(fall(User, :last_name=>"Baggins"), 1)
    @test 2 == size(fall(User, ("uuid IS NOT NULL", :last_name=>"Baggins"); limit=2), 1)
end