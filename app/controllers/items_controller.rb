class ItemsController < ApplicationController

    get '/items/new' do
        @prefilledcab = "" #to prevent nil class error
        erb :'/items/new'
    end

    post '/items' do
        #{"name"=>"fritata", "list"=>"pantry", "amount"=>"2 pies", "expire"=>"7"}
        
        if !params[:name].empty? && !params[:list].empty?

            newitem = Item.create(name: params[:name], amount: params[:amount], expire: params[:expire])

            list = give_me_list(params[:list])  
            list.items << newitem
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

    patch '/items/:id/' do
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


end