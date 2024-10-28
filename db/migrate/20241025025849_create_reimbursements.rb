class CreateReimbursements < ActiveRecord::Migration[7.2]
  def change
    create_table :reimbursements do |t|
      t.integer :employee_id, null: false
      t.string :category
      t.datetime :activity_date
      t.string :invoice_reference_number
      t.decimal :invoice_amount
      t.decimal :reimbursable_amount
      t.decimal :reimbursed_amount
      t.integer :participated_employee_ids, array:true
      t.string :supplier
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
