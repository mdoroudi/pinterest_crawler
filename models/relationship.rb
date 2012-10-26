require_relative '../database_configuration'

class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: 'Users'
  belongs_to :followee, class_name: 'Users'

  validates :follower_id, presence: true
  validates :followee_id, presence: true
end
