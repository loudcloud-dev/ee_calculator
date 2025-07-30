class ReimbursementItem < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  belongs_to :employee
  belongs_to :reimbursement

  def self.used_budget_sum(employee_id:, category_id:, activity_date:)
    start_date = activity_date.beginning_of_month
    end_date = activity_date.end_of_month

    self.joins(:reimbursement)
        .where(employee_id: employee_id)
        .where(reimbursements: { category_id: category_id })
        .where.not(reimbursements: { status: "cancelled" })
        .where("reimbursements.activity_date >= ?", start_date)
        .where("reimbursements.activity_date <= ?", end_date)
        .sum(:shared_amount)
  end

  def self.reimbursement_items(employee_id:, start_date:, end_date:)
    self.select("reimbursements.category_id, SUM(reimbursement_items.shared_amount) AS total_shared_amount")
        .joins(:reimbursement)
        .where.not(reimbursements: { status: "cancelled" })
        .where(employee_id: employee_id)
        .where("reimbursements.activity_date >= ?", start_date)
        .where("reimbursements.activity_date <= ?", end_date)
        .group("reimbursements.category_id")
  end

  def formatted_shared_amount
    number_to_currency(shared_amount, unit: "₱")
  end
end
