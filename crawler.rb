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
  attr_accessor :append_to_file

  def initialize(params = {seed: nil, append_to_file: true})
    append_to_file = params[:append_to_file].nil? ? true :  params[:append_to_file]

    unless params[:seed].nil?
      @current_user_slug = params[:seed]
    end
  end

  def file_mode
    append_to_file ? 'a' : 'w'
  end

  def append_to_file
    @append_to_file ||= true
  end

  def self.instruction
    puts "Wrong arguments, try one of the followings:".red
    puts "Crawl a specific user:".blue
    puts "\truby get_boards.rb [username]"
    puts "Crawl only the main page pins (50):".blue
    puts "\truby get_boards.rb"
    puts "Crawl (deep) all the users boards and pins from the main page:".blue
    puts "\truby get_boards.rb -d"
    puts "Use -a at anytime to append the results to the end of the previews result".blue
  end


  protected

  def users_url 
     url(@current_user_slug)
  end
  
  def url(username)
    "http://pinterest.com/#{username}/"
  end


  def users_page(slug)
    get_page_html(url(slug))
  end

  def get_page_html(url)
    sleep rand(1.0..2.0)
    header_hash = { "User-Agent" => 
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11"}
    Nokogiri::HTML(open(url, header_hash)) 
  end

end

# run with
# ruby get_boards.rb user-name 

#if ARGV.include?('-a')
  #append = true
  #ARGV.delete('-a')
#else
  #append = false
#end

#if ARGV.size == 0
  #puts "crawling and finding pin from the homepage"
  #crawler = PinterestCrawler.new({append_to_file: append})
  #crawler.crawl_from_main_page
#elsif ARGV.size == 1
  #if ARGV[0] == "-d"
    #puts "crawling deep and finding pins and boards from the homepage"
    #crawler = PinterestCrawler.new({append_to_file: append})
    #crawler.crawl_from_main_page(true)
  #else
    #puts "crawling the boards for #{ARGV[0]}"
    #crawler = PinterestCrawler.new({append_to_file: append, seed: ARGV[0]})
    #crawler.crawl_from_seed
  #end
#elsif ARGV.size == 2
  #if ARGV[0] == "-u"
    #puts "crawling user #{ARGV[1]} and all its follwer and following"
    #crawler = PinterestCrawler.new({append_to_file: append, seed: RGV[1]})
    #crawler.crawl_users_from_seed(ARGV[1])
  #end
#else
  #PinterestCrawler.instruction
#end
