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
          if redis.exists(redis_key)
              redis.sadd(redis_key, tweet.to_json)
          end

        end


      end

    end
  end

  end
