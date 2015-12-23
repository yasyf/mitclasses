class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.belongs_to :student, index: true, foreign_key: true, null: true

      t.timestamps null: false
    end
  end
end
