class AddFeatureVectorsToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :feature_vectors, :json, null: false, default: []
  end
end
