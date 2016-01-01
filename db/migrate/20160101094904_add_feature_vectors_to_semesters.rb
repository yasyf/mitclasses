class AddFeatureVectorsToSemesters < ActiveRecord::Migration
  def change
    add_column :semesters, :feature_vectors, :json, null: false, default: []
  end
end
