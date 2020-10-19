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
            params[:recipe][:ing].each do | inghash |
                if !inghash[:name].empty?  
                    #a) find ingredient/create one if new
                    ingredient = Ingredient.find_or_create_by(name: inghash[:name])
                    #b) associate recipe <--> ingredients 
                    ingredient.recipes << newrecipe if !ingredient.recipes.include?(newrecipe)
                    newrecipe.ingredients << ingredient if !newrecipe.ingredients.include?(ingredient)
                    #we dont want duplicates added but also sometimes we need to add both sides. its inconsistent hence we do this

                    #c) add amount to rec-ing
                    if !inghash[:amount].empty?
                    rec_ing_instance = RecipeIngredient.find_by(ingredient_id: ingredient.id, recipe_id: newrecipe.id) # this returns the first item that matches both criteria
                    rec_ing_instance.amount = inghash[:amount] 
                    rec_ing_instance.save
                    #warning, apparently you need to save rec ing instance to a variable, THEN set amount, then save
                    #miss one step it won't save! alternatively, u can use update. that will save.
                    end
                end
            end
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


    get '/recipes/:id/edit' do
    end
    

        
        
    
end