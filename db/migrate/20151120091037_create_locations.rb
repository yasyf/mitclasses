class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :number, null: false, unique: true

      t.timestamps null: false
    end
  end
end
