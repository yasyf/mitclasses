class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.belongs_to :mit_class, index: true, foreign_key: true, null: false

      t.float :assigments_useful
      t.float :expectations_clear
      t.float :grading_fair
      t.float :learning_objectives_met
      t.float :classroom_hours
      t.float :home_hours
      t.float :rating, null: false
      t.float :pace
      t.float :percent_response, null: false

      t.timestamps null: false
    end
  end
end
