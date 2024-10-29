class Reimbursement < ApplicationRecord
  belongs_to :employee
  has_many :reimbursement_items

  def participated_employees
    Employee.where(id: participated_employee_ids, status: "active")
  end
end
