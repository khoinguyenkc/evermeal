class RecipesController < ApplicationController

    get '/recipes/new' do
        erb :'/recipes/new'
    end

    post '/recipes' do
        #TESTED. works


        # @params = params
        # erb :temp
        #1. create recipe
        if !params[:recipe][:content].empty? && !params[:recipe][:name].empty?

            newrecipe = Recipe.create(name: params[:recipe][:name], content: params[:recipe][:content])
            current_user.recipes << newrecipe

        #2.  process ingredients 
        process_ingredients_of_recipe(params, newrecipe)
            # params[:recipe][:ing].each do | inghash |
            #     if !inghash[:name].empty?  
            #         #a) find ingredient/create one if new
            #         ingredient = Ingredient.find_or_create_by(name: inghash[:name])
            #         #b) associate recipe <--> ingredients 
            #         ingredient.recipes << newrecipe if !ingredient.recipes.include?(newrecipe)
            #         newrecipe.ingredients << ingredient if !newrecipe.ingredients.include?(ingredient)
            #         #we dont want duplicates added but also sometimes we need to add both sides. its inconsistent hence we do this

            #         #c) add amount to rec-ing
            #         if !inghash[:amount].empty?
            #         rec_ing_instance = RecipeIngredient.find_by(ingredient_id: ingredient.id, recipe_id: newrecipe.id) # this returns the first item that matches both criteria
            #         rec_ing_instance.amount = inghash[:amount] 
            #         rec_ing_instance.save
            #         #warning, apparently you need to save rec ing instance to a variable, THEN set amount, then save
            #         #miss one step it won't save! alternatively, u can use update. that will save.
            #         end
            #     end
            # end
            redirect "/recipes/#{newrecipe.id}" #show recipe
        else
            redirect '/recipes/new'
        end
        
    end

    get '/recipes/:id' do
        #THIS WORKS. tested
        @recipe = Recipe.find_by_id(params[:id])
        
        if is_logged_in?
            if @recipe
                recipeowner = @recipe.user 
                if recipeowner == current_user 
                    
                    erb :'/recipes/show'
                else 
                    "you dont own this item"
                    
                end
            else 
                "recipe not found"
            end
        else
            redirect '/login'
        end
    end

    get '/recipes' do
        #show all recipes OF USER
        @recipes = current_user.recipes
        erb :'/recipes/index'
    end

    get '/recipes/:id/edit' do
        @recipe = Recipe.find_by_id(params[:id])
        if is_logged_in?
            if @recipe
                recipeowner = @recipe.user 
                if recipeowner == current_user 
                    
                    erb :'/recipes/edit'
                else 
                    "you dont own this item"
                    
                end
            else 
                "recipe not found"
            end
        else
            redirect '/login'
        end
    end

    patch '/recipes/:id' do
        #process editing of recipe
        #keep in mind: remove from all the collections, avoid ovreadd, underremove,,
        #try to be efficient, instead of updating everything all over... we want to avoid same rec-ings with diff ids etc... if possible
        #but dont be so insistent either
        #keep in mind our rec ing might have same recipe id and ing id but diff amounts
        #make sure u are finding the right ones...

        #perhaps change the name structure of inputs so we can better control....
        #wish there was a good example of deisng pattern for this
        #ASSUMPTION: no identical name for ingredients in one recipe
        #new ones 
        #are added like normal

        #old ones 
        #are checked to see if the NAME part are in the .ingredients array
        #if it is in there, it means that ingredient is there, only the amount is changed
        #thus we will look up the rec-ing, and edit the amount
        #this relies on the fact that we dont have many rec ings of diff ids with the same recipe id and same ingredient id
        #otherwise we will not be able to know which one is the latest, correct amount
        #thus it is important that elsewehre we do not mess with it

        #actually it turns out we're gonna reuse the same process as adding
        #since the adding already had all these checks to make sure not to add redundant things 
        #so we simply need to add a bit more at the end
        
        #process_ingredients_of_recipe seems to work for create but not for edit
        therecipe = Recipe.find_by_id(params[:id])
        if is_logged_in?
            if therecipe
                recipeowner = therecipe.user 
                if recipeowner == current_user 
                    therecipe.update(content: params[:recipe][:content])
                    #add new ings and modify existent ings:
                    process_ingredients_of_recipe(params, therecipe)
                    #clear old ings:
                    therecipe.ingredients.each do | existenting |
                        #search thru array if any ings from the edit form has this name
                        searchresult = params[:recipe][:ing].find { |inghash| inghash[:name] == existenting.name }
                        #remove associations if search didn't find anything
                        if !searchresult
                            therecipe.ingredients.delete(existenting)
                            therecipe.save
                            existenting.recipes.delete(therecipe)
                            existenting.save
                        end

                    end
                    #redirect
                    redirect "/recipes/#{therecipe.id}" #show recipe
                else 
                    "you dont own this item"
                    
                end
            else 
                "recipe not found"
            end
        else
            redirect '/login'
        end
    end

    delete '/recipes/:id/delete' do

        therecipe = Recipe.find_by_id(params[:id])
        
        if is_logged_in?
            if therecipe
                recipeowner = therecipe.user 
                if recipeowner == current_user 
                    #remove the recipe automatically remove associations
                    therecipe.delete
                    redirect "/recipes"
                else 
                    "you dont own this item"
                    
                end
            else 
                "recipe not found"
            end
        else
            redirect '/login'
        end

    end

    get '/recipes/search/:itemname' do
        #search thru 4 lists &accumulate results
        @searchquery = params[:itemname]
        @resultarray = []

        if is_logged_in?
            
            current_user.recipes.each do | recipe |
                recipe.ingredients.each  do | ing |
                    if ing.name.include?(params[:itemname]) && !@resultarray.include?(ing)
                        @resultarray << ing 
                    end
                end
                    
                
            end
            #display result    
            
            erb :'/recipes/searchresult'
            
        else
            redirect '/login'
        end


    end

        
    
    helpers do
        
        def process_ingredients_of_recipe(params, recipe)
            #used for both adding a recipe and editing a recipe
            params[:recipe][:ing].each do | inghash |
                if !inghash[:name].empty?  
                    #a) find ingredient/create one if new
                     ingredient = Ingredient.find_or_create_by(name: inghash[:name])
                    #b) associate recipe <--> ingredients 
                    ingredient.recipes << recipe if !ingredient.recipes.include?(recipe)
                    recipe.ingredients << ingredient if !recipe.ingredients.include?(ingredient)
                    #we dont want duplicates added but also sometimes we need to add both sides. its inconsistent hence we do this
                    
                    #c) add amount to rec-ing
                    if !inghash[:amount].empty?
                    rec_ing_instance = RecipeIngredient.find_by(ingredient_id: ingredient.id, recipe_id: recipe.id) # this returns the first item that matches both criteria
                    rec_ing_instance.amount = inghash[:amount] 
                    rec_ing_instance.save
                    #warning, apparently you need to save rec ing instance to a variable, THEN set amount, then save
                    #miss one step it won't save! alternatively, u can use update. that will save.
                    end
                end
            end
        end

    end

end