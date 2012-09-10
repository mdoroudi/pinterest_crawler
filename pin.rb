class Pin 

  attr_accessor :field_id, :user_id, :board_id, :img_url, :is_repin, :is_video, :source, :link, :description, :user_name

  def initialize
  end
  
  def to_json
    {
      filed_id: field_id,
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
