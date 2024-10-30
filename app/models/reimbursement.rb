class Reimbursement < ApplicationRecord
  belongs_to :employee
  has_many :reimbursement_items

  validates :employee_id, presence: true
  validates :category_id, presence: true
  validates :activity_date, presence: true
  validates :invoice_reference_number, presence: true, uniqueness: true
  validates :invoice_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :supplier, presence: true

  def participated_employees
    Employee.where(id: participated_employee_ids, status: "active")
  end
end
