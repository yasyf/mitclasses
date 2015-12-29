class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.belongs_to :schedule, index: true, foreign_key: true
      t.belongs_to :mit_class, index: true, foreign_key: true
      t.boolean :positive, null: false

      t.index [:schedule_id, :mit_class_id], unique: true

      t.timestamps null: false
    end
  end
end
