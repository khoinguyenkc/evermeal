require_relative './config/environment'

require './config/environment'
#think avi had this extra dupe by mistake

if ActiveRecord::Base.connection.migration_context.needs_migration?
    raise "migration pending. run rake db:migrate to do that"
end


use Rack::MethodOverride
use GroceryItemsController
use IngredientsController
use ItemsController
use ListsController
use RecipesController
use TasksController
use UsersController
run ApplicationController