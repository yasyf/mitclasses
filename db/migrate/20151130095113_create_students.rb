class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :kerberos, null: false, unique: true

      t.timestamps null: false
    end
  end
end
