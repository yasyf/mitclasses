require 'sidekiq'

CONNECTION_LIMIT = Rails.env.development? ? 50 : 20

Sidekiq.configure_client do |config|
  config.redis = { size: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { size: CONNECTION_LIMIT - (ENV['WEB_CONCURRENCY'].to_i * ENV['MAX_THREADS'].to_i) }
end
