module Concerns
  module SafeJson
    extend ActiveSupport::Concern

    def as_json(options = {})
      ignored = %w(id created_at updated_at)
      ignored += self.class.column_names.select { |c| c.last(3) == '_id' }
      super options.reverse_merge(except: ignored)
    end
  end
end
