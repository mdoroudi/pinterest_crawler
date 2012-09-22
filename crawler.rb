require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'debugger'
require 'zlib'
require 'json'
require 'colorize'
require_relative 'board'
require_relative 'pin'
require_relative 'user'
#$LOAD_PATH << '.'

class PinterestCrawler 

  def initialize(seed = nil)
    @boards = []
    @pins = []

    file_mode = @@append_to_file ? 'a' : 'w'
    @boards_file = File.new("boards.json", file_mode)
    @pins_file = File.new("pins.json", file_mode)
    @users_file = File.new("users.json", file_mode)

    unless seed.nil?
      @current_user_slug = seed
    end
  end

  # The seed is a users user name
  def crawl_from_seed
    users_page =  users_page(@current_user_slug)
    sleep rand(1.0..2.0)
    users_boards = users_page.css("#wrapper.BoardLayout li")
    users_boards.each do |board_thumb_html|
      get_board_and_pins(board_thumb_html)
    end
    save_to_files
  end

  def crawl_from_main_page(deep = false)
     @current_user_slug = nil 
     home_page = get_page_html("http://pinterest.com/") 
     pins = home_page.css("#wrapper #ColumnContainer .pin")
     if deep
       get_pins_info(pins, {crawling_from_main_page: 'boards'})
     else
       get_pins_info(pins, {crawling_from_main_page: 'pins'})
     end
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
    @users_pin_board  = get_page_html(users_url+board.slug)
    board.description = @users_pin_board.css("#BoardDescription").text
    board.category    = @users_pin_board.css('meta[property="pinterestapp:category"]').attr("content").value

    board
  end 

  def get_pins_info(pins_html, args = {})
    default_args = {
      board_id: nil, 
      slug: nil, 
      crawling_from_main_page: "none",
    }
    args = default_args.merge(args)
    pins_html.each_with_index do |pin_html, index|
      begin
        if args[:crawling_from_main_page] == "boards"
          @current_user_slug = pin_html.css(".convo a").attr("href").value.split("/")[1] 
          crawl_from_seed
        elsif args[:crawling_from_main_page] == "pins"
          get_pin_info_only_from_main(pin_html, index)
        else
          get_pin_info_from_board(pin_html, index, args)
        end
      rescue Exception => e
        puts e
        puts "There was a problem with the current pin:".red
        puts "#{pin_html}"
        next
      end
    end
    @pins
  end

  def crawl_users_from_seed(seed = @current_user_slug)
    @users = []
    seed_user = User.new(user_name: seed)
    @users << seed_user
    
    following_html = users_following_page(@current_user_slug)
    followers_html = users_followers_page(@current_user_slug)
    
    seed_user.user_id = Zlib.crc32 @current_user_slug
    seed_user.about = followers_html.css(".content p").text 


    following_html.css(".person").each do |person_html|
      user_name = person_html.css(".PersonImage").attr("href").value 
      seed_user.following << Zlib.crc32(user_name)
    end

    followers_html.css(".person").each do |person_html|
      user_name = person_html.css(".PersonImage").attr("href").value 
      seed_user.followers << Zlib.crc32(user_name)
    end
    debugger
    puts "donezo"

  end

  protected

  def crawl_curr_user(user)
    user.user_id = Zlib.crc32 user.user_name
    
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

    @boards = []
    @pins = []
  end 

  def get_pin_info_only_from_main(pin_html, index)
    pin = Pin.new
    @current_user_slug = pin_html.css(".convo a").attr("href").value.split("/")[1] 
    puts "Crawling #{index}th pin of the main page. User: #{@current_user_slug}"

    pin = get_common_pin_info(pin_html, pin)
    @pins << pin
  end

  def get_pin_info_from_board(pin_html, index, args)
    pin = Pin.new
    puts "Crawling #{index}th pin of board #{@current_user_slug}/#{args[:slug]}" if args[:slug]

    source_of = pin_html.css(".convo.attribution .NoImage a")
    pin = get_common_pin_info(pin_html, pin)
    pin.board_id = args[:board_id] if args[:board_id]
    pin.source = source_of.empty? ? "User Uplaod" : source_of.attr("href").value
    @pins << pin
  end

  def get_common_pin_info(pin_html, pin)
    pin.user_name = @current_user_slug
    pin.user_id = Zlib.crc32 @current_user_slug
    pin.field_id = pin_html.attr("data-id") 
    pin.description = pin_html.css(".description").text 
    pin.link = pin_html.css(".PinImage.ImgLink").attr("href").value 
    pin.img_url = pin_html.css(".PinImage.ImgLink img").attr("src").value 
    pin
  end

  def users_page(slug)
    get_page_html(url(slug))
  end

  def users_following_page(slug)
    get_page_html("#{url(slug)}following")
  end

  def users_followers_page(slug)
    get_page_html("#{url(slug)}followers")
  end

  def get_page_html(url)
    header_hash = { "User-Agent" => 
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11"}
    Nokogiri::HTML(open(url, header_hash)) 
  end

end

# run with
# ruby get_boards.rb user-name 
if ARGV.include?('-a')
  @@append_to_file = true
  ARGV.delete('-a')
else
  @@append_to_file = false
end

if ARGV.size == 0
  puts "crawling and finding pin from the homepage"
  crawler = PinterestCrawler.new
  crawler.crawl_from_main_page
elsif ARGV.size == 1
  if ARGV[0] == "-d"
    puts "crawling deep and finding pins and boards from the homepage"
    crawler = PinterestCrawler.new
    crawler.crawl_from_main_page(true)
  else
    puts "crawling the boards for #{ARGV[0]}"
    crawler = PinterestCrawler.new(ARGV[0])
    crawler.crawl_from_seed
  end
elsif ARGV.size == 2
  if ARGV[0] == "-u"
    puts "crawling user #{ARGV[1]} and all its follwer and following"
    crawler = PinterestCrawler.new(ARGV[1])
    crawler.crawl_users_from_seed(ARGV[1])
  end
else
  puts "Wrong arguments, try one of the followings:".red
  puts "Crawl a specific user:".blue
  puts "\truby get_boards.rb [username]"
  puts "Crawl only the main page pins (50):".blue
  puts "\truby get_boards.rb"
  puts "Crawl (deep) all the users boards and pins from the main page:".blue
  puts "\truby get_boards.rb -d"
  puts "Use -a at anytime to append the results to the end of the previews result".blue
end
