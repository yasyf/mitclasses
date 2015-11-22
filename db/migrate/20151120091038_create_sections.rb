class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :number, null: false, unique: true
      t.integer :size
      t.belongs_to :mit_class, index: true, foreign_key: true, null: false
      t.belongs_to :location, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
