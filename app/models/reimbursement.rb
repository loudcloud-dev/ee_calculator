class Reimbursement < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  belongs_to :employee
  belongs_to :category
  has_many :reimbursement_items
  has_one_attached :image

  validates :employee_id, presence: true
  validates :category_id, presence: true
  validates :activity_date, presence: true
  validates :invoice_reference_number, presence: true
  validates :invoice_amount, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10**6 } # 1,000,000
  validates :supplier, presence: true
  validate :unique_invoice_reference_number
  validates :image, attached: true,
                    content_type: [ "image/png", "image/jpeg" ],
                    size: { less_than: 10.megabytes, message: "is too large. Maximum size is 10 MB." }

  def participated_employees
    order_by_clause = participated_employee_ids.each_with_index.map { |id, index| "WHEN #{id} THEN #{index}" }.join(" ")
    Employee.where(id: participated_employee_ids, status: "active")
            .order(Arel.sql(ActiveRecord::Base.sanitize_sql_array("CASE id #{order_by_clause} END")))
  end

  def participated_employees_shares
    order_by_clause = participated_employee_ids.each_with_index.map { |id, index| "WHEN #{id} THEN #{index}" }.join(" ")
    ReimbursementItem.joins(:employee)
                     .where(reimbursement_id: id, employee_id: participated_employee_ids)
                     .order(Arel.sql(ActiveRecord::Base.sanitize_sql_array("CASE employees.id #{order_by_clause} END")))
  end

  def self.filed_reimbursements(employee_id)
    self.select("reimbursements.*, categories.name")
        .joins(:category)
        .where(employee_id: employee_id)
        .where.not(status: "cancelled")
        .order("reimbursements.activity_date DESC")
  end

  def self.item_breakdown(employee_id:, start_date:, end_date:)
    self.select("categories.name, reimbursements.activity_date, reimbursements.participated_employee_ids, reimbursement_items.shared_amount")
        .joins(:reimbursement_items)
        .joins(:category)
        .where(reimbursement_items: { employee_id: employee_id })
        .where("reimbursements.activity_date >= ?", start_date)
        .where("reimbursements.activity_date <= ?", end_date)
        .where.not(status: "cancelled")
        .order("reimbursements.activity_date DESC")
  end

  def formatted_activity_date
    activity_date.strftime("%B %d, %Y") if activity_date.present?
  end

  def formatted_invoice_amount
    format_amount(invoice_amount) if invoice_amount.present?
  end

  def formatted_reimbursable_amount
    format_amount(reimbursable_amount) if reimbursable_amount.present?
  end

  def formatted_reimbursed_amount
    format_amount(reimbursed_amount) if reimbursed_amount.present?
  end

  def formatted_shared_amount
    format_amount(shared_amount) if shared_amount.present?
  end

  private

  def unique_invoice_reference_number
    unique_reimbursement = Reimbursement.where(invoice_reference_number: invoice_reference_number)
                                        .where.not(id: id)
                                        .where.not(status: "cancelled")
                                        .exists?

    errors.add(:invoice_reference_number, "has already been taken") if unique_reimbursement
  end

  def format_amount(amount)
    number_to_currency(amount, unit: "₱")
  end
end
