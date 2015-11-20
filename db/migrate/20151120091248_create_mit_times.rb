class CreateMitTimes < ActiveRecord::Migration
  def change
    create_table :mit_times do |t|
      t.integer :day, null: false
      t.time :start, null: false
      t.time :finish, null: false

      t.index [:day, :start, :finish], unique: true

      t.timestamps null: false
    end
  end
end
