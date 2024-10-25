class ReimbursementItem < ApplicationRecord
  belongs_to :employee
  belongs_to :reimbursement
end
  