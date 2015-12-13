class CreateMitClasses < ActiveRecord::Migration
  def change
    create_table :mit_classes do |t|
      t.string :name
      t.string :number, null: false
      t.text :description
      t.string :short_name
      t.belongs_to :semester, index: true, foreign_key: true, null: false
      t.belongs_to :course, index: true, foreign_key: true, null: false
      t.belongs_to :instructor, index: true, foreign_key: true
      t.json :prereqs
      t.json :coreqs
      t.string :units, array: true
      t.string :hass
      t.string :ci

      t.index [:number, :semester_id], unique: true

      t.timestamps null: false
    end
  end
end
