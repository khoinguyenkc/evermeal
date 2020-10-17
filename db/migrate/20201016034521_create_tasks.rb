class CreateTasks < ActiveRecord::Migration[5.2]
  def change

    create_table :tasks do | t |
      t.string :name
      t.integer :user_id
      t.integer :due
      t.datetime :created_at
      t.datetime :updated_at
    end

  end
end
