require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'debugger'
require 'zlib'
require 'json'
require_relative 'board'
require_relative 'pin'
#$LOAD_PATH << '.'

class BoardsCrawler 

  def initialize(seed = nil)
    @header_hash = { "User-Agent" => 
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11"}
    @boards = []
    @pins = []

    @boards_file = File.new("boards.json", "w+")
    @pins_file = File.new("pins.json", "w+")

    if !seed.nil?
      @current_user_slug = seed
    end
  end

  # The seed is a users user name
  def crawl_from_seed
    users_page = Nokogiri::HTML(open(users_url, @header_hash))
    users_boards = users_page.css("#wrapper.BoardLayout li")
    users_boards.each do |board_thumb_html|
      get_board_and_pins(board_thumb_html)
      sleep rand (1.0..3.0)
    end
    save_to_files
  end

  def crawl_from_main_page
     @current_user_slug = nil 
     home_page = Nokogiri::HTML(open("http://pinterest.com/", @header_hash))
     pins = home_page.css("#wrapper #ColumnContainer .pin")
     get_pins_info(pins, {crawl_pin_boards: true})
     save_to_files
  end


  def get_board_and_pins(board_thumb_html)
    @boards << get_board_info(board_thumb_html)
    get_pins_info(@users_pin_board.css(".pin"), {board_id: @boards.last.field_id, slug: @boards.last.slug})
  end 

  def get_board_info(board_thumb_html)
    board_thumb_html = board_thumb_html.css(".pinBoard").first
    board = Board.new
        
    board.user_name   = @current_user_slug 
    board.user_id     = Zlib.crc32 @current_user_slug
    board.field_id    = board_thumb_html["id"].gsub("board","")
    board.slug        = board_thumb_html.css("h3 a").first["href"].gsub( @current_user_slug, "").gsub("\/","")
    board.name        = board_thumb_html.css("h3 a").first.text
    sleep rand(1.0..2.0)
    @users_pin_board  = Nokogiri::HTML(open(users_url+board.slug, @header_hash ))
    board.description = @users_pin_board.css("#BoardDescription").text
    board.category    = @users_pin_board.css('meta[property="pinterestapp:category"]').attr("content").value

    board
  end 

  def get_pins_info(pins_html, args = {})
    default_args = {board_id: nil, slug: nil, crawl_pin_boards: false}
    args = default_args.merge(args)

    begin
      pins_html.each_with_index do |pin_html, index|
        pin = Pin.new
        @current_user_slug = pin_html.css(".convo a").attr("href").value.split("/")[1] 
        break if @current_user_slug.empty?
        
        if args[:crawl_pin_boards]
          sleep rand(1.0..2.0)
          crawl_from_seed
        else
          puts "Crawling #{index}th pin of board #{@current_user_slug}/#{args[:slug]}" if args[:slug]
          source_of = pin_html.css(".convo.attribution .NoImage a")

          pin.user_name = @current_user_slug
          pin.user_id = Zlib.crc32 @current_user_slug
          pin.board_id = args[:board_id] if args[:board_id]
          pin.field_id = pin_html.attr("data-id") 
          pin.description = pin_html.css(".description").text 
          pin.source = source_of.empty? ? "User Uplaod" : source_of.attr("href").value
          pin.link = pin_html.css(".PinImage.ImgLink").attr("href").value 
          pin.img_url = pin_html.css(".PinImage.ImgLink img").attr("src").value 
          @pins << pin
        end

        @pins
      end
    rescue Exception => e
      puts e
      puts "pin_html has a problem"
    end
  end

  def users_url 
     url(@current_user_slug)
  end
  
  def url(username)
    "http://pinterest.com/#{username}/"
  end

  def save_to_files
    @boards.collect! { |board| board.to_json } 
    @pins.collect! { |pin| pin.to_json } 

    @boards_file.puts @boards unless @boards.empty?
    @pins_file.puts @pins unless @pins.empty?
  end 

end

# run with
# ruby get_boards.rb user-name 

if ARGV.size == 0
  puts "crawling and finding users from the homepage"
  crawler = BoardsCrawler.new
  crawler.crawl_from_main_page
else
  puts "crawling the boards for #{ARGV[0]}"
  crawler = BoardsCrawler.new(ARGV[0])
  crawler.crawl_from_seed
end
