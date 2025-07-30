class Leave < ApplicationRecord
  belongs_to :employee
  belongs_to :approver, class_name: "AdminUser"
  belongs_to :processed_by, class_name: "AdminUser", optional: true

  validates :employee_id, presence: true
  validates :approver_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :day_count, presence: true
  validates :leave_type, presence: true

  validate :end_date_must_be_after_start_date, :day_count_must_be_countable, :no_overlapping_dates

  scope :sick_leaves, -> { where(leave_type: "sick") }
  scope :vacation_leaves, -> { where(leave_type: "vacation") }
  scope :pending_leaves, -> { where(status: "pending").order("start_date asc") }
  scope :approved_leaves, -> { where(status: "approved").order("start_date asc") }
  scope :counted_leaves, -> { where(status: [ "pending", "approved" ]) }
  scope :uncounted_leaves, -> { where(status: [ "rejected", "cancelled" ]) }

  private

  def end_date_must_be_after_start_date
    if start_date.present? && end_date.present? && start_date > end_date
      errors.add(:end_date, "must be after the start date.")
    end
  end

  def day_count_must_be_countable
    if day_count < 1
      errors.add(:day_count, "must be greater than 0.")
    end
  end

  def no_overlapping_dates
    overlaps = Leave.counted_leaves.where.not(id: id).where(employee_id: employee_id).where("start_date <= ? and end_date >= ?", end_date, start_date)
    if !overlaps.empty?
      errors.add(:base, "Leave request shouldn't overlap with other leaves.")
    end
  end
end
