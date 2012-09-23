require_relative 'crawler'

class PinAndBoardCrawler < PinterestCrawler

  def initialize(params = {seed: nil, append_to_file: true})
    params[:append_to_file] = true if params[:append_to_file].nil?
    super params
    @boards = []
    @pins = []
    @boards_file = File.new("boards.json", file_mode)
    @pins_file = File.new("pins.json", file_mode)
  end

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

  protected
  
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


end
