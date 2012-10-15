require 'debugger'
Dir.glob('./models/*').each { |file| require_relative file }

class DataAnalyzer

  def load_data
    load_pins
    load_boards
  end
  
  def load_pins
    pins = JSON.parse(File.read('pins.json'))
    pins.each do  |pin|
      pin["field_id"] = pin["field_id"].to_i
      pin["board_id"] = pin["board_id"].to_i
    end
    Pin.create!(pins)
  end

  def load_boards
    boards = JSON.parse(File.read('boards.json'))
    boards.each do |board|
      board["field_id"] = board["field_id"].to_i
    end
    Board.create!(boards)
  end
end

da = DataAnalyzer.new
da.load_data
