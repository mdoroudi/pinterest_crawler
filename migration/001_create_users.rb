class CreateUsers< ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.integer :user_id 
      t.string :user_name
      t.string :about
    end
  end

  def down
    drop_table :users
  end
end
