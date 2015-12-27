module Concerns
  module Cacheable
    extend ActiveSupport::Concern

    def cached(options = {}, &block)
      key = "#{cache_key}/#{caller_locations(1,1).first.label}"
      Rails.cache.fetch(key, options, &block)
    end
  end
end
