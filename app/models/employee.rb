class Employee < ApplicationRecord
  has_many :reimbursements
  has_many :reimbursement_items
end
