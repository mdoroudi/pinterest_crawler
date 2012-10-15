class CreatePins < ActiveRecord::Migration
  def up
    create_table :pins do |t|
     t.integer :field_id
     t.integer :user_id
     t.integer :board_id
     t.string :img_url
     t.boolean :is_repin, :default => 0
     t.boolean :is_video, :default => 0
     t.string :source
     t.string :link
     t.string :description
     t.string :user_name
    end
  end

  def down
    drop_table :pins
  end
end
