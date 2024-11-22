class Employee < ApplicationRecord
  has_many :reimbursements
  has_many :reimbursement_items

  validates :nickname, presence: true, uniqueness: true
end
