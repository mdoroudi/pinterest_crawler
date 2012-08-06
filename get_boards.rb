#require 'active_record'
#require 'rubygems'
require 'yaml'
#require 'schema'
require 'nokogiri'
require 'open-uri'
require 'debugger'
require 'zlib'
require_relative 'board'
#$LOAD_PATH << '.'

class BoardsCrawler 

  def initialize(seed = nil)
    @header_hash = { "User-Agent" => 
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11"}

    if !seed.nil?
      @current_user_slug = seed
    end
  end

  # The seed is a users user name
  def crawl_from_seed
    puts "begining to crawl!"
    users_page = Nokogiri::HTML(open(users_url, @header_hash))
    users_boards = users_page.css("#wrapper.BoardLayout li")
    users_boards.each do |board_thumb_html|
      board = get_board_info(board_thumb_html)
      sleep rand (1.0..3.0)
    end
  end

  def crawl_from_main_page
     @current_user_slug = "?"
  end

  def get_board_info(board_thumb_html)
    board_thumb_html = board_thumb_html.css(".pinBoard").first
    board = Board.new
    
    board.user_name   = @current_user_slug
    board.user_id     = Zlib.crc32 @current_user_slug
    board.field_id    = board_thumb_html["id"].gsub("board","")
    board.slug        = board_thumb_html.css("h3 a").first["href"].gsub( @current_user_slug, "").gsub("\/","")
    board.category    = board_thumb_html.css("h3 a").first.text
    users_pin_board   = Nokogiri::HTML(open(users_url+board.slug, @header_hash ))
    board.description = users_pin_board.css("#BoardDescription").text()
  
    board
  end

  def users_url 
     url(@current_user_slug)
  end
  
  def url(username)
    "http://pinterest.com/#{username}/"
  end

end

# run with
# ruby get_boards.rb mdoroudi

if ARGV.size == 0
  puts "crawling and finding users from the homepage"
  crawler = BoardsCrawler.new
  crawler.crawl_from_main_page
else
  puts "crawling the boards for #{ARGV[0]}"
  crawler = BoardsCrawler.new(ARGV[0])
  crawler.crawl_from_seed
end
