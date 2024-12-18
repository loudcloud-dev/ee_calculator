class Leave < ApplicationRecord
  belongs_to :employee
  belongs_to :approver, class_name: "AdminUser"
  belongs_to :processed_by, class_name: "AdminUser"

  validates :employee_id, presence: true
  validates :approver_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :day_count, presence: true
  validates :leave_type, presence: true

  validate :end_date_must_be_after_start_date, :day_count_must_be_in_range

  private

  def end_date_must_be_after_start_date
    if start_date.present? && end_date.present? && start_date > end_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def day_count_must_be_in_range
    if day_count > 15 || day_count < 1
      errors.add(:day_count, "must be between 1 to 15 days")
    end
  end
end
