class CreateRelationships 
  def up
    create_table :relationships do |t|
      t.integer :followee_id
      t.integer :follower_id
      
      t.timestamps
    end

    add_index :relationships, :followee_id
    add_index :relationships, :follower_id
    add_index :relationships, [:followee_id, :follower_id], unique: true
  end

  def down
    drop_table :relationships
  end
end
