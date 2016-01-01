module Concerns
  module FeatureVectors
    extend ActiveSupport::Concern

    included do
      after_commit :update_feature_vectors, on: [:create, :update]
    end

    private

    def update_feature_vectors
      FeatureVectorWorker.perform_async(self.class.name, id)
    end

    def update_feature_vectors!
      assign_attributes feature_vectors: generate_feature_vectors
      save! if changed?
    end
  end
end
