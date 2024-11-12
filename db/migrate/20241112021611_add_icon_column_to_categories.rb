class AddIconColumnToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :icon, :string
    add_column :categories, :icon_color, :string
  end
end
