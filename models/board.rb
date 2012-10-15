require_relative '../database_configuration'

class Board < ActiveRecord::Base
  attr_accessor :field_id, :user_id, :user_name, :slug, :description, :category, :name
  attr_accessible :field_id, :user_id, :user_name, :slug, :description, :category, :name


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

  #TODO
  def self.json_create(o)
  end
end 
