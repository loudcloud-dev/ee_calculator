class AddTransactionIdToReimbursements < ActiveRecord::Migration[8.0]
  def change
    add_column :reimbursements, :transaction_id, :string
    add_index :reimbursements, :transaction_id
  end
end
