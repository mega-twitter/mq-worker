require "bunny"
require 'json'
require_relative 'helper/test_helper.rb'
require './models/tweet.rb'

class MQ
  def initialize(redis)
    @conn = Bunny.new(host:  '142.93.71.173',
                     port:  '5672',
                     vhost: '/',
                     ssl: false,
                     user:  'admin',
                     pass:  'admin')

    @conn.start
    @channel = @conn.create_channel
    @queue = @channel.queue("test")
    @redis = redis
    self.receive
  end


  def receive
    puts " [*] Waiting for messages in #{@queue.name}. To exit press CTRL+C"
    @queue.subscribe(block: true) do |delivery_info, properties, body|
      content =  JSON.parse(body)
      if content["tweet_content"].nil?
         TestHelper.generate_tweet(content["user_id"].to_i, content["tweet_cnt"].to_i, @redis)
      else
        tweet = Tweet.new(user_id: content["user_id"].to_i, content: content["tweet_content"])
        if tweet.save
          redis_key = content["user_id"] + "-1"
          if redis.exists(redis_key)
              redis.lpush(redis_key, tweet.to_json)
              redis.rpop(redis_key) if redis.llen(redis) > 10

          end

        end


      end

    end
  end

  end
