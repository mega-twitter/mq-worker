workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['THREAD_COUNT'] || 1)
threads threads_count, threads_count

rackup      DefaultRackup
port        ENV['PORT']     || 3003
environment ENV['RACK_ENV'] || 'development'