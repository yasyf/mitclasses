class CreateMitClassesSchedules < ActiveRecord::Migration
  def change
    create_table :mit_classes_schedules do |t|
      t.integer :mit_class_id
      t.integer :schedule_id
    end
  end
end
