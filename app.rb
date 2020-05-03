# nano twitter
require 'sinatra'
require 'sinatra/activerecord'
require 'redis'
require_relative 'helper/test_helper.rb'
require_relative 'message_queue_worker'
require 'json'

set :redis, Redis.new()
$mq = MQ.new(settings.redis)

get "/" do
  status 200
end