class AddProcessedByToLeaves < ActiveRecord::Migration[8.0]
  def change
    add_reference :leaves, :processed_by, foreign_key: { to_table: :admin_users }, null: true
  end
end
