class CreateReimbursementItems < ActiveRecord::Migration[7.2]
  def change
    create_table :reimbursement_items do |t|
      t.integer :reimbursement_id, null: false
      t.integer :employee_id, null: false
      t.decimal :shared_amount

      t.timestamps
    end
  end
end
