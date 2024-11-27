class Category < ApplicationRecord
  has_many :reimbursement

  validates :name, presence: true, uniqueness: true
  validates :icon, presence: true
end
