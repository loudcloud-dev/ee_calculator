class AddIndexToReimbursements < ActiveRecord::Migration[7.2]
  def change
    add_index :reimbursements, :employee_id
    add_index :reimbursements, :category_id
    add_index :reimbursements, :activity_date
    add_index :reimbursements, :status
  end
end
