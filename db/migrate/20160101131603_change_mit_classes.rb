class ChangeMitClasses < ActiveRecord::Migration
  def change
    change_column_default :mit_classes, :offered, false
  end
end
