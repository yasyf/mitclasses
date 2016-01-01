module Concerns
  module Cacheable
    extend ActiveSupport::Concern

    private

    def cached(options = {}, &block)
      key = "#{cache_key}/#{caller_locations(1,1).first.label}"
      Rails.cache.fetch(key, options, &block)
    end

    def key_cached(key_hash, options = {}, &block)
      hashed = Digest::MD5.base64digest key_hash.to_param
      key = "#{cache_key}/#{caller_locations(1,1).first.label}/#{hashed}"
      Rails.cache.fetch(key, options, &block)
    end
  end
end
