class FeatureVectorWorker
  include Sidekiq::Worker

  def perform(class_name, id)
    class_name.constantize.find(id).send(:update_feature_vectors!)
  end
end
