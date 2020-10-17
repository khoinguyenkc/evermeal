class CreateGroceryItems < ActiveRecord::Migration[5.2]
  def change
    
    create_table :grocery_items do | t |
      t.string :name
      t.integer :user_id
      t.integer :amount
    end


  end
end
