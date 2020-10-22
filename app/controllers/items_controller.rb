class ItemsController < ApplicationController

    get '/items/new' do
        @prefilledcab = "" #to prevent nil class error
        erb :'/items/new'
    end

    

    post '/items' do
        #{"name"=>"fritata", "list"=>"pantry", "amount"=>"2 pies", "expire"=>"7"}
        if params[:items] && !params[:items].empty? #IF this is a BATCH ADD
            batch_add_items(params)
        elsif params[:name] && !params[:name].empty? && !params[:list].empty? #if a valid SINGLE ADD

            newitem = Item.create(name: params[:name], amount: params[:amount], expire: params[:expire])
            #SOMEHOW THE amount is lost if it's moved from grocery!?
            list = give_me_list(params[:list])  
            list.items << newitem
            if params[:moved_from_grocery_id] 
                groceryitem = GroceryItem.find_by(id: params[:moved_from_grocery_id].to_i)
                #delete grocery item
                groceryitem.delete
                #go back to grocery page, not to list
                redirect "/groceries"
            end

            if params[:moved_from_cabinet_item_id] 
                olditem = Item.find_by(id: params[:moved_from_cabinet_item_id].to_i)
                listofolditem = olditem.list.name.downcase
                #delete  item
                olditem.delete
                #go back to grocery page, not to list
                redirect "/#{listofolditem}"
            end

            list.save
            redirect "/#{params[:list]}" #ex: /freezer
        else
            redirect '/items/new'
        end
        
    end

    get '/items/new/:cabinet' do
        @prefilledcab = ""
        if params[:cabinet] == "fridge" || params[:cabinet] == "freezer" || params[:cabinet] == "pantry" || params[:cabinet] == "spices"
            @prefilledcab = params[:cabinet]
        end
        #somehow add the prefilled choice. not sure thats how u should set@prefilledcab value
        erb :'/items/new'

    end

    get '/items/new/:cabinet/batch' do
        @list = give_me_list(params[:cabinet])
        erb :'/items/batch_new'
    end

    

    get '/items/:id/edit' do
        #edit form
        item = Item.find_by_id(params[:id])
        
        if is_logged_in?
            if item
                list = item.list 
                if item.list.user == current_user 
                    @item = item
                    erb :'/items/edit'
                else 
                    "you dont own this item"
                end
            else 
                "item not found"
            end
        else
            redirect '/login'
        end
    end

    get '/items/edit/:cabinet/batch' do
        if is_logged_in?
            @list = give_me_list(params[:cabinet])
            erb :'/items/batch_edit'
        else
            redirect '/login'
        end
    end

    patch '/items/batch' do
        if is_logged_in?
            list = give_me_list(params[:list]) 
            
                params[:items].each do | itemhash |
                    if !itemhash[:name].empty?
                        if list.items.find_by(name: itemhash[:name]) #aka IF OLD - if list.items  include this item insatce with this NAME
                            #find the item
                            olditem = list.items.find_by(name: itemhash[:name])
                            #update the item
                            olditem.update(name: itemhash[:name], amount: itemhash[:amount], expire: itemhash[:expire])
                            #save item
                            olditem.save
                        elsif !list.items.find_by(name: itemhash[:name]) # aka list.items doesn't includ this NAME 
                            #create item
                            newitem = Item.create(name: itemhash[:name], amount: itemhash[:amount], expire: itemhash[:expire])
                            #associate with list
                            list.items << newitem
                        end
                    end
                end


            #delete old items that user no longer want on the list:
            list.items.each do | existentitem |
                #search thru array if any items from the edit form has this name
                searchresult = params[:items].find { |itemhash| itemhash[:name] == existentitem.name }
                #delete item if search didn't find anything
                existentitem.delete if !searchresult
            end

            redirect "/#{params[:list]}"
        else
            redirect '/login'
        end

    end

    patch '/items/:id' do
        #process edit. be careful with the switching of lists
        #make sure every list is cleared properly
        redirect to "/items/#{params[:id]}/edit" if params[:name].empty? 
        
        item = Item.find_by_id(params[:id])

        if is_logged_in?
            if item
                list = item.list 
                if item.list.user == current_user 
                    #security has cleared. now we're gonna TRY to update
                    if item.update(name: params[:name], amount: params[:amount], expire: params[:expire]) #should update if input are string/integer compliant etc..
                        #its an if but it happens! 
                        #1. now we update the associated list if necessary:
                        if list.name.downcase != params[:list] #aka if theres list change
                            #a) remove from current list
                            list.items.delete(item)
                            #b) add to new list 
                            newlist = give_me_list(params[:list])
                            newlist.items << item
                            item.list = newlist
                            item.save
                        end
                        # 2. redirect:
                        redirect "/#{item.list.name.downcase}"

                    else
                        redirect to "/items/#{params[:id]}/edit"
                    end
                else 
                    "you dont own this item"
                end
            else 
                "item not found"
            end
        else
            redirect '/login'
        end

    end

    delete '/items/:id/delete' do
        item = Item.find_by_id(params[:id])
        
        if is_logged_in?

            if item
                list = item.list #step by step to avoid nil class error
                #check that he owns the item:
                if item.list.user == current_user 
                    item.delete
                    #i think this will remove it from any collection as well
                    redirect "/#{list.name.downcase}" #ex: /freezer
                    #this depends on the fact that after item is deleted, item.list's value is still remaining in the list variable... it needs to hold its own copy of the value.
                else 
                    #this is a not a GET kinda thing so errors not likely to happen but we still want to stay very fool proof and hackproof. we want to stay fool proof to OURSELVES. we might expose vulnerabilities. 
                    "you dont own this item"
                end
            else 
                "item not found"
            end
        else
            redirect '/login'
        end
      
    end

    get '/items/search/:ingname' do
        #search thru 4 lists &accumulate results
        @searchquery = params[:ingname]
        @resultarray = []

        if is_logged_in?
            
            user_lists.each do | list |
                if list.name.downcase != "spoiled"
                    list.items.each  do | item |
                        if item.name.include?(params[:ingname]) && !@resultarray.include?(item)
                            @resultarray << item 
                        end
                    end
                end
            end
            #display result    
            
            erb :'/items/searchresult'
            
        else
            redirect '/login'
        end


    end

    helpers do
        def batch_add_items(params) 
            params[:items].each do | itemhash |
                if !itemhash[:name].empty?
                    #create item
                    newitem = Item.create(name: itemhash[:name], amount: itemhash[:amount], expire: itemhash[:expire])
                    #associate with list
                    list = give_me_list(params[:list])  
                    binding.pry
                    list.items << newitem
                    
                end
            end
            redirect "/#{params[:list]}"
        end



    end #end helpers


end