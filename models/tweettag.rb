require 'sinatra/activerecord'

class Tweettag < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :tweettag
end