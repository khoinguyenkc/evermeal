class UsersController < ApplicationController
    get '/users/:slug' do
      
      @user = User.find_by_slug(:slug)
      erb :'/users/user_home'
        
    end


    get '/signup' do 
        #if signed in, redirect to /
        redirect '/' if is_logged_in?
        #show signup form
          erb :'users/create_user'
      end
    
      post '/signup' do
        #process, then redirect to /
        if !params[:username].empty? && !params[:email].empty? && !params[:password].empty?
          @user = User.new(username: params[:username], email: params[:email], password: params[:password])
          @user.save
          session[:user_id] = @user.id
          initialize_user_lists #order matters. need to set session user id first before i can use this
          redirect '/'
        else #signup inputs problematic
          redirect '/signup'
        end
    
      end
    
      
    
      get '/login' do
        #if signed in, redirect to /
        redirect '/' if is_logged_in?
        #otherwise, show login form
        erb :'users/login'
      end
    
      post '/login' do
        #process, then redirect to /
        @user = User.find_by(username: params[:username])
    
        #if correct login:
        if @user && @user.authenticate(params[:password])
          session[:user_id] = @user.id
          redirect '/'
        else #wrong password or username
          redirect '/login'
        end
    
      end
    
      get '/logout' do
        #if already logged out, redirect to  '/'
        redirect '/' if !is_logged_in?
        #otherwise 
        session.clear
        redirect '/login'
      end
    
end
