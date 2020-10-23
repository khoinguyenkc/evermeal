class GroceryItemsController < ApplicationController

    get '/groceries/new' do
        #NOT TESTED YET
        if is_logged_in?
            erb :'/groceries/new'
          else
            redirect to '/login'
          end
    end

    get '/groceries/new/batch' do
        if is_logged_in?
            erb :'/groceries/batch_new'
          else
            redirect to '/login'
          end
    end

    post '/groceries' do
        #NOT TESTED YET
        #if its a one click add, it has no separte form page. it just has a button to send the form
        if is_logged_in?
            if params[:items] && !params[:items].empty? #if multiple add
                params[:items].each do | itemhash |
                    if !itemhash[:name].empty?
                        #create item
                        newitem = GroceryItem.create(name: itemhash[:name], amount: itemhash[:amount])
                        #associate with list
                        current_user.grocery_items << newitem
                        current_user.save
                    end
                end
                redirect "/groceries"
            elsif #if single add
                if params[:name].empty?
                    redirect to "/groceries/new"
                else

                    newgroceryitem = GroceryItem.create(name: params[:name], amount: params[:amount])
                    current_user.grocery_items << newgroceryitem
                    current_user.save
                    if newgroceryitem.save 
                        listnames = ["fridge", "freezer", "pantry", "spices"]
                        if listnames.include?(params[:source])
                            redirect "/#{params[:source]}"
                        elsif  params[:source].include?("recipe") #ex: true if params[:source] is "recipe-43"
                            recipeid = params[:source].split("-").last
                            redirect "/recipes/#{recipeid}"
                        else
                            redirect  "/groceries"
                        end
                    else
                        redirect to "/groceries/new"
                    end

                end
            end

        else
        redirect to '/login'
        end
    end


    get '/groceries' do
        if is_logged_in?
          @user_groceries = current_user.grocery_items
          erb :'groceries/index'
        else
          redirect to '/login'
        end
    end

    #NEED EDIT AND DELETE functions

    get '/groceries/:id/edit' do
        @groceryitem = GroceryItem.find_by_id(params[:id])
        #binding.pry
        if is_logged_in?
            if @groceryitem
                groceryitemowner = @groceryitem.user 
                if groceryitemowner == current_user 
                    
                    erb :'/groceries/edit'
                else 
                    "you dont own this grocery item"
                    
                end
            else 
                "grocery item not found"
            end
        else
            redirect '/login'
        end
    end

    get '/groceries/edit/batch' do
        if is_logged_in?
            @grocery_items = current_user.grocery_items
            erb :'/groceries/batch_edit'
        else
            redirect '/login'
        end
    end

    patch '/groceries/batch' do
        if is_logged_in?       
            @grocery_items = current_user.grocery_items     
            params[:items].each do | itemhash |
                if !itemhash[:name].empty?
                    if @grocery_items.find_by(name: itemhash[:name]) #aka IF OLD -
                        #find the item
                        olditem = @grocery_items.find_by(name: itemhash[:name])
                        #update the item
                        olditem.update(name: itemhash[:name], amount: itemhash[:amount])
                        #save item
                        olditem.save
                    elsif !@grocery_items.find_by(name: itemhash[:name]) # aka new
                        #create item
                        newitem = GroceryItem.create(name: itemhash[:name], amount: itemhash[:amount])
                        #associate with list
                        @grocery_items << newitem
                    end
                end
            end

            #delete old items that user no longer want on the list:
            @grocery_items.each do | existentitem |
                #search thru array if any items from the edit form has this name
                searchresult = params[:items].find { |itemhash| itemhash[:name] == existentitem.name }
                #delete item if search didn't find anything
                existentitem.delete if !searchresult
            end

            redirect "/groceries"
        end
    end





    patch '/groceries/:id' do
        @groceryitem = GroceryItem.find_by_id(params[:id])
        if is_logged_in?
            if @groceryitem
                groceryitemowner = @groceryitem.user 
                if groceryitemowner == current_user 
                    if params[:name].empty?
                        redirect "/groceries/#{params[:id]}/edit"
                    else
                        @groceryitem.update(name: params[:name], amount: params[:amount])
                        @groceryitem.save
                        redirect "/groceries"
                    end
                else 
                    "you dont own this grocery item"
                    
                end
            else 
                "grocery item not found"
            end
        else
            redirect '/login'
        end
    end


    delete '/groceries/:id/delete' do
        @groceryitem = GroceryItem.find_by_id(params[:id])
        if is_logged_in?
            if @groceryitem
                groceryitemowner = @groceryitem.user 
                if groceryitemowner == current_user 
                    @groceryitem.delete
                    redirect "/groceries"

                else 
                    "you dont own this grocery item"
                end
            else 
                "grocery item not found"
            end
        else
            redirect '/login'
        end

    end





end