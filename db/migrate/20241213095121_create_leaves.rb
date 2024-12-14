class CreateLeaves < ActiveRecord::Migration[8.0]
  def change
    create_table :leaves do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :approver, null: false, foreign_key: { to_table: :admin_users }
      t.date :start_date
      t.date :end_date
      t.integer :day_count
      t.string :leave_type
      t.string :reason
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
