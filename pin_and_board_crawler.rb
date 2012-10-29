require_relative 'crawler'

class PinAndBoardCrawler < PinterestCrawler

  def initialize(params = {seed: nil, append_to_file: true})
    params[:append_to_file] = true if params[:append_to_file].nil?
    super params
    @boards = []
    @pins = []
    @boards_file = File.new("boards.json", file_mode)
    @pins_file = File.new("pins.json", file_mode)
    @deep = false
  end

  # for current user slug get all her pins and boards
  def crawl_from_seed
    users_page =  users_page(@current_user_slug)
    sleep rand(1.0..2.0)
    users_boards = users_page.css("#wrapper.BoardLayout li")
    users_boards.each do |board_thumb_html|
      get_board_and_pins(board_thumb_html)
    end
    save_to_files unless @deep
  end

  # from the main page if
  # deep is true, get all the boards of the pins in the main page and crawl both boards and pis
  # deep is false, just crawl the 50 pins on the main page
  def crawl_from_main_page(deep = false)
    @deep = deep
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


  protected

  # helper method for crawling from users seed
  # input: html for the board thumbnail on users profile
  def get_board_and_pins(board_thumb_html)
    @boards << get_board_info(board_thumb_html)
    get_pins_info(@users_pin_board.css(".pin"), {board_id: @boards.last.field_id.to_i, slug: @boards.last.slug})
  end 
  
  # for both pins and boards data, save them to file as json
  def save_to_files
    @boards.collect! { |board| board.to_json } 
    @pins.collect! { |pin| pin.to_json } 

    @boards = JSON.generate(@boards)
    @pins = JSON.generate(@pins)

    @boards_file.puts @boards unless @boards.empty?
    @pins_file.puts @pins unless @pins.empty?
  end 

  # pins info from the main page
  def get_pin_info_only_from_main(pin_html, index)
    pin = Pin.new
    @current_user_slug = pin_html.css(".convo a").attr("href").value.split("/")[1] 
    puts "Crawling #{index}th pin of the main page. User: #{@current_user_slug}"

    pin = get_common_pin_info(pin_html, pin)
    @pins << pin
  end

  # pins info from users boards
  def get_pin_info_from_board(pin_html, index, args)
    pin = Pin.new
    puts "Crawling #{index}th pin of board #{@current_user_slug}/#{args[:slug]}" if args[:slug]

    source_of = pin_html.css(".convo.attribution .NoImage a")
    pin = get_common_pin_info(pin_html, pin)
    pin.board_id = args[:board_id].to_i if args[:board_id]
    pin.source = source_of.empty? ? "User Uplaod" : source_of.attr("href").value
    @pins << pin
  end

  # extracting data from the common UI and CSS between pins on the main page and on each board
  def get_common_pin_info(pin_html, pin)
    pin.user_name = @current_user_slug
    pin.user_id = unique_id @current_user_slug
    pin.field_id = pin_html.attr("data-id") 
    pin.description = pin_html.css(".description").text 
    pin.link = pin_html.css(".PinImage.ImgLink").attr("href").value 
    pin.img_url = pin_html.css(".PinImage.ImgLink img").attr("src").value 
    pin
  end

  # helper method for given a board thumbnail, extract the board info and return a Board instance
  def get_board_info(board_thumb_html)
    board_thumb_html = board_thumb_html.css(".pinBoard").first
    board = Board.new
        
    board.user_name   = @current_user_slug 
    board.user_id     = unique_id @current_user_slug
    board.field_id    = board_thumb_html["id"].gsub("board","").try(:to_i)
    board.slug        = board_thumb_html.css("h3 a").first["href"].gsub( @current_user_slug, "").gsub("\/","")
    board.name        = board_thumb_html.css("h3 a").first.text
    @users_pin_board  = get_page_html(users_url+board.slug)
    board.description = @users_pin_board.css("#BoardDescription").text
    board.category    = @users_pin_board.css('meta[property="pinterestapp:category"]').attr("content").value

    board
  end 

  # helper method for given all the pin_htmls
  # if it's crawling from main page and it needs to get the baords (deep)
  #   set the pin owner to the curret_user
  #   see if the current_user has not been crawled through the main page get all her boads and pins
  # if it's crawling from main page and it needs to get the pins only (not deep)
  #   call the method that only extract the pins
  # else it's crawling from seed so just do the right thing 
  def get_pins_info(pins_html, args = {})
    default_args = {
      board_id: nil, 
      slug: nil, 
      crawling_from_main_page: "none",
    }
    visited_users = {}
    args = default_args.merge(args)
    pins_html.each_with_index do |pin_html, index|
      begin
        if args[:crawling_from_main_page] == "boards"
          @current_user_slug = pin_html.css(".convo a").attr("href").value.split("/")[1] 
          if visited_users[unique_id(@current_user_slug)].nil?
             visited_users[unique_id(@current_user_slug)] = true
            crawl_from_seed
          end
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

end
