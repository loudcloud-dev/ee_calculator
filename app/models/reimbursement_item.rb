class ReimbursementItem < ApplicationRecord
  belongs_to :employee
  belongs_to :reimbursement

  def self.used_budget_sum(employee_id, category_id)
    ReimbursementItem.joins(:reimbursement)
                     .where(employee_id: employee_id)
                     .where(reimbursements: { category_id: category_id })
                     .where('reimbursements.activity_date >= ?', Date.today.at_beginning_of_month + 5.days)
                     .where('reimbursements.activity_date <= ?', Date.today.at_beginning_of_month.next_month + 4.days)
                     .sum(:shared_amount)
  end
end
  