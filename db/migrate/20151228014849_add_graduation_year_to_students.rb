class AddGraduationYearToStudents < ActiveRecord::Migration
  def change
    change_table :students do |t|
      t.integer :graduation_year
      t.string :name
      t.belongs_to :course, index: true, foreign_key: true, null: true
    end
  end
end
