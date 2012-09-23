require_relative 'crawler'
require 'debugger'

class UserCrawler < PinterestCrawler

  def initialize(params = {seed: nil, append_to_file: true})
    params[:append_to_file] = true if params[:append_to_file].nil?

    super params
    @users       = []
    @users_slugs = params[:seed].nil? ? [] : [params[:seed]]
    @crawled_users_ids = [] 
    @users_file  = File.new("users.json", file_mode)
    @total_users_crawled = 0
    @crawling_limit = 500
  end

  def crawl_users_from_seed(seed = @current_user_slug)
    while @users_slugs.size > 0 && @total_users_crawled < @crawling_limit
      begin
        crawl_current_user(@users_slugs[0])
        @users_slugs.delete_at(0)
        save_to_file
      rescue Exception => e
        puts e
        puts "There was a problem with the current user: #{@users_slugs[0]}".red
        @users_slugs.delete_at(0)
        next
      end
    end
  end

  def crawl_current_user(seed = @current_user_slug)
    return if have_been_crawled?(seed) 
    puts "Crawling user #{seed} ..."

    seed_user = User.new(user_name: seed)
    @users << seed_user
    @total_users_crawled += 1
    
    following_html = users_following_page(seed)
    followers_html = users_followers_page(seed)
    
    seed_user.user_id = Zlib.crc32 seed
    seed_user.about = followers_html.css(".content p").text 


    following_html.css(".person").each do |person_html|
      user_name = person_html.css(".PersonImage").attr("href").value.split("/")[1] 
      seed_user.following << Zlib.crc32(user_name)
      @users_slugs << user_name
    end

    followers_html.css(".person").each do |person_html|
      user_name = person_html.css(".PersonImage").attr("href").value.split("/")[1] 
      seed_user.followers << Zlib.crc32(user_name)
      @users_slugs << user_name
    end
    @crawled_users_ids << seed_user.user_id
  end

  protected
  
  def have_been_crawled?(user_slug)
    id = Zlib.crc32 user_slug
    @crawled_users_ids.find_index(id).nil? ? false : true
  end

  def save_to_file
    @users.collect! {|user| user.to_json}
    @users_file.puts @users unless @users.empty?
    @users = []
  end

  def users_following_page(slug)
    get_page_html("#{url(slug)}following")
  end

  def users_followers_page(slug)
    get_page_html("#{url(slug)}followers")
  end
end
