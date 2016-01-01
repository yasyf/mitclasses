class AddKerberosIndexToStudents < ActiveRecord::Migration
  def change
    add_index :students, :kerberos
  end
end
