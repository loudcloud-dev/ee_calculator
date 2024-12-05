class Employee < ApplicationRecord
  has_many :reimbursements
  has_many :reimbursement_items

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true, uniqueness: true
  validates :email, uniqueness: true, allow_nil: true

  protected

  def email_required?
    # TODO: validate this later on with employee_type
    false
  end
end
