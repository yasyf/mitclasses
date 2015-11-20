class CreateMitClasses < ActiveRecord::Migration
  def change
    create_table :mit_classes do |t|
      t.string :name
      t.string :number, unique: true, null: false
      t.text :description
      t.string :short_name
      t.belongs_to :semester, null: false
      t.belongs_to :course, null: false
      t.belongs_to :instructor
      t.string :prereqs, array: true, default: []
      t.string :coreqs, array: true, default: []
      t.string :units, array: true
      t.string :hass
      t.string :ci

      t.timestamps null: false
    end
  end
end
