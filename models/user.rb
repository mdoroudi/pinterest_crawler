require_relative '../database_configuration'

class User < ActiveRecord::Base
  attr_accessor :user_id, :user_name, :about, :followers, :following
  has_many :pins
  has_many :boards

  has_many :followers, through: relationships, foreign_key: "follower_id"
  has_many :followees, through: relationships, foreign_key: "followee_id"

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
