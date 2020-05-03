require 'sinatra/activerecord'

class Tag < ActiveRecord::Base
  has_many :tweettags
  has_many :tweets, through: :tweettags
  validates :hashtag, uniqueness: true
end