class ReimbursementItem < ApplicationRecord
  belongs_to :employee
  belongs_to :reimbursement

  def self.used_budget_sum(employee_id:, category_id:, activity_date:)
    start_date = if activity_date.day < 6
                   (activity_date.beginning_of_month - 1.month).change(day: 6)
                 else
                   activity_date.beginning_of_month.change(day: 6)
                 end

    end_date = (start_date + 1.month - 1.day)

    ReimbursementItem.joins(:reimbursement)
                     .where(employee_id: employee_id)
                     .where(reimbursements: { category_id: category_id })
                     .where.not(reimbursements: { status: 'cancelled' })
                     .where('reimbursements.activity_date >= ?', start_date)
                     .where('reimbursements.activity_date <= ?', end_date)
                     .sum(:shared_amount)
  end

  def self.reimbursement_items(employee_id:, start_date:, end_date:)
    ReimbursementItem.select('reimbursements.category_id, SUM(reimbursement_items.shared_amount) AS total_shared_amount')
                     .joins(:reimbursement)
                     .where.not(reimbursements: { status: 'cancelled' })
                     .where(employee_id: employee_id)
                     .where('reimbursements.activity_date >= ?', start_date)
                     .where('reimbursements.activity_date <= ?', end_date)
                     .group('reimbursements.category_id')
  end

  def self.item_breakdown(employee_id:, start_date:, end_date:)
    Reimbursement.select('categories.name, reimbursements.activity_date, reimbursements.participated_employee_ids, reimbursement_items.shared_amount')
                 .joins(:reimbursement_items)
                 .joins(:category)
                 .where(reimbursement_items: { employee_id: employee_id })
                 .where('reimbursements.activity_date >= ?', start_date)
                 .where('reimbursements.activity_date <= ?', end_date)
                 .where.not(status: 'cancelled')
                 .order('reimbursements.activity_date DESC')
  end
end
  