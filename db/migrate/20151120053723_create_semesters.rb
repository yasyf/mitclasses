class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.integer :year, null: false
      t.integer :season, null: false

      t.timestamps null: false

      t.index [:season, :year], unique: true
    end
  end
end
