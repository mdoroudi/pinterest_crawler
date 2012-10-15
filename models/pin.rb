require_relative '../database_configuration'

class Pin < ActiveRecord::Base 

  attr_accessor :field_id, :user_id, :board_id, :img_url, :is_repin, :is_video, :source, :link, :description, :user_name

  validates_presence_of :field_id, :user_id, :board_id

  def to_json
    {
      field_id: field_id,
      user_id: user_id,
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
