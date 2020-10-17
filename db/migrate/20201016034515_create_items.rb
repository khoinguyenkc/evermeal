class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do | t |
      t.string :name
      t.integer :list_id
      t.integer :user_id
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :expire
      t.string :amount
    end
  end
end
