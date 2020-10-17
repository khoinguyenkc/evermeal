class ItemsController < ApplicationController

    get '/items/new' do
        erb :'/items/new'
    end

    post '/items' do
        #{"name"=>"fritata", "list"=>"pantry", "amount"=>"2 pies", "expire"=>"7"}
        
    end

end