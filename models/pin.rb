require_relative '../database_configuration'

class Pin < ActiveRecord::Base 

  attr_accessor :field_id, :user_id, :board_id, :img_url, :is_repin, :is_video, :source, :link, :description, :user_name
  attr_accessible :field_id, :user_id, :board_id, :img_url, :is_repin, :is_video, :source, :link, :description, :user_name


  def to_json
    {
      field_id: field_id,
      user_id: user_id,
      user_name: user_name,
      board_id: board_id,
      img_url: img_url,
      is_repin: is_repin,
      is_video: is_video,
      source: source,
      link: link,
      description: description,
    }
  end

  #TODO
  def self.json_create(o)
  end
end 
