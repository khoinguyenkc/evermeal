class ListsController < ApplicationController

    get '/fridge' do
        @list =  user_lists[0]
        erb :'/lists/show'
    end

    get '/freezer' do
        @list =  user_lists[1]
        erb :'/lists/show'
    end

    get '/pantry' do
        @list =  user_lists[2]
        erb :'/lists/show'
    end

    get '/spices' do
        @list =  user_lists[3]
        erb :'/lists/show'
    end

    get '/spoiled' do
        @list = user_lists[4]
        erb :'/lists/show'
    end
end