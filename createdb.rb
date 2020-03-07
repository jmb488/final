# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
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


neighborhoods_table.insert(name: "West Loop", 
                    city: "Chicago",
                    density: 21644,
                    income: 107626)


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



reviews_table.insert(
                    neighborhood_id:1,
                    user_id:0,
                    affordability_sat:4,
                    public_transit_sat:4,
                    bike_walk_sat:4,
                    safety_sat:4,
                    thing_to_do_sat:4,
                    overall_sat:4,
                    comment:"Great!",
                    unit_type:"Studio",
                    monthly_rent:1500
)


reviews_table.insert(
                    neighborhood_id:1,
                    user_id:1,
                    affordability_sat:5,
                    public_transit_sat:5,
                    bike_walk_sat:5,
                    safety_sat:5,
                    thing_to_do_sat:5,
                    overall_sat:5,
                    comment:"Great!",
                    unit_type:"Studio",
                    monthly_rent:1300
)