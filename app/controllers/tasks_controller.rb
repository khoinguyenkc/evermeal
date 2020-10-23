class TasksController < ApplicationController

    get '/tasks/new' do
        if is_logged_in?
            erb :'/tasks/new'
          else
            redirect to '/login'
          end
    end

    get '/tasks/new/batch' do
        erb :'/tasks/batch_new'
    end
    
    post '/tasks' do

        if is_logged_in?
            if params[:tasks] && !params[:tasks].empty? #if MULTIPLE add
                params[:tasks].each do | taskhash |
                    if !taskhash[:name].empty?
                        #create task
                        newtask = Task.create(name: taskhash[:name], due: taskhash[:due])
                        #associate with list
                        current_user.tasks << newtask
                        current_user.save
                    end
                end
                redirect "/tasks"

            elsif #single add
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
            
            end
        else #not logged in
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

    get '/tasks/edit/batch' do
        if is_logged_in?
            @tasks = current_user.tasks
            erb :'/tasks/batch_edit'
        else
            redirect '/login'
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


    patch '/tasks/batch' do
        if is_logged_in?       
            @tasks = current_user.tasks     
                params[:tasks].each do | taskhash |
                    if !taskhash[:name].empty?
                        if @tasks.find_by(name: taskhash[:name]) #aka IF OLD -
                            #find the task
                            oldtask = @tasks.find_by(name: taskhash[:name])
                            #update the task
                            oldtask.update(name: taskhash[:name], due: taskhash[:due])
                            #save task
                            oldtask.save
                        elsif !@tasks.find_by(name: taskhash[:name]) # aka new
                            #create item
                            newtask = Task.create(name: taskhash[:name], due: taskhash[:due])
                            #associate with list
                            @tasks << newtask
                        end
                    end
                end


            #delete old tasks that user no longer want on the list:
            @tasks.each do | existenttask |
                #search thru array if any task from the edit form has this name
                searchresult = params[:tasks].find { |taskhash| taskhash[:name] == existenttask.name }
                #delete task if search didn't find anything
                existenttask.delete if !searchresult
            end

            redirect "/tasks"
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