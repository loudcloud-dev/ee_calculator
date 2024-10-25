class Reimbursement < ApplicationRecord
  belongs_to :employee
  has_many :reimbursement_items
end
