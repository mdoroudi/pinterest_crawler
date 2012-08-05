require 'active_record'
require 'rubygems'
require 'yaml'
#require 'schema'
require 'nokogiri'
require 'open-uri'
require 'debugger'
class BoardCrawler 

  def initialize(seed = nil)
    if !seed.nil?
      @seed = seed
    end
  end

  # The seed is a users user name
  def crawl_from_seed
    puts "begining to crawl!"
    doc = Nokogiri::HTML(open(url(@seed)))
    users_boards = doc.css("#wrapper.BoardLayout li")
    users_boards.each do |board|
      get_board_info(board)
    end
  end

  def crawl_from_main_page

  end

  def get_board_info(board)
    debugger
    puts "boar!d"
  end
  
  def url(username)
    "http://pinterest.com/#{username}"
  end

end

if ARGV.size == 0
else
  puts "crawling the boards for #{ARGV[0]}"
  crawler = BoardCrawler.new(ARGV[0])
  crawler.crawl_from_seed
end
