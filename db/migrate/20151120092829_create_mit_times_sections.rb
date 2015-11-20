class CreateMitTimesSections < ActiveRecord::Migration
  def change
    create_table :mit_times_sections do |t|
      t.integer :section_id
      t.integer :mit_time_id
    end
  end
end
