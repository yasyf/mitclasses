class CreateTextbooks < ActiveRecord::Migration
  def change
    create_table :textbooks do |t|
      t.belongs_to :mit_class, index: true, foreign_key: true
      t.string :title, null: false
      t.boolean :required, null: false, default: true
      t.string :asin
      t.string :author, null: false
      t.integer :isbn, null: false
      t.string :publisher
      t.string :image
      t.float :retail

      t.timestamps null: false
    end
  end
end
