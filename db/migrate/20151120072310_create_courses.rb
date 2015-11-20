class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.text :number, null: false, unique: true

      t.timestamps null: false
    end
  end
end
