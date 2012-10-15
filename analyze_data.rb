require 'debugger'
Dir.glob('./models/*').each { |file| require_relative file }

class DataAnalyzer

  def load_data
    load_pins
    load_boards
  end
  
  def load_pins
    pins = JSON.parse(File.read('pins.json'))
    debugger
    puts "mina"

  end

  def load_boards
    boards = JSON.parse(File.read('boards.json'))
  end
end

da = DataAnalyzer.new
da.load_pins
