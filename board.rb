class Board 
  attr_accessor :field_id, :user_id, :user_name, :slug, :description, :category, :name

  def initialize(hash)
    hash.each do |key_value|
    end
  end
  
  def to_json
    {
      field_id: field_id,
      user_id: user_id,
      user_name: user_name,
      slug: slug,
      description: description,
      category: category,
      name: name,
    }
  end

  def self.json_create(o)
    obj = new()
  end
end 
