class CreateBoards < ActiveRecord::Migration
  def up
    create_table :boards do |t|
       t.integer :field_id
       t.integer :user_id
       t.string :user_name
       t.string :slug
       t.string :description
       t.string :category
       t.string :name 
    end
  end

  def down
    drop_table :boards
  end
end
