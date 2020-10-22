class TasksController < ApplicationController

    get '/tasks/new' do
        if is_logged_in?
            erb :'/tasks/new'
          else
            redirect to '/login'
          end
    end

    post '/tasks' do

        if is_logged_in?
            
            if params[:name].empty?
                redirect to "/tasks/new"
            else
                newtask = Task.create(name: params[:name], due: params[:due])
                current_user.tasks << newtask
                current_user.save
                if newtask.save #to be extra safe
                    redirect to "/tasks"
                else
                    redirect to "/tasks/new"
                end
            end

        else
        redirect to '/login'
        end
    end

    get '/tasks' do
        if is_logged_in?
          @tasks = current_user.tasks
          erb :'tasks/index'
        else
          redirect to '/login'
        end
    end

    get '/tasks/:id/edit' do
        @task = Task.find_by_id(params[:id])
        if is_logged_in?
            if @task
                taskowner = @task.user 
                if taskowner == current_user 
                    
                    erb :'/tasks/edit'
                else 
                    "you dont own this task"
                    
                end
            else 
                "task not found"
            end
        else
            redirect '/login'
        end
    end


    patch '/tasks/:id' do
        @task = Task.find_by(id: params[:id])

        if is_logged_in?
            if @task
                taskowner = @task.user
                if taskowner == current_user 
                    if params[:name].empty?
                        redirect "/tasks/#{params[:id]}/edit"
                    else
                        @task.update(name: params[:name], due: params[:due])
                        @task.save
                        redirect "/tasks"
                    end
                else 
                    "you dont own this task"
                    
                end
            else 
                "task not found"
            end
        else
            redirect '/login'
        end

    end




    delete '/tasks/:id/delete' do
        task = Task.find_by_id(params[:id])
        
        if is_logged_in?
            if task
                taskowner = task.user 
                if taskowner == current_user 
                    #remove the recipe automatically remove associations
                    task.delete
                    redirect "/tasks"
                else 
                    "you dont own this task"
                    
                end
            else 
                "task not found"
            end
        else
            redirect '/login'
        end
    end

    


    

end