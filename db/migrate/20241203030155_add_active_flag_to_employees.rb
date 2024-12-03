class AddActiveFlagToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :active, :boolean, default: true, null: false
  end
end
