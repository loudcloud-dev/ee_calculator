class Reimbursement < ApplicationRecord
  belongs_to :employee
  belongs_to :category
  has_many :reimbursement_items

  validates :employee_id, presence: true
  validates :category_id, presence: true
  validates :activity_date, presence: true
  validates :invoice_reference_number, presence: true
  validates :invoice_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :supplier, presence: true
  validate :unique_invoice_reference_number

  def participated_employees
    Employee.where(id: participated_employee_ids, status: "active")
  end

  def self.filed_reimbursements(employee_id)
    Reimbursement.select('reimbursements.*, categories.name')
                 .joins(:category)
                 .where(employee_id: employee_id)
                 .where.not(status: 'cancelled')
                 .order('reimbursements.activity_date DESC')
  end

  private

  def unique_invoice_reference_number
    unique_reimbursement = Reimbursement.where(invoice_reference_number: invoice_reference_number)
                                        .where.not(id: id)
                                        .where.not(status: "cancelled")
                                        .exists?
    
    errors.add(:invoice_reference_number, "has already been taken") if unique_reimbursement
  end
end
