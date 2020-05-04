require 'json'
require './models/tweet.rb'
require 'activerecord-import'
require 'activerecord-import/active_record/adapters/postgresql_adapter'
require 'faker'
require 'random/password'
include RandomPassword


module TestHelper
  # create tweets randomly for given user
  def self. generate_tweet(id, count, redis)
    tweet_bulk = []
    current_tweet_count = 0

    until current_tweet_count >= count do
      tweet_bulk << Tweet.new(user_id: id, content: Faker::Quote.yoda)
      current_tweet_count = current_tweet_count + 1
    end
    Tweet.import tweet_bulk, batch_size: 50, on_duplicate_key_ignore: true

    redis_key = id.to_s + "-1"

    if redis.exists(redis_key)
      tweet_bulk.each  do |tweet|
        redis.lpush(redis_key, tweet.to_json)
        redis.rpop(redis_key) if redis.llen(redis) > 10

      end
    end
  end


end