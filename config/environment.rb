# Load the Rails application.
require File.expand_path('../application', __FILE__)

ENV['WEB_CONCURRENCY'] ||= "2"
ENV['MAX_THREADS'] ||= "5"

# Initialize the Rails application.
Rails.application.initialize!
