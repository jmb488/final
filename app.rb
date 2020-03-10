# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"      
require "geocoder"                                                               #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

account_sid = "ACa1920a096cb2e686c44e88a2f481a87d"
auth_token = "4b6a948b3aebd45fbd9d9d0228261934"
client = Twilio::REST::Client.new(account_sid, auth_token)

neighborhoods_table = DB.from(:neighborhoods)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)


before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end


get "/" do
    puts neighborhoods_table.all
    @neighborhoods = neighborhoods_table.all.to_a
    view "neighborhoods"
end

get "/neighborhoods/:id" do
    #Individual neighborhood from table
    @neighborhood = neighborhoods_table.where(id: params[:id]).to_a[0]
    @location_name = @neighborhood[:name] + ", " + @neighborhood[:city]
    puts @location_name

    @results = Geocoder.search(@location_name)
    puts @results
    @lat_long = @results.first.coordinates  # gives [lat, long]
    puts @lat_long
    @formatted_lat_long = "#{@lat_long[0]},#{@lat_long[1]}"

    #Reviews for the given neighborhood, and total number of reviews
    @reviews = reviews_table.where(neighborhood_id: @neighborhood[:id])
    @review_count = reviews_table.where(neighborhood_id: @neighborhood[:id]).count(:id)

    #Calculated average satisfaction scores for the neighborhood
    @avg_affordability_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:affordability_sat)
    @avg_public_transit_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:public_transit_sat)
    @avg_bike_walk_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:bike_walk_sat)
    @avg_safety_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:safety_sat)
    @avg_thing_to_do_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:thing_to_do_sat)
    @avg_overall_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:overall_sat)

    #Calculated average rent by unit type for hte neighborhood
    @avg_studio_rent = reviews_table.where(neighborhood_id: @neighborhood[:id], unit_type: "Studio").avg(:monthly_rent)
    @avg_1bd_rent = reviews_table.where(neighborhood_id: @neighborhood[:id], unit_type: "1bed").avg(:monthly_rent)
    @avg_2bd_rent = reviews_table.where(neighborhood_id: @neighborhood[:id], unit_type: "2bed").avg(:monthly_rent)
    @avg_3bd_rent = reviews_table.where(neighborhood_id: @neighborhood[:id], unit_type: "3bed").avg(:monthly_rent)

    @users_table = users_table
    
    #If there are reviews, show all data. If there are no reviews show a page inviting the user to be the first to review.
    if @review_count >= 1
        view "neighborhood"
    else
        view "noreview"
    end
end

get "/neighborhoods/:id/reviews/new" do
    @neighborhood = neighborhoods_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

get "/neighborhoods/:id/reviews/create" do
    puts params
    @neighborhood = neighborhoods_table.where(id: params[:id]).to_a[0]
    reviews_table.insert(
                    neighborhood_id: params["id"],
                    user_id: session["user_id"],
                    affordability_sat: params["affordability_sat"],
                    public_transit_sat: params["public_transit_sat"],
                    bike_walk_sat: params["bike_walk_sat"],
                    safety_sat: params["safety_sat"],
                    thing_to_do_sat: params["thing_to_do_sat"],
                    overall_sat: params["overall_sat"],
                    comment: params["comment"],
                    unit_type: params["unit_type"],
                    monthly_rent: params["monthly_rent"],
    )

    @location_name = @neighborhood[:name] + ", " + @neighborhood[:city]
    client.messages.create(
        from: "+12064018863", 
        to: "+12404723172",
        body: "New Review uploaded for #{@location_name}: #{params["comment"]}"
    )

    view "create_review"
end

get "/users/new" do
    view "new_user"
end

get "/users/create" do
    puts params
    users_table.insert(
            name: params["name"],
            email: params["email"],
            password: BCrypt::Password.create(params["password"])
    )

    @user = users_table.where(email: params["email"]).to_a[0]
    session["user_id"] = @user[:id]
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts params
    # If the name = a name in the DB
    # AND the password matches the password for that name
    # then - create_login, else login failed

    email_address = params["email"]
    password = params["password"]

    @user = users_table.where(email: email_address).to_a[0]

    if @user
        if BCrypt::Password.new(@user[:password]) == password
            puts @user
            session["user_id"] = @user[:id]
            @current_user = users_table.where(id: session["user_id"]).to_a[0]
            view "create_login"
        else
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end

end

get "/logout" do
    session["user_id"] = nil
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
    view "logout"
end