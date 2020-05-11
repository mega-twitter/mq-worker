# nano twitter
require 'sinatra'
require 'sinatra/activerecord'
require 'redis'
require_relative 'helper/test_helper.rb'
require_relative 'message_queue_worker'
require 'json'

set :redis, Redis.new(host: "157.245.114.60", port: 6379, password: "foo")

$mq = MQ.new(settings.redis)

get "/" do
  status 200
end