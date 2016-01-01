module Concerns
  module ReactJson
    extend ActiveSupport::Concern

    def as_json(options = {})
      options[:react] ? react_json.reverse_merge(key: id, id: id) : super
    end

    private

    def react_json
      {}
    end
  end
end
