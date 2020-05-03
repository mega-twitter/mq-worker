require 'sinatra/activerecord'
require './models/es/searchable.rb'

class Tweet < ActiveRecord::Base
# include Searchable

  belongs_to :user, primary_key: :id, foreign_key: :user_id
  validates :user_id, presence: true
  default_scope -> { order(created_at: :desc) }

  has_many :tweettags
  has_many :tags, through: :tweettags


end