class CommentsController < ApplicationController

    
    get '/comments/new/:recipesourceid' do
        @recipesourceid = params[:recipesourceid]
        erb :'/comments/new'
    end

    post '/comments' do
        #comments belong to a recipe. must know the recipe
        if is_logged_in?
            
            if params[:recipesourceid].empty?
                "error. no recipe source."
            elsif params[:content].empty?
                redirect to "/comments/new/#{params[:recipesourceid]}"
            else
                current_recipe = Recipe.find_by(id: params[:recipesourceid].to_i)
                newcomment = Comment.create(content: params[:content])
                current_recipe.comments << newcomment
                if newcomment.save #to be extra safe
                    redirect to "/recipes/#{params[:recipesourceid]}"
                else
                    redirect to "/comments/new/#{params[:recipesourceid]}"
                end
            end

        else
        redirect to '/login'
        end

    end

    get '/comments/:id/edit' do
        #NOT TESTED YET
        @comment = Comment.find_by(id: params[:id])

        if is_logged_in?
            if @comment
                commentowner = @comment.recipe.user
                if commentowner == current_user 
                    
                    erb :'/comments/edit'
                else 
                    "you dont own this comment"
                    
                end
            else 
                "comment not found"
            end
        else
            redirect '/login'
        end

    end

    patch '/comments/:id' do
        #NOT TESTED YET
        @comment = Comment.find_by(id: params[:id])

        if is_logged_in?
            if @comment
                commentowner = @comment.recipe.user
                if commentowner == current_user 
                    if params[:content].empty?
                        redirect "/comments/#{params[:id]}/edit"
                    else
                        @comment.update(content: params[:content])
                        @comment.save
                        redirect "/recipes/#{@comment.recipe.id}"
                    end
                else 
                    "you dont own this comment"
                    
                end
            else 
                "comment not found"
            end
        else
            redirect '/login'
        end

    end


    delete '/comments/:id/delete' do
        redirect '/login' if !is_logged_in? 
    
        comment = Comment.find_by(id: params[:id])
        recipe = comment.recipe
        if comment && current_user.id == comment.recipe.user.id
                comment.delete
        end

        #if tweet is found or not, after we delete the tweet, we go here
        redirect "recipes/#{recipe.id}"
    end

end

