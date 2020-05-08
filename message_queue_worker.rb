require "bunny"
require 'json'
require_relative 'helper/test_helper.rb'
require './models/tweet.rb'

class MQ
  def initialize(redis)
    @conn = Bunny.new(host:  '134.122.5.100',
                     port:  '5672',
                     vhost: '/',
                     ssl: false,
                     user:  'admin',
                     pass:  'admin')

    @conn.start
    @channel = @conn.create_channel
    @queue = @channel.queue("tweet")
    @redis = redis
    self.receive
  end


  def receive
    puts " [*] Waiting for messages in #{@queue.name}. To exit press CTRL+C"
    @queue.subscribe(block: true) do |delivery_info, properties, body|
      content =  JSON.parse(body)
      if content["tweet_content"].nil?
         TestHelper.generate_tweet(content["user_id"].to_i, content["tweet_cnt"].to_i)
      else
        tweet = Tweet.new(user_id: content["user_id"].to_i, content: content["tweet_content"])

        if tweet.save

          redis_key = content["user_id"] + "-1"
          tweet = ActiveRecord::Base.connection.execute(
              "select tweets.content, tweets.created_at, tweets.user_id, users.name
  from tweets inner join users on tweets.user_id = users.id
  where tweets.id=#{tweet.id}"
          )[0]
          tweet["created_at"] = tweet["created_at"].to_s


          if redis.exists(redis_key)
              redis.sadd(redis_key, tweet.to_json)
          end


          follower_ids = ActiveRecord::Base.connection.execute(
              "select follows.follower_id from follows where followed_id=#{tweet["user_id"]}").map{|x| x["follower_id"]}

          follower_ids.each  do |id|
            follower_redis_key = id.to_s + "-1"
            if redis.exists(follower_redis_key)
              redis.sadd(follower_redis_key, tweet.to_json)
            end
          end

        end


      end

    end
  end

  end
