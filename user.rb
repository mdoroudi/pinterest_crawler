class User
  attr_accessor :user_id, :user_name, :about, :followers, :following

  def initialize(params={})
    @user_name = params[:user_name]
    @user_id   = params[:user_id]
    @followers = params[:followers] || []
    @following = params[:following] || []
  end

  def to_json
    {
      user_id: user_id,
      user_name: user_name,
      about: about,
      following: following,
      followers: followers
    }
  end
end
