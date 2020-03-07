# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

neighborhoods_table = DB.from(:neighborhoods)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)


before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end


  #  results = Geocoder.search(@params["q"])
   # @lat_long = results.first.coordinates  # gives [lat, long]


get "/" do
    puts neighborhoods_table.all
    @neighborhoods = neighborhoods_table.all.to_a
    view "neighborhoods"
end

get "/neighborhoods/:id" do
    @neighborhood = neighborhoods_table.where(id: params[:id]).to_a[0]
    @reviews = reviews_table.where(neighborhood_id: @neighborhood[:id])
    @review_count = reviews_table.where(neighborhood_id: @neighborhood[:id]).count(:id)

    @avg_affordability_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:affordability_sat)
    @avg_public_transit_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:public_transit_sat)
    @avg_bike_walk_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:bike_walk_sat)
    @avg_safety_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:safety_sat)
    @avg_thing_to_do_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:thing_to_do_sat)
    @avg_overall_sat = reviews_table.where(neighborhood_id: @neighborhood[:id]).avg(:overall_sat)

    @avg_studio_rent = reviews_table.where(neighborhood_id: @neighborhood[:id], unit_type: "Studio").avg(:monthly_rent)
    @avg_1bd_rent = reviews_table.where(neighborhood_id: @neighborhood[:id], unit_type: "One Bedroom").avg(:monthly_rent)
    @avg_2bd_rent = reviews_table.where(neighborhood_id: @neighborhood[:id], unit_type: "Two Bedroom").avg(:monthly_rent)
    @avg_3bd_rent = reviews_table.where(neighborhood_id: @neighborhood[:id], unit_type: "Three Bedroom").avg(:monthly_rent)

    @users_table = users_table
    view "neighborhood"
end

get "/neighborhoods/:id/reviews/new" do
    @neighborhood = neighborhoods_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

get "/events/:id/reviews/create" do
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
    view "logout"
end