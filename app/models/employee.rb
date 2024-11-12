class Employee < ApplicationRecord
  has_many :reimbursements
  has_many :reimbursement_items

  validates :nickname, uniqueness: true
end
