class ApplicationController < Sinatra::Base

    configure do
        set :public_folder, 'public'
        set :views, 'app/views'
        enable :sessions
        set :session_secret, "secret"
    end

    get '/' do
        if is_logged_in?
        erb :'users/user_home'  
        #homepage with links to kitchen cabinets, tasks, grocery items, recipes  
        else
        erb :lockedhome
        
        end
    end

    

    helpers do
    
        def is_logged_in?
         session[:user_id] ? true : false #if user_id key exist s
        end
    
        def current_user
          User.find(session[:user_id])
        end

        def initialize_user_lists
          #this method is meant to be called when the user is first created
          #we create the 4 kitchen cabinets 
          if current_user.lists.empty? #safeguard accidental call
          fridge = List.create(name: "Fridge") 
          freezer = List.create(name: "Freezer") 
          pantry = List.create(name: "Pantry") 
          spices = List.create(name: "Spices")
          spoiled = List.create(name: "Spoiled")
          current_user.lists << fridge
          current_user.lists << freezer 
          current_user.lists << pantry  
          current_user.lists << spices
          current_user.lists << spoiled
          current_user.save
          end
          #this must be safeguarded because the way each cabinet is laoded is we find by name
        end

        def user_lists 
          fridge =  current_user.lists.find { | list | list.name == "Fridge" }
          freezer =  current_user.lists.find { | list | list.name == "Freezer" }
          pantry =  current_user.lists.find { | list | list.name == "Pantry" }
          spices =  current_user.lists.find { | list | list.name == "Spices" }
          spoiled =  current_user.lists.find { | list | list.name == "Spoiled" }
          result = [ fridge, freezer, pantry, spices, spoiled ]  
        end

        def give_me_list(listname)
          case listname
          when "fridge"
              list = user_lists[0]
          when "freezer"
              list = user_lists[1]
          when "pantry"
              list = user_lists[2]
          when "spices"
              list = user_lists[3]
          when "spoiled"
              list = user_lists[4]
          end
          list
        end



        
      end
    


end #end class