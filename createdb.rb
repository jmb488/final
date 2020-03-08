# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
# Neighborhood input data comes from: https://statisticalatlas.com/place/Illinois/Chicago/Overview

DB.create_table! :neighborhoods do
    primary_key :id
    String :name
    String :city
    Integer :density
    Integer :income
end
DB.create_table! :reviews do
    primary_key :id
    foreign_key :neighborhood_id
    foreign_key :user_id
    Integer :affordability_sat
    Integer :public_transit_sat
    Integer :bike_walk_sat
    Integer :safety_sat
    Integer :thing_to_do_sat
    Integer :overall_sat
    String :comment, text: true
    String :unit_type
    Integer :monthly_rent
end
DB.create_table! :users do
    primary_key :id
    String :name
    String :email
    String :password
end

# Insert initial (seed) data
neighborhoods_table = DB.from(:neighborhoods)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

#List of 10 Neighborhoods

neighborhoods_table.insert(name: "Lincoln Park", 
                    city: "Chicago",
                    density: 21322,
                    income: 100624)


neighborhoods_table.insert(name: "Lakeview East", 
                    city: "Chicago",
                    density: 40266,
                    income: 66564)


neighborhoods_table.insert(name: "Uptown", 
                    city: "Chicago",
                    density: 20984,
                    income: 37609)


neighborhoods_table.insert(name: "Streeterville", 
                    city: "Chicago",
                    density: 33871,
                    income: 99350)


neighborhoods_table.insert(name: "Wicker Park", 
                    city: "Chicago",
                    density: 21742,
                    income: 95586)

            
neighborhoods_table.insert(name: "Logan Square", 
                    city: "Chicago",
                    density: 25602,
                    income: 53980)


neighborhoods_table.insert(name: "Albany Park", 
                    city: "Chicago",
                    density: 31880,
                    income: 53349)


neighborhoods_table.insert(name: "South Loop", 
                    city: "Chicago",
                    density: 10765,
                    income: 80940)


neighborhoods_table.insert(name: "Pilsen", 
                    city: "Chicago",
                    density: 14411,
                    income: 37308)


neighborhoods_table.insert(name: "Bridgeport", 
                    city: "Chicago",
                    density: 13199,
                    income: 44968)

#List of Users

users_table.insert(
                    name:"John D"
)

users_table.insert(
                    name:"Joan B"
)

users_table.insert(
                    name:"Jeff J"
)

users_table.insert(
                    name:"James D"
)

users_table.insert(
                    name:"Jordan T"
)

users_table.insert(
                    name:"Joe M"
)

users_table.insert(
                    name:"Jessica R"
)

users_table.insert(
                    name:"Jennifer A"
)

users_table.insert(
                    name:"Julia M"
)


# Reviews data

reviews_table.insert(
                    neighborhood_id:1,
                    user_id:1,
                    affordability_sat:4,
                    public_transit_sat:4,
                    bike_walk_sat:4,
                    safety_sat:4,
                    thing_to_do_sat:4,
                    overall_sat:4,
                    comment:"It is a very nice neighborhood that includes DePaul University. It also has a lot of shopping areas that include boutiques and small mom and pop shops which I appreciate. I enjoy Armitage st a lot. There is where you will find many small boutiques and it is a very nice place to look around.",
                    unit_type:"Studio",
                    monthly_rent:1500
)


reviews_table.insert(
                    neighborhood_id:1,
                    user_id:2,
                    affordability_sat:5,
                    public_transit_sat:5,
                    bike_walk_sat:5,
                    safety_sat:5,
                    thing_to_do_sat:5,
                    overall_sat:5,
                    comment:"I love this neighborhood. Every street you see a variety of cultures. The area is very close to the city as well as the lake front.",
                    unit_type:"Studio",
                    monthly_rent:1400
)

reviews_table.insert(
                    neighborhood_id:1,
                    user_id:3,
                    affordability_sat:3,
                    public_transit_sat:4,
                    bike_walk_sat:5,
                    safety_sat:4,
                    thing_to_do_sat:5,
                    overall_sat:4,
                    comment:"Lincoln Park is in the midst of a demographic adjustment. Although the $1M+ townhomes w/rooftop decks sit right next to senior buildings, it is still well protected, safe to walk your dog at night, non-stressful type of neighborhood where you can breathe.",
                    unit_type:"1bed",
                    monthly_rent:2100
)

reviews_table.insert(
                    neighborhood_id:1,
                    user_id:4,
                    affordability_sat:3,
                    public_transit_sat:4,
                    bike_walk_sat:5,
                    safety_sat:5,
                    thing_to_do_sat:4,
                    overall_sat:4,
                    comment:"I am at the perfect distance of big city and residential living with urban vibes. Local restaurants and boutiques are bountiful, and there is always some cozy cafe or bar popping up. Nightlife exists, but it is never so loud or dangerous (or barf covered).",
                    unit_type:"1bed",
                    monthly_rent:2000
)

