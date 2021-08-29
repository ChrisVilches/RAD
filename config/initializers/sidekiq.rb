# By default, Sidekiq tries to connect to Redis at localhost:6379.
# This typically works great during development but needs tuning in production.
# https://github.com/mperham/sidekiq/wiki/Using-Redis

# Sidekiq.configure_server do |config|
#   config.redis = { url: 'redis://redis.example.com:7372/0' }
# end

# Sidekiq.configure_client do |config|
#   config.redis = { url: 'redis://redis.example.com:7372/0' }
# end
