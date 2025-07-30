class Employee < ApplicationRecord
  has_many :reimbursements
  has_many :reimbursement_items
  has_many :leaves

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :nickname, presence: true, uniqueness: true
  validates :email, uniqueness: true, allow_nil: true
  validates_confirmation_of :password

  before_validation :convert_blank_to_nil

  # override trackable method
  def update_tracked_fields(request)
    self.sign_in_count ||= 0
    self.sign_in_count += 1
  end

  private

  def convert_blank_to_nil
    if email.blank?
      self.email = nil
    end
  end

  protected

  # override validatable methods to allow blank emails
  def password_required?
    # TODO: validate this later on with employee_type
    false
  end

  def email_required?
    # TODO: validate this later on with employee_type
    false
  end
end
