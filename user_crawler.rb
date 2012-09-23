require_relative 'crawler'

class UserCrawler < PinterestCrawler

  def initialize(params = {seed: nil, append_to_file: true})
    params[:append_to_file] = true if params[:append_to_file].nil?

    super params
    @users = []
    @users_slug = []
    @users_file = File.new("users.json", file_mode)
  end

  # The seed is a users user name
  def crawl_users_from_seed(seed = @current_user_slug)
    seed_user = User.new(user_name: seed)
    @users << seed_user
    
    following_html = users_following_page(seed)
    followers_html = users_followers_page(seed)
    
    seed_user.user_id = Zlib.crc32 seed
    seed_user.about = followers_html.css(".content p").text 


    following_html.css(".person").each do |person_html|
      user_name = person_html.css(".PersonImage").attr("href").value 
      seed_user.following << Zlib.crc32(user_name)
      @users_slug << user_name
    end

    followers_html.css(".person").each do |person_html|
      user_name = person_html.css(".PersonImage").attr("href").value 
      seed_user.followers << Zlib.crc32(user_name)
      @users_slug << user_name
    end
  end

  protected
  
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
