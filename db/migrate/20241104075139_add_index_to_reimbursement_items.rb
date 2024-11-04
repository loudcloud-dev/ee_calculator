class AddIndexToReimbursementItems < ActiveRecord::Migration[7.2]
  def change
    add_index :reimbursement_items, :employee_id
  end
end
