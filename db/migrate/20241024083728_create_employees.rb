class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :nickname
      t.string :status, default: 'active'

      t.timestamps
    end
  end
end
