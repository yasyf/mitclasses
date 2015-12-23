class AddEquivalentsToMitClasses < ActiveRecord::Migration
  def change
    add_column :mit_classes, :equivalents, :string, array: true, null: false, default: []
  end
end
